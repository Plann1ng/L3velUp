-- =============================================================================
-- Seed 04: Demo gym, one admin profile, and five member profiles
--
-- IMPORTANT: This seed is for LOCAL DEVELOPMENT only.
-- Do NOT run on production — it creates auth.users rows directly,
-- bypassing email confirmation, which is intentional for dev convenience.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- 1. Gym
-- ---------------------------------------------------------------------------
INSERT INTO gyms (id, name, slug, theme_config, subscription_tier, is_active)
VALUES (
  'aaaaaaaa-0000-0000-0000-000000000001',
  'IronForge Gym',
  'ironforge',
  jsonb_build_object(
    'primaryColor', '#e63946',
    'accentColor',  '#457b9d',
    'appName',      'IronForge',
    'timezone',     'Europe/London'
  ),
  'pro',
  true
);

INSERT INTO gym_locations (gym_id, address, city, region, country, latitude, longitude)
VALUES (
  'aaaaaaaa-0000-0000-0000-000000000001',
  '12 Steel Street',
  'London',
  'Greater London',
  'GB',
  51.5074,
  -0.1278
);

-- ---------------------------------------------------------------------------
-- 2. Auth users
--    Passwords are hashed bcrypt of 'Password123!' for all seed users.
--    In real Supabase local dev, use the Studio UI or API to create users.
-- ---------------------------------------------------------------------------
DO $$
DECLARE
  gym_id UUID := 'aaaaaaaa-0000-0000-0000-000000000001';
BEGIN
  -- Supabase auth.users requires: aud, role, id, email, encrypted_password, email_confirmed_at
  -- Admin user
  INSERT INTO auth.users (
    id, aud, role, email, encrypted_password, email_confirmed_at,
    raw_user_meta_data, created_at, updated_at
  ) VALUES (
    'bbbbbbbb-0000-0000-0000-000000000001',
    'authenticated', 'authenticated',
    'admin@ironforge.gym',
    crypt('Password123!', gen_salt('bf')),
    now(),
    jsonb_build_object('gym_id', gym_id, 'display_name', 'Alex (Admin)', 'role', 'gym_owner'),
    now(), now()
  ) ON CONFLICT (id) DO NOTHING;

  -- Member 1
  INSERT INTO auth.users (
    id, aud, role, email, encrypted_password, email_confirmed_at,
    raw_user_meta_data, created_at, updated_at
  ) VALUES (
    'bbbbbbbb-0000-0000-0000-000000000002',
    'authenticated', 'authenticated',
    'morgan@example.com',
    crypt('Password123!', gen_salt('bf')),
    now(),
    jsonb_build_object('gym_id', gym_id, 'display_name', 'Morgan Davies', 'role', 'member'),
    now(), now()
  ) ON CONFLICT (id) DO NOTHING;

  -- Member 2
  INSERT INTO auth.users (
    id, aud, role, email, encrypted_password, email_confirmed_at,
    raw_user_meta_data, created_at, updated_at
  ) VALUES (
    'bbbbbbbb-0000-0000-0000-000000000003',
    'authenticated', 'authenticated',
    'sam@example.com',
    crypt('Password123!', gen_salt('bf')),
    now(),
    jsonb_build_object('gym_id', gym_id, 'display_name', 'Sam Okafor', 'role', 'member'),
    now(), now()
  ) ON CONFLICT (id) DO NOTHING;

  -- Member 3
  INSERT INTO auth.users (
    id, aud, role, email, encrypted_password, email_confirmed_at,
    raw_user_meta_data, created_at, updated_at
  ) VALUES (
    'bbbbbbbb-0000-0000-0000-000000000004',
    'authenticated', 'authenticated',
    'jamie@example.com',
    crypt('Password123!', gen_salt('bf')),
    now(),
    jsonb_build_object('gym_id', gym_id, 'display_name', 'Jamie Reyes', 'role', 'member'),
    now(), now()
  ) ON CONFLICT (id) DO NOTHING;

  -- Member 4
  INSERT INTO auth.users (
    id, aud, role, email, encrypted_password, email_confirmed_at,
    raw_user_meta_data, created_at, updated_at
  ) VALUES (
    'bbbbbbbb-0000-0000-0000-000000000005',
    'authenticated', 'authenticated',
    'priya@example.com',
    crypt('Password123!', gen_salt('bf')),
    now(),
    jsonb_build_object('gym_id', gym_id, 'display_name', 'Priya Sharma', 'role', 'member'),
    now(), now()
  ) ON CONFLICT (id) DO NOTHING;

  -- Member 5
  INSERT INTO auth.users (
    id, aud, role, email, encrypted_password, email_confirmed_at,
    raw_user_meta_data, created_at, updated_at
  ) VALUES (
    'bbbbbbbb-0000-0000-0000-000000000006',
    'authenticated', 'authenticated',
    'taylor@example.com',
    crypt('Password123!', gen_salt('bf')),
    now(),
    jsonb_build_object('gym_id', gym_id, 'display_name', 'Taylor Brooks', 'role', 'member'),
    now(), now()
  ) ON CONFLICT (id) DO NOTHING;
