-- =============================================================================
-- Seed 02: Achievement catalogue (30 achievements)
-- criteria_type maps to profile fields or computed stats; evaluated server-side.
-- =============================================================================

INSERT INTO achievements (name, description, icon_key, category, criteria_type, criteria_value, xp_reward, is_hidden) VALUES

-- ── Streak achievements ───────────────────────────────────────────────────────
('First Spark',      'Log your first workout day streak',        'streak_01', 'streak', 'streak_days',     1,   0,  false),
('Hat Trick',        'Maintain a 3-day workout streak',          'streak_03', 'streak', 'streak_days',     3,  50,  false),
('Week Warrior',     'Maintain a 7-day workout streak',          'streak_07', 'streak', 'streak_days',     7, 100,  false),
('Fortnight Forge',  'Maintain a 14-day workout streak',         'streak_14', 'streak', 'streak_days',    14, 200,  false),
('Monthly Machine',  'Maintain a 30-day workout streak',         'streak_30', 'streak', 'streak_days',    30, 500,  false),
('Century Streak',   'Maintain a 100-day workout streak',        'streak_100','streak', 'streak_days',   100,2000,  false),

-- ── Volume / Workout count ────────────────────────────────────────────────────
('First Blood',      'Log your very first workout',              'workout_01','milestone','workouts_count',  1, 100, false),
('Ten and Going',    'Log 10 total workouts',                    'workout_10','volume',   'workouts_count', 10, 150, false),
('Half-Century',     'Log 50 total workouts',                    'workout_50','volume',   'workouts_count', 50, 300, false),
('Triple Digits',    'Log 100 total workouts',                   'workout_100','volume',  'workouts_count',100, 750, false),
('Iron Will',        'Log 500 total workouts',                   'workout_500','volume',  'workouts_count',500,2500, false),

-- ── XP / Level milestones ─────────────────────────────────────────────────────
('Level Up!',        'Reach level 5',                            'level_05',  'milestone','xp_level',  5,  100, false),
('Rising Star',      'Reach level 10',                           'level_10',  'milestone','xp_level', 10,  250, false),
('Seasoned Lifter',  'Reach level 15',                           'level_15',  'milestone','xp_level', 15,  500, false),
('Elite Athlete',    'Reach level 20',                           'level_20',  'milestone','xp_level', 20, 1000, false),
('Gym Legend',       'Reach level 25',                           'level_25',  'milestone','xp_level', 25, 2000, false),
('Transcendent',     'Reach level 30',                           'level_30',  'milestone','xp_level', 30, 5000, true ),

-- ── Performance ───────────────────────────────────────────────────────────────
('PR Hunter',        'Set your first personal record',           'pr_01',     'milestone','personal_records',  1, 75,  false),
('Record Breaker',   'Set 10 personal records',                  'pr_10',     'volume',   'personal_records', 10, 200, false),
('Record Smasher',   'Set 50 personal records',                  'pr_50',     'volume',   'personal_records', 50, 500, false),

-- ── Programs ──────────────────────────────────────────────────────────────────
('Program Starter',  'Start your first training program',        'prog_01',   'milestone','programs_started',  1,  50, false),
('Program Finisher', 'Complete your first training program',     'prog_fin',  'milestone','programs_completed',1, 200, false),
('Serial Achiever',  'Complete 5 training programs',             'prog_fin_5','volume',   'programs_completed',5, 750, false),

-- ── Social ────────────────────────────────────────────────────────────────────
('Profile Polished', 'Complete your profile (goal, avatar, age band set)', 'profile_complete','social','onboarding_complete',1,  50, false),
('Avatar Unlocked',  'Customize your avatar',                    'avatar_01', 'social',   'avatar_slots_set', 5,  25, false),
('Clan Joiner',      'Join or create a clan',                    'clan_01',   'social',   'clan_member',      1,  75, false),

-- ── Perfect week ──────────────────────────────────────────────────────────────
('Perfect Week',     'Log a workout 7 days in a single calendar week', 'perfect_week','streak','perfect_week_count', 1, 250, false),
('Relentless',       'Achieve 4 perfect weeks',                  'perfect_weeks_4','streak','perfect_week_count', 4, 750, false),

-- ── Special / Hidden ──────────────────────────────────────────────────────────
('Early Bird',       'Be among the first 50 members of your gym','early_bird','special','early_member_rank',50, 500, false),
('Night Owl',        'Log a workout after midnight (00:00–04:59)','night_owl','special','late_night_workout', 1, 100, true),
('Monday Motivation','Log a workout every Monday for a month',   'monday_month','special','monday_streak',  4, 200, true);
