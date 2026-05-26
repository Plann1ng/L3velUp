-- =============================================================================
-- Migration 00001: Core schema — gyms, profiles, gamification, workouts,
--                  programs, leaderboards, avatars, social (challenges, clans)
--
-- Conventions:
--   • All PKs: UUID via gen_random_uuid()
--   • All timestamps: TIMESTAMPTZ
--   • Soft deletes via is_archived / is_active flags, not DELETE
--   • Helper functions defined first, tables second, indexes third, RLS last
-- =============================================================================

-- ---------------------------------------------------------------------------
-- 0. Extensions
-- ---------------------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS "pgcrypto";   -- gen_random_uuid() on PG < 13
CREATE EXTENSION IF NOT EXISTS "pg_trgm";    -- GIN trigram index for exercise search

-- ---------------------------------------------------------------------------
-- 1. Shared trigger: keep updated_at current on every UPDATE
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

-- Convenience macro: attach set_updated_at to a table
CREATE OR REPLACE FUNCTION create_updated_at_trigger(tbl TEXT)
RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
  EXECUTE format(
    'CREATE TRIGGER trg_%I_updated_at
     BEFORE UPDATE ON %I
     FOR EACH ROW EXECUTE FUNCTION set_updated_at()',
    tbl, tbl
  );
END;
$$;

-- ---------------------------------------------------------------------------
-- 2. JWT helper functions (used by RLS policies)
--    app_metadata claims are set by a Supabase Auth hook on sign-in.
-- ---------------------------------------------------------------------------

-- Returns the gym_id the current JWT belongs to (NULL for super admins).
CREATE OR REPLACE FUNCTION current_user_gym_id()
RETURNS UUID LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT (auth.jwt() -> 'app_metadata' ->> 'gym_id')::UUID
$$;

-- Returns the role claim: 'member' | 'gym_staff' | 'gym_owner' | 'super_admin'
CREATE OR REPLACE FUNCTION current_user_role()
RETURNS TEXT LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT COALESCE(auth.jwt() -> 'app_metadata' ->> 'role', 'member')
$$;

-- Returns true when the caller is a gym admin (owner or staff) for the given gym.
CREATE OR REPLACE FUNCTION is_gym_admin(gid UUID)
RETURNS BOOLEAN LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT current_user_gym_id() = gid
     AND current_user_role() IN ('gym_owner', 'gym_staff')
$$;

-- Returns true for super_admin, who can bypass gym isolation.
CREATE OR REPLACE FUNCTION is_super_admin()
RETURNS BOOLEAN LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT current_user_role() = 'super_admin'
$$;

-- =============================================================================
-- TABLE DEFINITIONS
-- =============================================================================