END;
$$;

-- ---------------------------------------------------------------------------
-- 3. Profiles (the handle_new_user trigger fires on auth.users INSERT,
--    but since we use ON CONFLICT DO NOTHING the trigger may or may not fire
--    depending on Supabase version. We upsert profiles explicitly here too.)
-- ---------------------------------------------------------------------------
INSERT INTO profiles (
  id, gym_id, role, display_name, goal, age_band, experience_level,
  xp_total, xp_level, streak_current, streak_best,
  leaderboard_visibility, onboarding_complete,
  avatar_config
) VALUES
(
  'bbbbbbbb-0000-0000-0000-000000000001',
  'aaaaaaaa-0000-0000-0000-000000000001',
  'gym_owner', 'Alex (Admin)',
  'strength', '35-44', 'advanced',
  9745, 10, 14, 30, 'public_name', true,
  '{"background":"background/gym_01","body":"body/powerlifter","skin":"skin/tone_03","bottom":"bottom/shorts_01","shoes":"shoes/lifting_01","top":"top/tank_01","face":"face/intense_01","hair_front":"hair_front/bald","accessory":"accessory/none"}'::jsonb
),
(
  'bbbbbbbb-0000-0000-0000-000000000002',
  'aaaaaaaa-0000-0000-0000-000000000001',
  'member', 'Morgan Davies',
  'muscle_gain', '25-34', 'intermediate',
  3420, 7, 5, 21, 'public_name', true,
  '{"background":"background/gym_02","body":"body/athletic_01","skin":"skin/tone_04","bottom":"bottom/leggings_01","shoes":"shoes/trainers_01","top":"top/compression_01","face":"face/smile_01","hair_front":"hair_front/curly_01","accessory":"accessory/headband_01"}'::jsonb
),
(
  'bbbbbbbb-0000-0000-0000-000000000003',
  'aaaaaaaa-0000-0000-0000-000000000001',
  'member', 'Sam Okafor',
  'fat_loss', '16-24', 'beginner',
  850, 4, 3, 7, 'nickname', true,
  '{"background":"background/gym_01","body":"body/lean_01","skin":"skin/tone_07","bottom":"bottom/shorts_02","shoes":"shoes/trainers_02","top":"top/tshirt_01","face":"face/focus_01","hair_front":"hair_front/short_01"}'::jsonb
),
(
  'bbbbbbbb-0000-0000-0000-000000000004',
  'aaaaaaaa-0000-0000-0000-000000000001',
  'member', 'Jamie Reyes',
  'cardio', '25-34', 'intermediate',
  2100, 6, 0, 14, 'public_name', true,
  '{"background":"background/outdoor_01","body":"body/lean_01","skin":"skin/tone_05","bottom":"bottom/compression","shoes":"shoes/runners_01","top":"top/tank_02","face":"face/smile_01","hair_front":"hair_front/medium_01","accessory":"accessory/cap_01"}'::jsonb
),
(
  'bbbbbbbb-0000-0000-0000-000000000005',
  'aaaaaaaa-0000-0000-0000-000000000001',
  'member', 'Priya Sharma',
  'mobility', '35-44', 'beginner',
  400, 3, 2, 5, 'public_name', true,
  '{"background":"background/gym_01","body":"body/athletic_01","skin":"skin/tone_06","bottom":"bottom/leggings_01","shoes":"shoes/barefoot","top":"top/tank_01","face":"face/neutral_01","hair_front":"hair_front/bun_01","accessory":"accessory/none"}'::jsonb
),
(
  'bbbbbbbb-0000-0000-0000-000000000006',
  'aaaaaaaa-0000-0000-0000-000000000001',
  'member', 'Taylor Brooks',
  'strength', '45-54', 'advanced',
  8200, 9, 7, 42, 'private', true,
  '{"background":"background/gym_02","body":"body/stocky_01","skin":"skin/tone_02","bottom":"bottom/sweatpants","shoes":"shoes/lifting_01","top":"top/hoodie_01","face":"face/focus_01","hair_front":"hair_front/short_01"}'::jsonb
)
ON CONFLICT (id) DO UPDATE
  SET goal = EXCLUDED.goal,
      age_band = EXCLUDED.age_band,
      experience_level = EXCLUDED.experience_level,
      xp_total = EXCLUDED.xp_total,
      xp_level = EXCLUDED.xp_level,
      streak_current = EXCLUDED.streak_current,
      streak_best = EXCLUDED.streak_best,
      leaderboard_visibility = EXCLUDED.leaderboard_visibility,
      onboarding_complete = EXCLUDED.onboarding_complete,
      avatar_config = EXCLUDED.avatar_config;

