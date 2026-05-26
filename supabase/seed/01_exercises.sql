-- =============================================================================
-- Seed 01: Global exercise library (25+ common exercises)
-- gym_id IS NULL means globally available to all gyms.
-- =============================================================================

INSERT INTO exercises (id, gym_id, name, category, muscle_groups, equipment, instructions) VALUES

-- ── Barbell ──────────────────────────────────────────────────────────────────
(gen_random_uuid(), NULL, 'Barbell Back Squat',    'barbell',    ARRAY['quads','glutes','hamstrings','core'],
 ARRAY['barbell','squat rack'],
 'Stand with bar on upper traps. Descend until thighs are parallel or below. Drive through heels to stand.'),

(gen_random_uuid(), NULL, 'Barbell Deadlift',       'barbell',    ARRAY['hamstrings','glutes','back','traps'],
 ARRAY['barbell'],
 'Hinge at hips with bar over mid-foot. Grip outside legs. Drive floor away, keeping back neutral.'),

(gen_random_uuid(), NULL, 'Barbell Bench Press',    'barbell',    ARRAY['chest','triceps','front delts'],
 ARRAY['barbell','bench'],
 'Lie flat. Lower bar to lower chest with elbows ~45°. Press to lockout.'),

(gen_random_uuid(), NULL, 'Barbell Overhead Press', 'barbell',    ARRAY['front delts','triceps','upper traps'],
 ARRAY['barbell'],
 'Press bar from clavicle height to lockout overhead. Keep core braced.'),

(gen_random_uuid(), NULL, 'Barbell Romanian Deadlift','barbell',  ARRAY['hamstrings','glutes','lower back'],
 ARRAY['barbell'],
 'Hold bar at hips. Push hips back, keeping bar close to legs. Feel hamstring stretch, then drive hips forward.'),

(gen_random_uuid(), NULL, 'Barbell Row',             'barbell',   ARRAY['lats','rhomboids','rear delts','biceps'],
 ARRAY['barbell'],
 'Hinge to ~45°. Pull bar to lower rib cage, leading with elbows.'),

(gen_random_uuid(), NULL, 'Barbell Hip Thrust',      'barbell',   ARRAY['glutes','hamstrings'],
 ARRAY['barbell','bench'],
 'Shoulders on bench, bar across hips. Drive hips to full extension, squeezing glutes at top.'),

-- ── Dumbbell ─────────────────────────────────────────────────────────────────
(gen_random_uuid(), NULL, 'Dumbbell Bench Press',   'dumbbell',   ARRAY['chest','triceps','front delts'],
 ARRAY['dumbbells','bench'],
 'Control dumbbells to chest width. Press to lockout, allowing natural arc.'),

(gen_random_uuid(), NULL, 'Dumbbell Shoulder Press','dumbbell',   ARRAY['front delts','triceps','upper traps'],
 ARRAY['dumbbells'],
 'Press from ear level to lockout. Keep core engaged to avoid arching.'),

(gen_random_uuid(), NULL, 'Dumbbell Romanian Deadlift','dumbbell',ARRAY['hamstrings','glutes'],
 ARRAY['dumbbells'],
 'Hold dumbbells in front of thighs. Push hips back, lowering to mid-shin.'),

(gen_random_uuid(), NULL, 'Dumbbell Lateral Raise', 'dumbbell',   ARRAY['side delts'],
 ARRAY['dumbbells'],
 'Raise dumbbells to shoulder height with slight forward lean. Control the descent.'),

(gen_random_uuid(), NULL, 'Dumbbell Bicep Curl',    'dumbbell',   ARRAY['biceps','forearms'],
 ARRAY['dumbbells'],
 'Curl from hip to shoulder, supinating the wrist. Lower with control.'),

(gen_random_uuid(), NULL, 'Dumbbell Tricep Kickback','dumbbell',  ARRAY['triceps'],
 ARRAY['dumbbells'],
 'Hinge over bench. Lock upper arm parallel to floor, extend forearm back to lockout.'),