-- ---------------------------------------------------------------------------
-- 3. Gyms — top-level white-label tenant
-- ---------------------------------------------------------------------------
CREATE TABLE gyms (
  id                UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  name              TEXT        NOT NULL,
  slug              TEXT        NOT NULL UNIQUE,
  logo_url          TEXT,
  -- White-label theme: { primaryColor, accentColor, appName, timezone }
  theme_config      JSONB       NOT NULL DEFAULT '{}'::jsonb,
  subscription_tier TEXT        NOT NULL DEFAULT 'starter'
                                CHECK (subscription_tier IN ('starter','pro','enterprise')),
  owner_id          UUID        REFERENCES auth.users(id) ON DELETE SET NULL,
  is_active         BOOLEAN     NOT NULL DEFAULT true,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

SELECT create_updated_at_trigger('gyms');

-- ---------------------------------------------------------------------------
-- 4. Gym locations (future: city/country leaderboards)
-- ---------------------------------------------------------------------------
CREATE TABLE gym_locations (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  gym_id      UUID        NOT NULL REFERENCES gyms(id) ON DELETE CASCADE,
  address     TEXT,
  city        TEXT,
  region      TEXT,
  country     TEXT,
  latitude    NUMERIC(9,6),
  longitude   NUMERIC(9,6),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

SELECT create_updated_at_trigger('gym_locations');

-- ---------------------------------------------------------------------------
-- 5. Profiles — one per auth.users row, always linked to one gym
-- ---------------------------------------------------------------------------
CREATE TYPE user_role         AS ENUM ('gym_owner','gym_staff','member');
CREATE TYPE goal_type         AS ENUM (
  'strength','muscle_gain','fat_loss','fitness',
  'cardio','power','mobility','general_health'
);
CREATE TYPE age_band          AS ENUM ('16-24','25-34','35-44','45-54','55+');
CREATE TYPE experience_level  AS ENUM ('beginner','intermediate','advanced');

-- leaderboard_visibility controls how this member appears on leaderboards:
--   public_name  → full display_name shown
--   nickname     → only avatar visible; name shown as "Athlete #N"
--   private      → excluded from all leaderboard views
CREATE TYPE leaderboard_visibility AS ENUM ('public_name','nickname','private');

CREATE TABLE profiles (
  id                          UUID                  PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  gym_id                      UUID                  NOT NULL REFERENCES gyms(id),
  role                        user_role             NOT NULL DEFAULT 'member',
  display_name                TEXT                  NOT NULL,
  -- 2D avatar layer config: { background, body, skin, bottom, shoes, top,
  --                            hair_back, face, hair_front, accessory, equipment }
  avatar_config               JSONB                 NOT NULL DEFAULT '{}'::jsonb,
  goal                        goal_type,
  age_band                    age_band,
  experience_level            experience_level,
  xp_total                    INTEGER               NOT NULL DEFAULT 0 CHECK (xp_total >= 0),
  xp_level                    INTEGER               NOT NULL DEFAULT 1 CHECK (xp_level >= 1),
  streak_current              INTEGER               NOT NULL DEFAULT 0 CHECK (streak_current >= 0),
  streak_best                 INTEGER               NOT NULL DEFAULT 0 CHECK (streak_best >= 0),
  last_workout_date           DATE,
  -- Leaderboard privacy (see enum above)
  leaderboard_visibility      leaderboard_visibility NOT NULL DEFAULT 'public_name',
  -- Opt-in flags for future city/country boards (default false — explicit consent required)
  city_leaderboard_opt_in     BOOLEAN               NOT NULL DEFAULT false,
  country_leaderboard_opt_in  BOOLEAN               NOT NULL DEFAULT false,
  onboarding_complete         BOOLEAN               NOT NULL DEFAULT false,
  is_active                   BOOLEAN               NOT NULL DEFAULT true,
  created_at                  TIMESTAMPTZ           NOT NULL DEFAULT now(),
  updated_at                  TIMESTAMPTZ           NOT NULL DEFAULT now()
);

SELECT create_updated_at_trigger('profiles');

-- ---------------------------------------------------------------------------
-- 6. Member goals — history of goal changes (one is_current per member)
-- ---------------------------------------------------------------------------
CREATE TABLE member_goals (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id  UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  goal        goal_type   NOT NULL,
  is_current  BOOLEAN     NOT NULL DEFAULT true,
  started_at  DATE        NOT NULL DEFAULT CURRENT_DATE,
  ended_at    DATE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------------
-- 7. Exercises — global seed + gym-specific custom exercises
-- ---------------------------------------------------------------------------
CREATE TYPE exercise_category AS ENUM (
  'barbell','dumbbell','machine','cable','bodyweight','cardio','stretch','other'
);

CREATE TABLE exercises (
  id            UUID              PRIMARY KEY DEFAULT gen_random_uuid(),
  -- NULL gym_id = global (seeded) exercise; non-null = gym custom exercise
  gym_id        UUID              REFERENCES gyms(id) ON DELETE CASCADE,
  name          TEXT              NOT NULL,
  category      exercise_category NOT NULL,
  muscle_groups TEXT[]            NOT NULL DEFAULT '{}',
  equipment     TEXT[]            NOT NULL DEFAULT '{}',
  instructions  TEXT,
  video_url     TEXT,
  is_archived   BOOLEAN           NOT NULL DEFAULT false,
  created_at    TIMESTAMPTZ       NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ       NOT NULL DEFAULT now()
);

SELECT create_updated_at_trigger('exercises');

-- GIN index for fast full-text exercise search
CREATE INDEX idx_exercises_name_trgm ON exercises USING GIN (name gin_trgm_ops);
CREATE INDEX idx_exercises_gym_id ON exercises (gym_id);
CREATE INDEX idx_exercises_category ON exercises (category);

-- ---------------------------------------------------------------------------
-- 8. Workout programs & structure
-- ---------------------------------------------------------------------------
CREATE TABLE workout_programs (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  gym_id          UUID        NOT NULL REFERENCES gyms(id) ON DELETE CASCADE,
  creator_id      UUID        REFERENCES profiles(id) ON DELETE SET NULL,
  name            TEXT        NOT NULL,
  description     TEXT,
  goal            goal_type,
  difficulty      experience_level,
  duration_weeks  SMALLINT    NOT NULL DEFAULT 4 CHECK (duration_weeks > 0),
  is_public       BOOLEAN     NOT NULL DEFAULT false,
  is_gym_template BOOLEAN     NOT NULL DEFAULT false,
  is_archived     BOOLEAN     NOT NULL DEFAULT false,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

SELECT create_updated_at_trigger('workout_programs');

CREATE TABLE program_days (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  program_id  UUID        NOT NULL REFERENCES workout_programs(id) ON DELETE CASCADE,
  week_number SMALLINT    NOT NULL CHECK (week_number > 0),
  day_number  SMALLINT    NOT NULL CHECK (day_number BETWEEN 1 AND 7),
  name        TEXT,   -- e.g. "Push Day", "Rest"
  UNIQUE (program_id, week_number, day_number)
);

CREATE TABLE program_exercises (
  id              UUID     PRIMARY KEY DEFAULT gen_random_uuid(),
  day_id          UUID     NOT NULL REFERENCES program_days(id) ON DELETE CASCADE,
  exercise_id     UUID     NOT NULL REFERENCES exercises(id),
  order_index     SMALLINT NOT NULL,
  target_sets     SMALLINT,
  target_reps     TEXT,    -- e.g. "8-12" or "AMRAP"
  target_weight   TEXT,    -- e.g. "70% 1RM" (instructional, not enforced)
  rest_seconds    SMALLINT,
  notes           TEXT
);

CREATE INDEX idx_program_exercises_day_id ON program_exercises (day_id);

-- Members enrolled in a program
CREATE TABLE member_programs (
  id             UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id     UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  program_id     UUID        NOT NULL REFERENCES workout_programs(id),
  started_at     DATE        NOT NULL DEFAULT CURRENT_DATE,
  current_week   SMALLINT    NOT NULL DEFAULT 1,
  current_day    SMALLINT    NOT NULL DEFAULT 1,
  completed_at   DATE,
  is_active      BOOLEAN     NOT NULL DEFAULT true,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (profile_id, program_id, started_at)
);

CREATE INDEX idx_member_programs_profile_id ON member_programs (profile_id);

-- ---------------------------------------------------------------------------
-- 9. Workout sessions & sets
-- ---------------------------------------------------------------------------
CREATE TABLE workout_sessions (
  id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id       UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  gym_id           UUID        NOT NULL REFERENCES gyms(id),
  program_id       UUID        REFERENCES workout_programs(id) ON DELETE SET NULL,
  program_day_id   UUID        REFERENCES program_days(id) ON DELETE SET NULL,
  title            TEXT,
  notes            TEXT,
  started_at       TIMESTAMPTZ NOT NULL,
  ended_at         TIMESTAMPTZ,
  duration_seconds INTEGER     CHECK (duration_seconds > 0),
  xp_earned        INTEGER     NOT NULL DEFAULT 0 CHECK (xp_earned >= 0),
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_workout_sessions_profile_id ON workout_sessions (profile_id);
CREATE INDEX idx_workout_sessions_gym_id     ON workout_sessions (gym_id);
-- Date-range queries (workout history, leaderboard periods)
CREATE INDEX idx_workout_sessions_started_at ON workout_sessions (profile_id, started_at DESC);

CREATE TABLE workout_sets (
  id                  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id          UUID        NOT NULL REFERENCES workout_sessions(id) ON DELETE CASCADE,
  exercise_id         UUID        NOT NULL REFERENCES exercises(id),
  set_number          SMALLINT    NOT NULL,
  reps                SMALLINT    CHECK (reps >= 0),
  weight_kg           NUMERIC(7,2) CHECK (weight_kg >= 0),
  duration_seconds    INTEGER     CHECK (duration_seconds >= 0),
  distance_meters     NUMERIC(9,2) CHECK (distance_meters >= 0),
  rpe                 SMALLINT    CHECK (rpe BETWEEN 1 AND 10),
  is_personal_record  BOOLEAN     NOT NULL DEFAULT false,
  completed_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_workout_sets_session_id  ON workout_sets (session_id);
CREATE INDEX idx_workout_sets_exercise_id ON workout_sets (exercise_id);

-- ---------------------------------------------------------------------------
-- 10. Gamification: XP events, streaks, daily stats, progress scores
-- ---------------------------------------------------------------------------

-- Append-only audit log of all XP awards (source of truth for xp_total)
CREATE TYPE xp_event_type AS ENUM (
  'workout_complete','streak_bonus','personal_record',
  'program_day_complete','program_complete','achievement_earned',
  'first_workout','profile_complete'
);

CREATE TABLE xp_events (
  id          UUID           PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id  UUID           NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  gym_id      UUID           NOT NULL REFERENCES gyms(id),
  event_type  xp_event_type  NOT NULL,
  xp_amount   INTEGER        NOT NULL CHECK (xp_amount > 0),
  -- Arbitrary metadata: session_id, achievement_id, etc.
  metadata    JSONB,
  created_at  TIMESTAMPTZ    NOT NULL DEFAULT now()
);

CREATE INDEX idx_xp_events_profile_id  ON xp_events (profile_id);
CREATE INDEX idx_xp_events_gym_id      ON xp_events (gym_id);
CREATE INDEX idx_xp_events_created_at  ON xp_events (profile_id, created_at DESC);

-- Streaks: one row per member (upserted by trigger/edge function)
CREATE TABLE streaks (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id      UUID        NOT NULL UNIQUE REFERENCES profiles(id) ON DELETE CASCADE,
  current_streak  INTEGER     NOT NULL DEFAULT 0,
  best_streak     INTEGER     NOT NULL DEFAULT 0,
  last_active_date DATE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

SELECT create_updated_at_trigger('streaks');

-- Daily rollup per member: pre-aggregated for leaderboard computation
CREATE TABLE member_daily_stats (
  id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id       UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  gym_id           UUID        NOT NULL REFERENCES gyms(id),
  stat_date        DATE        NOT NULL,
  session_count    SMALLINT    NOT NULL DEFAULT 0,
  total_volume_kg  NUMERIC(12,2) NOT NULL DEFAULT 0,
  total_sets       INTEGER     NOT NULL DEFAULT 0,
  personal_records INTEGER     NOT NULL DEFAULT 0,
  xp_earned        INTEGER     NOT NULL DEFAULT 0,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (profile_id, stat_date)
);

CREATE INDEX idx_member_daily_stats_profile_date ON member_daily_stats (profile_id, stat_date DESC);
CREATE INDEX idx_member_daily_stats_gym_date     ON member_daily_stats (gym_id, stat_date DESC);

-- Rolling progress scores per member — computed by the leaderboard Edge Function
CREATE TABLE member_progress_scores (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id      UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  gym_id          UUID        NOT NULL REFERENCES gyms(id),
  period          TEXT        NOT NULL CHECK (period IN ('weekly','monthly','all_time')),
  progress_score  NUMERIC(6,2) NOT NULL DEFAULT 0 CHECK (progress_score BETWEEN 0 AND 100),
  consistency_score NUMERIC(6,2) NOT NULL DEFAULT 0 CHECK (consistency_score BETWEEN 0 AND 100),
  performance_score NUMERIC(6,2) NOT NULL DEFAULT 0,
  computed_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (profile_id, period)
);

CREATE INDEX idx_member_progress_scores_gym_period ON member_progress_scores (gym_id, period);

-- ---------------------------------------------------------------------------
-- 11. Leaderboards & entries
-- ---------------------------------------------------------------------------
CREATE TYPE board_type   AS ENUM ('progress','consistency','performance');
CREATE TYPE board_scope  AS ENUM ('gym','city','country');
CREATE TYPE board_period AS ENUM ('weekly','monthly','all_time');

CREATE TABLE leaderboards (
  id              UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  gym_id          UUID         NOT NULL REFERENCES gyms(id) ON DELETE CASCADE,
  board_type      board_type   NOT NULL,
  -- 'gym' scope is MVP; 'city'/'country' require opt-in (city/country_leaderboard_opt_in)
  scope           board_scope  NOT NULL DEFAULT 'gym',
  goal_filter     goal_type,          -- NULL = all goals
  age_band_filter age_band,           -- NULL = all age bands
  exp_filter      experience_level,   -- NULL = all experience levels
  period          board_period NOT NULL,
  is_active       BOOLEAN      NOT NULL DEFAULT true,
  created_at      TIMESTAMPTZ  NOT NULL DEFAULT now(),
  -- NULLS NOT DISTINCT treats NULLs as equal for uniqueness (Postgres 15+, used by Supabase)
  UNIQUE NULLS NOT DISTINCT (gym_id, board_type, scope, goal_filter, age_band_filter, exp_filter, period)
);

CREATE INDEX idx_leaderboards_gym_id ON leaderboards (gym_id);
CREATE INDEX idx_leaderboards_scope  ON leaderboards (scope, board_type, period);

CREATE TABLE leaderboard_entries (
  id             UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  leaderboard_id UUID        NOT NULL REFERENCES leaderboards(id) ON DELETE CASCADE,
  profile_id     UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  rank           INTEGER     NOT NULL,
  score          NUMERIC(10,2) NOT NULL DEFAULT 0,
  score_delta    NUMERIC(10,2) NOT NULL DEFAULT 0,   -- vs previous snapshot
  -- Snapshot of display data at time of computation.
  -- 'private' members are never inserted; 'nickname' members have display_name replaced.
  display_name   TEXT        NOT NULL,
  avatar_config  JSONB       NOT NULL DEFAULT '{}'::jsonb,
  computed_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (leaderboard_id, profile_id)
);

CREATE INDEX idx_leaderboard_entries_leaderboard ON leaderboard_entries (leaderboard_id, rank);
CREATE INDEX idx_leaderboard_entries_profile     ON leaderboard_entries (profile_id);
CREATE INDEX idx_leaderboard_entries_computed    ON leaderboard_entries (leaderboard_id, computed_at DESC);

-- ---------------------------------------------------------------------------
-- 12. AI insight messages (coach tips per member)
-- ---------------------------------------------------------------------------
CREATE TABLE insight_messages (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id  UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  gym_id      UUID        NOT NULL REFERENCES gyms(id),
  message     TEXT        NOT NULL,
  category    TEXT        NOT NULL DEFAULT 'general'
                          CHECK (category IN ('streak','performance','milestone','general')),
  is_read     BOOLEAN     NOT NULL DEFAULT false,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_insight_messages_profile ON insight_messages (profile_id, created_at DESC);

-- ---------------------------------------------------------------------------
-- 13. Avatar assets catalogue
-- ---------------------------------------------------------------------------
CREATE TABLE avatar_assets (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  asset_key     TEXT        NOT NULL UNIQUE,  -- e.g. "hair_front/curly_01"
  slot          TEXT        NOT NULL
                            CHECK (slot IN (
                              'background','body','skin','bottom','shoes','top',
                              'hair_back','face','hair_front','accessory','equipment'
                            )),
  label         TEXT        NOT NULL,
  level_required INTEGER    NOT NULL DEFAULT 1 CHECK (level_required >= 1),
  is_premium    BOOLEAN     NOT NULL DEFAULT false,
  is_active     BOOLEAN     NOT NULL DEFAULT true,
  -- Optional: gym_id != NULL means gym-exclusive asset pack
  gym_id        UUID        REFERENCES gyms(id) ON DELETE CASCADE,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_avatar_assets_slot    ON avatar_assets (slot);
CREATE INDEX idx_avatar_assets_gym_id  ON avatar_assets (gym_id);

-- ---------------------------------------------------------------------------
-- 14. Challenges — time-boxed goals with participants
-- ---------------------------------------------------------------------------
CREATE TABLE challenges (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  gym_id          UUID        NOT NULL REFERENCES gyms(id) ON DELETE CASCADE,
  created_by      UUID        REFERENCES profiles(id) ON DELETE SET NULL,
  name            TEXT        NOT NULL,
  description     TEXT,
  goal_filter     goal_type,
  metric          TEXT        NOT NULL DEFAULT 'workouts_count',
  target_value    NUMERIC(12,2),
  starts_at       TIMESTAMPTZ NOT NULL,
  ends_at         TIMESTAMPTZ NOT NULL,
  xp_prize        INTEGER     NOT NULL DEFAULT 0,
  is_active       BOOLEAN     NOT NULL DEFAULT true,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

SELECT create_updated_at_trigger('challenges');
CREATE INDEX idx_challenges_gym_id ON challenges (gym_id);

CREATE TABLE challenge_participants (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  challenge_id  UUID        NOT NULL REFERENCES challenges(id) ON DELETE CASCADE,
  profile_id    UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  current_value NUMERIC(12,2) NOT NULL DEFAULT 0,
  rank          INTEGER,
  joined_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (challenge_id, profile_id)
);

CREATE INDEX idx_challenge_participants_challenge ON challenge_participants (challenge_id, rank);

-- ---------------------------------------------------------------------------
-- 15. Clans / Teams
-- ---------------------------------------------------------------------------
CREATE TABLE clans (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  gym_id      UUID        NOT NULL REFERENCES gyms(id) ON DELETE CASCADE,
  name        TEXT        NOT NULL,
  description TEXT,
  logo_key    TEXT,
  leader_id   UUID        REFERENCES profiles(id) ON DELETE SET NULL,
  is_active   BOOLEAN     NOT NULL DEFAULT true,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (gym_id, name)
);

SELECT create_updated_at_trigger('clans');
CREATE INDEX idx_clans_gym_id ON clans (gym_id);

CREATE TABLE clan_members (
  id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  clan_id    UUID        NOT NULL REFERENCES clans(id) ON DELETE CASCADE,
  profile_id UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  joined_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (clan_id, profile_id),
  -- One clan per member globally (MVP constraint; relax for multi-gym by removing this)
  UNIQUE (profile_id)
);

CREATE INDEX idx_clan_members_clan_id ON clan_members (clan_id);

-- =============================================================================
-- ROW LEVEL SECURITY
-- =============================================================================

-- Enable RLS on all user-facing tables
ALTER TABLE gyms                   ENABLE ROW LEVEL SECURITY;
ALTER TABLE gym_locations          ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles               ENABLE ROW LEVEL SECURITY;
ALTER TABLE member_goals           ENABLE ROW LEVEL SECURITY;
ALTER TABLE exercises              ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_programs       ENABLE ROW LEVEL SECURITY;
ALTER TABLE program_days           ENABLE ROW LEVEL SECURITY;
ALTER TABLE program_exercises      ENABLE ROW LEVEL SECURITY;
ALTER TABLE member_programs        ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_sessions       ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_sets           ENABLE ROW LEVEL SECURITY;
ALTER TABLE xp_events              ENABLE ROW LEVEL SECURITY;
ALTER TABLE streaks                ENABLE ROW LEVEL SECURITY;
ALTER TABLE member_daily_stats     ENABLE ROW LEVEL SECURITY;
ALTER TABLE member_progress_scores ENABLE ROW LEVEL SECURITY;
ALTER TABLE leaderboards           ENABLE ROW LEVEL SECURITY;
ALTER TABLE leaderboard_entries    ENABLE ROW LEVEL SECURITY;
ALTER TABLE insight_messages       ENABLE ROW LEVEL SECURITY;
ALTER TABLE avatar_assets          ENABLE ROW LEVEL SECURITY;
ALTER TABLE challenges             ENABLE ROW LEVEL SECURITY;
ALTER TABLE challenge_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE clans                  ENABLE ROW LEVEL SECURITY;
ALTER TABLE clan_members           ENABLE ROW LEVEL SECURITY;

-- ── gyms ──────────────────────────────────────────────────────────────────────
-- Any authenticated user can read their own gym's row.
-- Only the owner or super_admin can update it.
-- Inserts are restricted to super_admin (gyms are provisioned server-side).
CREATE POLICY "gyms_select_own" ON gyms
  FOR SELECT USING (
    id = current_user_gym_id() OR is_super_admin()
  );

CREATE POLICY "gyms_update_owner" ON gyms
  FOR UPDATE USING (
    (id = current_user_gym_id() AND current_user_role() = 'gym_owner')
    OR is_super_admin()
  );

CREATE POLICY "gyms_insert_super_admin" ON gyms
  FOR INSERT WITH CHECK (is_super_admin());

-- ── gym_locations ─────────────────────────────────────────────────────────────
CREATE POLICY "gym_locations_select" ON gym_locations
  FOR SELECT USING (gym_id = current_user_gym_id() OR is_super_admin());

CREATE POLICY "gym_locations_manage" ON gym_locations
  FOR ALL USING (is_gym_admin(gym_id) OR is_super_admin());

-- ── profiles ─────────────────────────────────────────────────────────────────
-- Members can read their own profile.
-- Gym admins can read all profiles in their gym.
-- Super admins can read everything.
-- Note: leaderboard display_name and avatar_config are exposed via
--       leaderboard_entries (privacy already applied), NOT via profiles directly.
CREATE POLICY "profiles_select_own" ON profiles
  FOR SELECT USING (
    id = auth.uid()
    OR (gym_id = current_user_gym_id() AND is_gym_admin(gym_id))
    OR is_super_admin()
  );

-- Members can update only their own profile row.
CREATE POLICY "profiles_update_own" ON profiles
  FOR UPDATE USING (id = auth.uid() OR is_super_admin())
  WITH CHECK  (id = auth.uid() OR is_super_admin());

-- Profiles are created by the auth trigger (service_role), not by members.
CREATE POLICY "profiles_insert_service" ON profiles
  FOR INSERT WITH CHECK (auth.role() = 'service_role' OR is_super_admin());

-- Gym owners and super_admin can deactivate (soft-delete) members.
CREATE POLICY "profiles_deactivate" ON profiles
  FOR UPDATE USING (
    (is_gym_admin(gym_id) AND id != auth.uid())  -- can't self-deactivate as owner
    OR is_super_admin()
  );

-- ── member_goals ──────────────────────────────────────────────────────────────
CREATE POLICY "member_goals_select_own" ON member_goals
  FOR SELECT USING (profile_id = auth.uid() OR is_super_admin());

CREATE POLICY "member_goals_insert_own" ON member_goals
  FOR INSERT WITH CHECK (profile_id = auth.uid());

-- ── exercises ─────────────────────────────────────────────────────────────────
-- All authenticated members of a gym can read global exercises (gym_id IS NULL)
-- plus their gym's custom exercises.
CREATE POLICY "exercises_select" ON exercises
  FOR SELECT USING (
    gym_id IS NULL                                 -- global exercise
    OR gym_id = current_user_gym_id()              -- gym-specific
    OR is_super_admin()
  );

-- Only gym admins can create/update/archive exercises for their gym.
CREATE POLICY "exercises_manage" ON exercises
  FOR ALL USING (
    is_gym_admin(gym_id) OR is_super_admin()
  ) WITH CHECK (
    gym_id = current_user_gym_id() OR is_super_admin()
  );

-- ── workout_programs ──────────────────────────────────────────────────────────
-- Members can read programs that are public or created by themselves.
-- Gym admins can read all programs in their gym.
CREATE POLICY "programs_select" ON workout_programs
  FOR SELECT USING (
    (
      gym_id = current_user_gym_id()
      AND (is_public OR creator_id = auth.uid() OR is_gym_admin(gym_id))
    )
    OR is_super_admin()
  );

-- Gym admins can manage any program in their gym.
-- Members can manage only their own programs (non-templates).
CREATE POLICY "programs_manage" ON workout_programs
  FOR ALL USING (
    is_gym_admin(gym_id)
    OR (creator_id = auth.uid() AND NOT is_gym_template)
    OR is_super_admin()
  ) WITH CHECK (
    (gym_id = current_user_gym_id() AND is_gym_admin(gym_id))
    OR (creator_id = auth.uid() AND NOT is_gym_template)
    OR is_super_admin()
  );

-- ── program_days & program_exercises ──────────────────────────────────────────
-- Access is derived from the parent program's policies.
CREATE POLICY "program_days_select" ON program_days
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM workout_programs p
      WHERE p.id = program_id
        AND (
          (p.gym_id = current_user_gym_id() AND (p.is_public OR p.creator_id = auth.uid() OR is_gym_admin(p.gym_id)))
          OR is_super_admin()
        )
    )
  );

CREATE POLICY "program_days_manage" ON program_days
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM workout_programs p
      WHERE p.id = program_id
        AND (is_gym_admin(p.gym_id) OR p.creator_id = auth.uid() OR is_super_admin())
    )
  );

CREATE POLICY "program_exercises_select" ON program_exercises
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM program_days pd
      JOIN workout_programs p ON p.id = pd.program_id
      WHERE pd.id = day_id
        AND (
          (p.gym_id = current_user_gym_id() AND (p.is_public OR p.creator_id = auth.uid() OR is_gym_admin(p.gym_id)))
          OR is_super_admin()
        )
    )
  );

CREATE POLICY "program_exercises_manage" ON program_exercises
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM program_days pd
      JOIN workout_programs p ON p.id = pd.program_id
      WHERE pd.id = day_id
        AND (is_gym_admin(p.gym_id) OR p.creator_id = auth.uid() OR is_super_admin())
    )
  );

-- ── member_programs ───────────────────────────────────────────────────────────
CREATE POLICY "member_programs_select" ON member_programs
  FOR SELECT USING (
    profile_id = auth.uid()
    OR (is_gym_admin(current_user_gym_id()) AND EXISTS (
      SELECT 1 FROM profiles p WHERE p.id = profile_id AND p.gym_id = current_user_gym_id()
    ))
    OR is_super_admin()
  );

CREATE POLICY "member_programs_manage_own" ON member_programs
  FOR ALL USING (profile_id = auth.uid() OR is_super_admin())
  WITH CHECK (profile_id = auth.uid() OR is_super_admin());

-- ── workout_sessions ──────────────────────────────────────────────────────────
-- Members can read and write only their own sessions.
-- Gym admins can read all sessions within their gym.
CREATE POLICY "workout_sessions_select" ON workout_sessions
  FOR SELECT USING (
    profile_id = auth.uid()
    OR (gym_id = current_user_gym_id() AND is_gym_admin(gym_id))
    OR is_super_admin()
  );

CREATE POLICY "workout_sessions_insert_own" ON workout_sessions
  FOR INSERT WITH CHECK (
    profile_id = auth.uid()
    AND gym_id = current_user_gym_id()
  );

CREATE POLICY "workout_sessions_update_own" ON workout_sessions
  FOR UPDATE USING (profile_id = auth.uid() OR is_super_admin());

CREATE POLICY "workout_sessions_delete_own" ON workout_sessions
  FOR DELETE USING (profile_id = auth.uid() OR is_super_admin());

-- ── workout_sets ──────────────────────────────────────────────────────────────
CREATE POLICY "workout_sets_select" ON workout_sets
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM workout_sessions s
      WHERE s.id = session_id
        AND (
          s.profile_id = auth.uid()
          OR (s.gym_id = current_user_gym_id() AND is_gym_admin(s.gym_id))
          OR is_super_admin()
        )
    )
  );

