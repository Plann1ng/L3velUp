-- =============================================================================
-- Seed 03: Avatar asset catalogue
-- asset_key format: "{slot}/{variant_id}" — maps to a bundled PNG in mobile.
-- level_required: minimum profile.xp_level to unlock the asset.
-- =============================================================================

INSERT INTO avatar_assets (asset_key, slot, label, level_required, is_premium) VALUES

-- ── Backgrounds ──────────────────────────────────────────────────────────────
('background/gym_01',     'background', 'Iron Gym',        1, false),
('background/gym_02',     'background', 'CrossFit Box',    3, false),
('background/outdoor_01', 'background', 'Track & Field',   5, false),
('background/city_01',    'background', 'City Rooftop',   10, false),
('background/mountains',  'background', 'Mountain Summit', 20, false),

-- ── Body shapes ───────────────────────────────────────────────────────────────
('body/athletic_01', 'body', 'Athletic',      1, false),
('body/stocky_01',   'body', 'Stocky',        1, false),
('body/lean_01',     'body', 'Lean',          1, false),
('body/powerlifter', 'body', 'Powerlifter',  15, false),

-- ── Skin tones ────────────────────────────────────────────────────────────────
('skin/tone_01', 'skin', 'Porcelain', 1, false),
('skin/tone_02', 'skin', 'Ivory',     1, false),
('skin/tone_03', 'skin', 'Beige',     1, false),
('skin/tone_04', 'skin', 'Warm',      1, false),
('skin/tone_05', 'skin', 'Caramel',   1, false),
('skin/tone_06', 'skin', 'Brown',     1, false),
('skin/tone_07', 'skin', 'Dark',      1, false),
('skin/tone_08', 'skin', 'Ebony',     1, false),

-- ── Bottoms ───────────────────────────────────────────────────────────────────
('bottom/shorts_01',   'bottom', 'Basic Shorts',    1, false),
('bottom/shorts_02',   'bottom', 'Performance Shorts',3, false),
('bottom/leggings_01', 'bottom', 'Leggings',        2, false),
('bottom/sweatpants',  'bottom', 'Sweatpants',      4, false),
('bottom/compression', 'bottom', 'Compression Tights',8, false),
('bottom/shorts_elite','bottom', 'Elite Shorts',   15, false),

-- ── Shoes ─────────────────────────────────────────────────────────────────────
('shoes/trainers_01',  'shoes', 'White Trainers',   1, false),
('shoes/trainers_02',  'shoes', 'Black Trainers',   1, false),
('shoes/lifting_01',   'shoes', 'Lifting Shoes',    6, false),
('shoes/runners_01',   'shoes', 'Running Shoes',    4, false),
('shoes/barefoot',     'shoes', 'Bare Feet',        1, false),
('shoes/elite_kicks',  'shoes', 'Elite Kicks',     18, false),

-- ── Tops ──────────────────────────────────────────────────────────────────────
('top/tank_01',       'top', 'White Tank',         1, false),
('top/tank_02',       'top', 'Black Tank',         1, false),
('top/tshirt_01',     'top', 'Grey T-Shirt',       1, false),
('top/hoodie_01',     'top', 'Hoodie',             3, false),
('top/compression_01','top', 'Compression Shirt',  5, false),
('top/elite_jersey',  'top', 'Elite Jersey',      20, false),

-- ── Hair back ─────────────────────────────────────────────────────────────────
('hair_back/none',        'hair_back', 'No Back Hair', 1, false),
('hair_back/long_01',     'hair_back', 'Long Straight', 1, false),
('hair_back/ponytail_01', 'hair_back', 'Ponytail',      1, false),
('hair_back/braids',      'hair_back', 'Braids',        2, false),

-- ── Faces ─────────────────────────────────────────────────────────────────────
('face/neutral_01',  'face', 'Neutral',      1, false),
('face/smile_01',    'face', 'Happy',        1, false),
('face/focus_01',    'face', 'Focused',      1, false),
('face/intense_01',  'face', 'Intense',      5, false),
('face/glasses_01',  'face', 'Glasses',      3, false),
('face/sunglasses',  'face', 'Sunglasses',   8, false),

-- ── Hair front ────────────────────────────────────────────────────────────────
('hair_front/short_01',  'hair_front', 'Short Crop',    1, false),
('hair_front/medium_01', 'hair_front', 'Medium Wave',   1, false),
('hair_front/curly_01',  'hair_front', 'Curly Top',     1, false),
('hair_front/bun_01',    'hair_front', 'Top Bun',       1, false),
('hair_front/mohawk',    'hair_front', 'Mohawk',        7, false),
('hair_front/bald',      'hair_front', 'Bald',          1, false),

-- ── Accessories ───────────────────────────────────────────────────────────────
('accessory/none',        'accessory', 'None',           1, false),
('accessory/headband_01', 'accessory', 'Headband',       2, false),
('accessory/cap_01',      'accessory', 'Baseball Cap',   1, false),
('accessory/beanie',      'accessory', 'Beanie',         3, false),
('accessory/earrings_01', 'accessory', 'Earrings',       1, false),
('accessory/crown',       'accessory', 'Crown',         25, false),

-- ── Held equipment ────────────────────────────────────────────────────────────
('equipment/none',        'equipment', 'Nothing',        1, false),
('equipment/dumbbell_01', 'equipment', 'Dumbbell',       1, false),
('equipment/bottle_01',   'equipment', 'Water Bottle',   1, false),
('equipment/resistance_01','equipment','Resistance Band', 4, false),
('equipment/barbell_01',  'equipment', 'Barbell',        8, false),
('equipment/trophy',      'equipment', 'Trophy',        25, false);