-- ---------------------------------------------------------------------------
-- 4. Seed streaks rows for each member
-- ---------------------------------------------------------------------------
INSERT INTO streaks (profile_id, current_streak, best_streak, last_active_date)
VALUES
  ('bbbbbbbb-0000-0000-0000-000000000001', 14, 30, CURRENT_DATE - 1),
  ('bbbbbbbb-0000-0000-0000-000000000002',  5, 21, CURRENT_DATE),
  ('bbbbbbbb-0000-0000-0000-000000000003',  3,  7, CURRENT_DATE - 1),
  ('bbbbbbbb-0000-0000-0000-000000000004',  0, 14, CURRENT_DATE - 5),
  ('bbbbbbbb-0000-0000-0000-000000000005',  2,  5, CURRENT_DATE - 2),
  ('bbbbbbbb-0000-0000-0000-000000000006',  7, 42, CURRENT_DATE)
ON CONFLICT (profile_id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 5. Sample leaderboard definitions for IronForge
-- ---------------------------------------------------------------------------
INSERT INTO leaderboards (gym_id, board_type, scope, goal_filter, age_band_filter, exp_filter, period)
VALUES
  -- All-goals boards (no filters)
  ('aaaaaaaa-0000-0000-0000-000000000001', 'performance', 'gym', NULL, NULL, NULL, 'weekly'),
  ('aaaaaaaa-0000-0000-0000-000000000001', 'performance', 'gym', NULL, NULL, NULL, 'monthly'),
  ('aaaaaaaa-0000-0000-0000-000000000001', 'consistency', 'gym', NULL, NULL, NULL, 'weekly'),
  ('aaaaaaaa-0000-0000-0000-000000000001', 'consistency', 'gym', NULL, NULL, NULL, 'monthly'),
  ('aaaaaaaa-0000-0000-0000-000000000001', 'progress',    'gym', NULL, NULL, NULL, 'monthly'),
  ('aaaaaaaa-0000-0000-0000-000000000001', 'progress',    'gym', NULL, NULL, NULL, 'all_time'),
  -- Strength-only board
  ('aaaaaaaa-0000-0000-0000-000000000001', 'performance', 'gym', 'strength', NULL, NULL, 'monthly')
ON CONFLICT DO NOTHING;