CREATE POLICY "workout_sets_insert_own" ON workout_sets
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM workout_sessions s
      WHERE s.id = session_id AND s.profile_id = auth.uid()
    )
  );

CREATE POLICY "workout_sets_update_own" ON workout_sets
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM workout_sessions s
      WHERE s.id = session_id AND s.profile_id = auth.uid()
    )
    OR is_super_admin()
  );

CREATE POLICY "workout_sets_delete_own" ON workout_sets
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM workout_sessions s
      WHERE s.id = session_id AND s.profile_id = auth.uid()
    )
    OR is_super_admin()
  );

-- ── xp_events ─────────────────────────────────────────────────────────────────
-- xp_events are written by service_role (Edge Functions), never by the client.
-- Members can read their own events; gym admins can read all events in their gym.
CREATE POLICY "xp_events_select" ON xp_events
  FOR SELECT USING (
    profile_id = auth.uid()
    OR (gym_id = current_user_gym_id() AND is_gym_admin(gym_id))
    OR is_super_admin()
  );

-- Only server-side (service_role) can write XP events to prevent manipulation.
CREATE POLICY "xp_events_insert_service" ON xp_events
  FOR INSERT WITH CHECK (auth.role() = 'service_role' OR is_super_admin());

-- ── streaks ───────────────────────────────────────────────────────────────────
CREATE POLICY "streaks_select_own" ON streaks
  FOR SELECT USING (profile_id = auth.uid() OR is_gym_admin(current_user_gym_id()) OR is_super_admin());