-- ── Cable ─────────────────────────────────────────────────────────────────────
(gen_random_uuid(), NULL, 'Cable Row',              'cable',      ARRAY['lats','rhomboids','rear delts','biceps'],
 ARRAY['cable machine'],
 'Sit with slight forward lean. Pull handle to lower ribcage, squeezing shoulder blades.'),

(gen_random_uuid(), NULL, 'Cable Lat Pulldown',     'cable',      ARRAY['lats','biceps','rear delts'],
 ARRAY['cable machine','pulldown bar'],
 'Pull bar to upper chest, elbows pointing toward floor. Control the return.'),

(gen_random_uuid(), NULL, 'Cable Face Pull',        'cable',      ARRAY['rear delts','external rotators','upper traps'],
 ARRAY['cable machine','rope attachment'],
 'Pull rope to face level, separating hands at the end. Elbows above wrists.'),

(gen_random_uuid(), NULL, 'Cable Tricep Pushdown',  'cable',      ARRAY['triceps'],
 ARRAY['cable machine'],
 'Lock elbows at sides. Push handle to full extension. Control return.'),

-- ── Bodyweight ────────────────────────────────────────────────────────────────
(gen_random_uuid(), NULL, 'Pull-up',                'bodyweight', ARRAY['lats','biceps','rear delts'],
 ARRAY['pull-up bar'],
 'Hang with shoulder-width grip. Pull chest to bar, then lower fully.'),

(gen_random_uuid(), NULL, 'Dip',                   'bodyweight', ARRAY['chest','triceps','front delts'],
 ARRAY['parallel bars'],
 'Lower until elbows reach 90°. Press back to lockout.'),

(gen_random_uuid(), NULL, 'Push-up',               'bodyweight', ARRAY['chest','triceps','front delts','core'],
 ARRAY[],
 'Plank position. Lower chest to floor, keeping elbows ~45°. Press back up.'),

(gen_random_uuid(), NULL, 'Plank',                 'bodyweight', ARRAY['core','shoulders','glutes'],
 ARRAY[],
 'Forearms on floor, body straight. Hold position without letting hips sag.'),

-- ── Machine ───────────────────────────────────────────────────────────────────
(gen_random_uuid(), NULL, 'Leg Press',             'machine',    ARRAY['quads','glutes','hamstrings'],
 ARRAY['leg press machine'],
 'Feet shoulder-width on plate. Lower until 90° knee angle. Press to near lockout.'),

(gen_random_uuid(), NULL, 'Leg Curl',              'machine',    ARRAY['hamstrings'],
 ARRAY['leg curl machine'],
 'Curl lower legs toward glutes. Hold briefly at top. Lower with control.'),

-- ── Cardio ────────────────────────────────────────────────────────────────────
(gen_random_uuid(), NULL, 'Treadmill Run',         'cardio',     ARRAY['quads','calves','cardiovascular'],
 ARRAY['treadmill'],
 'Set speed and incline to target effort. Maintain upright posture.'),

(gen_random_uuid(), NULL, 'Rowing Machine',        'cardio',     ARRAY['back','legs','cardiovascular'],
 ARRAY['rowing machine'],
 'Drive with legs first, then lean back, then pull handle to lower ribcage. Reverse to return.'),

-- ── Stretch / Mobility ────────────────────────────────────────────────────────
(gen_random_uuid(), NULL, 'Hip Flexor Stretch',   'stretch',    ARRAY['hip flexors','quads'],
 ARRAY[],
 'Kneeling lunge position. Push hips forward gently until stretch is felt in front hip.'),

(gen_random_uuid(), NULL, 'Hamstring Stretch',    'stretch',    ARRAY['hamstrings'],
 ARRAY[],
 'Seated or standing, extend one leg and reach toward foot. Hold 30+ seconds.');
