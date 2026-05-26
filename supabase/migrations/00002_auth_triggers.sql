-- =============================================================================
-- Migration 00002: Auth triggers and helper functions
--
-- • handle_new_user: auto-creates a profiles row when a new auth.users row
--   is inserted (triggered by Supabase Auth on sign-up or magic-link accept).
-- • Gym join is done via gym_invitations (see migration 00003); this trigger
--   just creates the profile shell linked to the gym from the invitation.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Achievements table (lightweight — criteria evaluated by Edge Function)
-- ---------------------------------------------------------------------------
CREATE TABLE achievements (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  name            TEXT        NOT NULL,
  description     TEXT        NOT NULL,
  icon_key        TEXT        NOT NULL,
  category        TEXT        NOT NULL
                              CHECK (category IN ('streak','volume','milestone','social','special')),
  criteria_type   TEXT        NOT NULL,  -- e.g. 'streak_days', 'workouts_count', 'xp_level'
  criteria_value  INTEGER     NOT NULL,
  xp_reward       INTEGER     NOT NULL DEFAULT 0,
  is_hidden       BOOLEAN     NOT NULL DEFAULT false,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE member_achievements (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id      UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  achievement_id  UUID        NOT NULL REFERENCES achievements(id),
  earned_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (profile_id, achievement_id)
);

ALTER TABLE achievements        ENABLE ROW LEVEL SECURITY;
ALTER TABLE member_achievements ENABLE ROW LEVEL SECURITY;

-- All authenticated users can read the achievement catalogue.
CREATE POLICY "achievements_select" ON achievements
  FOR SELECT TO authenticated USING (true);

-- Service role manages achievement definitions (seeded, not user-editable).
CREATE POLICY "achievements_manage" ON achievements
  FOR ALL USING (auth.role() = 'service_role' OR (SELECT is_super_admin()));

CREATE POLICY "member_achievements_select" ON member_achievements
  FOR SELECT USING (
    profile_id = auth.uid()
    OR ((SELECT is_gym_admin(current_user_gym_id())) AND EXISTS (
      SELECT 1 FROM profiles p
      WHERE p.id = profile_id AND p.gym_id = current_user_gym_id()
    ))
    OR (SELECT is_super_admin())
  );

CREATE POLICY "member_achievements_service" ON member_achievements
  FOR INSERT WITH CHECK (auth.role() = 'service_role' OR (SELECT is_super_admin()));

-- ---------------------------------------------------------------------------
-- Gym invitations
-- ---------------------------------------------------------------------------
CREATE TABLE gym_invitations (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  gym_id      UUID        NOT NULL REFERENCES gyms(id) ON DELETE CASCADE,
  email       TEXT        NOT NULL,
  role        user_role   NOT NULL DEFAULT 'member',
  token       TEXT        NOT NULL UNIQUE DEFAULT encode(gen_random_bytes(32), 'hex'),
  invited_by  UUID        REFERENCES profiles(id) ON DELETE SET NULL,
  accepted_at TIMESTAMPTZ,
  expires_at  TIMESTAMPTZ NOT NULL DEFAULT (now() + INTERVAL '7 days'),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE gym_invitations ENABLE ROW LEVEL SECURITY;

-- Gym admins can read and create invitations for their gym.
CREATE POLICY "gym_invitations_select" ON gym_invitations
  FOR SELECT USING (
    gym_id = current_user_gym_id() AND is_gym_admin(gym_id)
    OR is_super_admin()
  );

CREATE POLICY "gym_invitations_insert" ON gym_invitations
  FOR INSERT WITH CHECK (
    gym_id = current_user_gym_id() AND is_gym_admin(gym_id)
    OR is_super_admin()
  );

-- Service role can update (mark accepted).
CREATE POLICY "gym_invitations_update_service" ON gym_invitations
  FOR UPDATE USING (auth.role() = 'service_role' OR is_super_admin());

-- ---------------------------------------------------------------------------
-- Baseline metrics (used for progress leaderboard computation)
-- ---------------------------------------------------------------------------
CREATE TABLE baseline_metrics (
  id                UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id        UUID        NOT NULL UNIQUE REFERENCES profiles(id) ON DELETE CASCADE,
  recorded_at       DATE        NOT NULL DEFAULT CURRENT_DATE,
  body_weight_kg    NUMERIC(5,2) CHECK (body_weight_kg > 0),
  bench_1rm_kg      NUMERIC(5,2) CHECK (bench_1rm_kg >= 0),
  squat_1rm_kg      NUMERIC(5,2) CHECK (squat_1rm_kg >= 0),
  deadlift_1rm_kg   NUMERIC(5,2) CHECK (deadlift_1rm_kg >= 0),
  run_5k_seconds    INTEGER      CHECK (run_5k_seconds > 0),
  pushups_max       SMALLINT     CHECK (pushups_max >= 0),
  -- Extensible for goal-specific metrics
  extra_metrics     JSONB        NOT NULL DEFAULT '{}'::jsonb,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

SELECT create_updated_at_trigger('baseline_metrics');

ALTER TABLE baseline_metrics ENABLE ROW LEVEL SECURITY;

-- Only the member themselves can read/write their own baseline metrics.
-- Gym admins cannot read these — they're used only server-side for computation.
CREATE POLICY "baseline_metrics_own" ON baseline_metrics
  FOR ALL USING (profile_id = auth.uid() OR is_super_admin())
  WITH CHECK (profile_id = auth.uid() OR is_super_admin());

-- ---------------------------------------------------------------------------
-- Trigger: auto-create profiles row on auth.users insert
-- ---------------------------------------------------------------------------
-- This trigger fires after Supabase Auth creates the auth.users row.
-- The raw_user_meta_data is expected to contain:
--   { gym_id: uuid, display_name: string, role: user_role }
-- These are set either by the invitation flow or gym self-registration.
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_gym_id      UUID;
  v_display     TEXT;
  v_role        user_role;
BEGIN
  v_gym_id  := (NEW.raw_user_meta_data ->> 'gym_id')::UUID;
  v_display := COALESCE(NEW.raw_user_meta_data ->> 'display_name', split_part(NEW.email, '@', 1));
  v_role    := COALESCE((NEW.raw_user_meta_data ->> 'role')::user_role, 'member');

  IF v_gym_id IS NOT NULL THEN
    INSERT INTO profiles (id, gym_id, role, display_name)
    VALUES (NEW.id, v_gym_id, v_role, v_display)
    ON CONFLICT (id) DO NOTHING;
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();