CREATE POLICY "streaks_manage_service" ON streaks
  FOR ALL USING (auth.role() = 'service_role' OR is_super_admin());

-- ── member_daily_stats & member_progress_scores ───────────────────────────────
CREATE POLICY "member_daily_stats_select" ON member_daily_stats
  FOR SELECT USING (
    profile_id = auth.uid()
    OR (gym_id = current_user_gym_id() AND is_gym_admin(gym_id))
    OR is_super_admin()
  );

CREATE POLICY "member_daily_stats_service" ON member_daily_stats
  FOR ALL USING (auth.role() = 'service_role' OR is_super_admin());

CREATE POLICY "member_progress_scores_select" ON member_progress_scores
  FOR SELECT USING (
    profile_id = auth.uid()
    OR (gym_id = current_user_gym_id() AND is_gym_admin(gym_id))
    OR is_super_admin()
  );

CREATE POLICY "member_progress_scores_service" ON member_progress_scores
  FOR ALL USING (auth.role() = 'service_role' OR is_super_admin());

-- ── leaderboards ──────────────────────────────────────────────────────────────
-- Any member of the gym can read the gym's leaderboard definitions.
-- City/country leaderboards are also readable (opt-in is checked when building entries).
CREATE POLICY "leaderboards_select" ON leaderboards
  FOR SELECT USING (
    gym_id = current_user_gym_id() OR is_super_admin()
  );

