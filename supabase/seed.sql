-- =============================================================================
-- Supabase seed entry point — run via: supabase db seed
-- Or manually: psql $DATABASE_URL -f supabase/seed.sql
--
-- WARNING: seed/04_demo_gym.sql is for LOCAL DEV ONLY.
-- Remove that \i line before running on staging/production.
-- =============================================================================

\i seed/01_exercises.sql
\i seed/02_achievements.sql
\i seed/03_avatar_assets.sql
\i seed/04_demo_gym.sql