CREATE POLICY "leaderboards_manage" ON leaderboards
  FOR ALL USING (is_gym_admin(gym_id) OR is_super_admin());

-- ── leaderboard_entries ───────────────────────────────────────────────────────
-- Members can read leaderboard entries for their gym's active boards.
-- IMPORTANT: Privacy is enforced at write time (Edge Function) — 'private' members
-- are never inserted, and 'nickname' members have display_name replaced with "Athlete #N".
-- This policy intentionally does NOT filter by privacy here to keep reads fast.
CREATE POLICY "leaderboard_entries_select" ON leaderboard_entries
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM leaderboards lb
      WHERE lb.id = leaderboard_id
        AND (lb.gym_id = current_user_gym_id() OR is_super_admin())
    )
  );

-- Only service_role writes leaderboard entries (computed server-side).
CREATE POLICY "leaderboard_entries_service" ON leaderboard_entries
  FOR ALL USING (auth.role() = 'service_role' OR is_super_admin());

-- ── insight_messages ──────────────────────────────────────────────────────────
CREATE POLICY "insight_messages_select_own" ON insight_messages
  FOR SELECT USING (profile_id = auth.uid() OR is_super_admin());

CREATE POLICY "insight_messages_update_own" ON insight_messages
  FOR UPDATE USING (profile_id = auth.uid() OR is_super_admin());

CREATE POLICY "insight_messages_service" ON insight_messages
  FOR INSERT WITH CHECK (auth.role() = 'service_role' OR is_super_admin());

-- ── avatar_assets ─────────────────────────────────────────────────────────────
-- All authenticated users can read the global asset catalogue.
-- Gym-specific assets are visible only to members of that gym.
CREATE POLICY "avatar_assets_select" ON avatar_assets
  FOR SELECT USING (
    gym_id IS NULL                       -- global asset
    OR gym_id = current_user_gym_id()    -- gym-exclusive pack
    OR is_super_admin()
  );

CREATE POLICY "avatar_assets_manage" ON avatar_assets
  FOR ALL USING (auth.role() = 'service_role' OR is_super_admin());

-- ── challenges ────────────────────────────────────────────────────────────────
CREATE POLICY "challenges_select" ON challenges
  FOR SELECT USING (
    (gym_id = current_user_gym_id() AND is_active) OR is_super_admin()
  );

CREATE POLICY "challenges_manage" ON challenges
  FOR ALL USING (is_gym_admin(gym_id) OR is_super_admin());

CREATE POLICY "challenge_participants_select" ON challenge_participants
  FOR SELECT USING (
    profile_id = auth.uid()
    OR (is_gym_admin(current_user_gym_id()) AND EXISTS (
      SELECT 1 FROM challenges c WHERE c.id = challenge_id AND c.gym_id = current_user_gym_id()
    ))
    OR is_super_admin()
  );

CREATE POLICY "challenge_participants_manage_own" ON challenge_participants
  FOR ALL USING (
    profile_id = auth.uid() OR auth.role() = 'service_role' OR is_super_admin()
  ) WITH CHECK (
    profile_id = auth.uid() OR auth.role() = 'service_role' OR is_super_admin()
  );

-- ── clans & clan_members ──────────────────────────────────────────────────────
CREATE POLICY "clans_select" ON clans
  FOR SELECT USING (
    (gym_id = current_user_gym_id() AND is_active) OR is_super_admin()
  );

CREATE POLICY "clans_manage" ON clans
  FOR ALL USING (is_gym_admin(gym_id) OR is_super_admin());

CREATE POLICY "clan_members_select" ON clan_members
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM clans c WHERE c.id = clan_id AND c.gym_id = current_user_gym_id()
    )
    OR is_super_admin()
  );

CREATE POLICY "clan_members_manage_own" ON clan_members
  FOR ALL USING (
    profile_id = auth.uid()
    OR is_gym_admin(current_user_gym_id())
    OR is_super_admin()
  );
