# L3velUp — Product Specification

## 1. Product Overview

L3velUp is a white-label gym member engagement platform sold as a SaaS product to gyms. Each gym gets a branded instance where their members log workouts, follow training programs, earn XP and achievements, customize a 2D avatar, and compete on fair leaderboards scoped to their gym.

**Core value propositions:**
- Retention through gamification (XP, levels, streaks, achievements)
- Fair competition through goal/age/experience-matched leaderboards
- Personalization through avatar customization
- Operational insight for gym operators via admin dashboard

---

## 2. Monorepo Structure

```
L3velUp/
├── apps/
│   ├── mobile/                     # Expo React Native (TypeScript)
│   │   ├── src/
│   │   │   ├── app/                # Expo Router file-based routing
│   │   │   │   ├── (auth)/         # Unauthenticated screens
│   │   │   │   │   ├── welcome.tsx
│   │   │   │   │   ├── login.tsx
│   │   │   │   │   ├── register.tsx
│   │   │   │   │   └── join-gym.tsx
│   │   │   │   ├── (onboarding)/   # First-run flow
│   │   │   │   │   ├── goal.tsx
│   │   │   │   │   ├── experience.tsx
│   │   │   │   │   └── avatar-setup.tsx
│   │   │   │   └── (tabs)/         # Main app tabs
│   │   │   │       ├── index.tsx           # Home / Dashboard
│   │   │   │       ├── log/
│   │   │   │       │   ├── index.tsx       # Start workout
│   │   │   │       │   ├── active.tsx      # Live session
│   │   │   │       │   └── history.tsx     # Past workouts
│   │   │   │       ├── programs/
│   │   │   │       │   ├── index.tsx       # Browse programs
│   │   │   │       │   ├── [id].tsx        # Program detail
│   │   │   │       │   └── create.tsx      # Create program
│   │   │   │       ├── leaderboard/
│   │   │   │       │   ├── index.tsx       # Board selector
│   │   │   │       │   └── [type].tsx      # Board view
│   │   │   │       └── profile/
│   │   │   │           ├── index.tsx       # Own profile
│   │   │   │           ├── avatar.tsx      # Avatar editor
│   │   │   │           └── achievements.tsx
│   │   │   ├── components/
│   │   │   │   ├── avatar/         # 2D layered avatar renderer
│   │   │   │   ├── workout/        # Workout logging widgets
│   │   │   │   ├── leaderboard/    # Leaderboard cards
│   │   │   │   └── ui/             # Generic primitives
│   │   │   ├── hooks/
│   │   │   ├── stores/             # Zustand state stores
│   │   │   ├── services/           # Supabase query wrappers
│   │   │   └── constants/
│   │   ├── assets/
│   │   │   └── avatar/             # Layered 2D PNG/SVG assets
│   │   │       ├── body/
│   │   │       ├── hair/
│   │   │       ├── face/
│   │   │       ├── top/
│   │   │       ├── bottom/
│   │   │       ├── shoes/
│   │   │       ├── accessories/
│   │   │       └── backgrounds/
│   │   ├── app.json
│   │   ├── babel.config.js
│   │   └── package.json
│   │
│   └── admin/                      # Next.js 14 App Router (TypeScript)
│       ├── src/
│       │   ├── app/
│       │   │   ├── (auth)/
│       │   │   │   └── login/
│       │   │   └── (dashboard)/
│       │   │       ├── layout.tsx
│       │   │       ├── page.tsx                    # Overview
│       │   │       ├── members/
│       │   │       │   ├── page.tsx                # Member list
│       │   │       │   └── [id]/page.tsx           # Member detail
│       │   │       ├── programs/
│       │   │       │   ├── page.tsx
│       │   │       │   └── [id]/page.tsx
│       │   │       ├── leaderboards/
│       │   │       │   └── page.tsx
│       │   │       ├── exercises/
│       │   │       │   └── page.tsx                # Gym exercise library
│       │   │       └── settings/
│       │   │           ├── page.tsx                # Gym profile & branding
│       │   │           └── staff/page.tsx
│       │   ├── components/
│       │   │   ├── ui/             # shadcn/ui components
│       │   │   └── gym/            # Domain-specific components
│       │   ├── lib/
│       │   │   ├── supabase/
│       │   │   └── utils/
│       │   └── hooks/
│       ├── next.config.ts
│       ├── tailwind.config.ts
│       └── package.json
│
├── packages/
│   ├── shared/                     # Shared TS types, Zod schemas, utilities
│   │   ├── src/
│   │   │   ├── types/              # All domain TypeScript interfaces
│   │   │   │   ├── gym.ts
│   │   │   │   ├── user.ts
│   │   │   │   ├── workout.ts
│   │   │   │   ├── program.ts
│   │   │   │   ├── exercise.ts
│   │   │   │   ├── achievement.ts
│   │   │   │   ├── avatar.ts
│   │   │   │   └── leaderboard.ts
│   │   │   ├── schemas/            # Zod validation schemas
│   │   │   │   ├── workout.schema.ts
│   │   │   │   ├── program.schema.ts
│   │   │   │   └── user.schema.ts
│   │   │   ├── scoring/            # XP, level, leaderboard scoring logic
│   │   │   │   ├── xp.ts
│   │   │   │   ├── levels.ts
│   │   │   │   ├── leaderboard.ts
│   │   │   │   └── consistency.ts
│   │   │   ├── constants/
│   │   │   │   ├── goals.ts
│   │   │   │   ├── age-bands.ts
│   │   │   │   └── experience-levels.ts
│   │   │   └── index.ts
│   │   └── package.json
│   │
│   └── database/                   # Supabase type generation & migrations
│       ├── src/
│       │   └── database.types.ts   # Auto-generated from Supabase
│       └── package.json
│
├── supabase/
│   ├── config.toml
│   ├── migrations/
│   │   ├── 00001_init_gyms.sql
│   │   ├── 00002_init_users.sql
│   │   ├── 00003_init_exercises.sql
│   │   ├── 00004_init_workouts.sql
│   │   ├── 00005_init_programs.sql
│   │   ├── 00006_init_gamification.sql
│   │   ├── 00007_init_leaderboards.sql
│   │   ├── 00008_rls_policies.sql
│   │   └── 00009_functions.sql
│   ├── seed/
│   │   ├── 01_exercises.sql
│   │   ├── 02_achievements.sql
│   │   └── 03_demo_gym.sql
│   └── functions/                  # Supabase Edge Functions
│       ├── compute-leaderboard/
│       ├── award-xp/
│       └── check-achievements/
│
├── docs/
│   ├── product-spec.md             # This file
│   ├── build-roadmap.md
│   └── privacy-model.md
│
├── turbo.json
├── pnpm-workspace.yaml
└── package.json
```

---

## 3. Architecture Decisions

### 3.1 Backend: Supabase

- **Auth:** Supabase Auth with email/password. Magic link as alternative. Gym owners can invite members via email; invitation creates a pending membership record and sends a magic link.
- **Database:** Postgres with Row Level Security (RLS) enforced on every table. No table is publicly readable without an explicit policy.
- **Storage:** Supabase Storage for gym logos, user-uploaded assets. Avatar layer assets are static files bundled with the mobile app (not user-uploaded) to ensure visual consistency and avoid moderation complexity.
- **Edge Functions:** Used for XP award, achievement checking, and leaderboard computation to keep scoring logic server-authoritative and prevent client-side manipulation.
- **Realtime:** Supabase Realtime for live leaderboard updates (optional, Phase 2).

### 3.2 Multi-tenancy

Gyms are the top-level tenant. Every domain table includes a `gym_id` foreign key. RLS policies enforce that users can only read and write data belonging to their own gym. A Postgres function `current_gym_id()` reads the JWT claim `gym_id` set at login to make RLS policies concise and reliable.

### 3.3 Scoring: Server-Authoritative

XP events, level calculations, and leaderboard scores are computed in Supabase Edge Functions, not by the client. The client submits workout data; the server validates and awards XP via database triggers and/or Edge Functions. This prevents manipulation.

### 3.4 Avatar System

The avatar is a composited stack of 2D layered PNG assets rendered client-side. Each layer slot has a set of options with defined z-indices. The selected option per slot is stored as a JSON config in the user's profile. No image compositing happens server-side in MVP — the client renders layers using absolute positioning. Assets are shipped with the app bundle in the MVP; in future phases, gym-branded or premium asset packs can be added via Supabase Storage.

Layer slots (render order, bottom to top):

| Order | Slot Key       | Description                              |
|-------|----------------|------------------------------------------|
| 0     | `background`   | Scene background (gym, outdoor, etc.)    |
| 1     | `body`         | Body shape/silhouette                    |
| 2     | `skin`         | Skin color overlay                       |
| 3     | `bottom`       | Pants, shorts, leggings                  |
| 4     | `shoes`        | Footwear                                 |
| 5     | `top`          | Shirt, tank top, hoodie                  |
| 6     | `hair_back`    | Back hair layer                          |
| 7     | `face`         | Eyes, expression                         |
| 8     | `hair_front`   | Front hair / bangs                       |
| 9     | `accessory`    | Hat, headband, glasses, earrings         |
| 10    | `equipment`    | Held item: dumbbell, bottle, band        |

### 3.4 Leaderboard Fairness

Three separate leaderboard types ensure members compete fairly:

1. **Progress Board** — percentage improvement in primary metrics vs. the member's own baseline (goal-specific metric selection).
2. **Consistency Board** — workout adherence score relative to their self-declared schedule commitment.
3. **Performance Board** — absolute XP earned in a rolling period, filtered by matching goal, age band, and experience level.

Leaderboards are pre-computed by a scheduled Edge Function (nightly or triggered on workout log) and cached in a `leaderboard_snapshots` table to keep reads fast.

### 3.5 White-Label Theming

Each gym record stores a `theme_config` JSONB column containing primary color, logo URL, and app name. The mobile app fetches this on first load and caches it. The admin panel uses these values to skin the gym's member-facing experience.

---

## 4. Data Models

### 4.1 `gyms`

```sql
CREATE TABLE gyms (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name          TEXT NOT NULL,
  slug          TEXT NOT NULL UNIQUE,        -- used in deep links
  logo_url      TEXT,
  theme_config  JSONB NOT NULL DEFAULT '{}'::jsonb,
  -- theme_config shape: { primaryColor, accentColor, appName, logoUrl }
  subscription_tier TEXT NOT NULL DEFAULT 'starter',
  owner_id      UUID REFERENCES auth.users(id),
  is_active     BOOLEAN NOT NULL DEFAULT true,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

### 4.2 `profiles`

Extends `auth.users`. One profile per user, always linked to one gym (MVP; multi-gym support is a future feature).

```sql
CREATE TABLE profiles (
  id                UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  gym_id            UUID NOT NULL REFERENCES gyms(id),
  role              TEXT NOT NULL CHECK (role IN ('gym_owner', 'gym_staff', 'member')),
  display_name      TEXT NOT NULL,
  avatar_config     JSONB NOT NULL DEFAULT '{}'::jsonb,
  -- avatar_config shape: { background, body, skin, bottom, shoes, top, hair_back,
  --                         face, hair_front, accessory, equipment }
  -- each value is a string asset key, e.g. "hair_front/curly_01"
  goal              TEXT CHECK (goal IN (
                      'strength','muscle_gain','fat_loss','fitness',
                      'cardio','power','mobility','general_health'
                    )),
  age_band          TEXT CHECK (age_band IN ('16-24','25-34','35-44','45-54','55+')),
  experience_level  TEXT CHECK (experience_level IN ('beginner','intermediate','advanced')),
  -- beginner: <6mo consistent training
  -- intermediate: 6-24mo
  -- advanced: 24mo+
  xp_total          INTEGER NOT NULL DEFAULT 0,
  xp_level          INTEGER NOT NULL DEFAULT 1,
  streak_current    INTEGER NOT NULL DEFAULT 0,
  streak_best       INTEGER NOT NULL DEFAULT 0,
  last_workout_date DATE,
  leaderboard_privacy TEXT NOT NULL DEFAULT 'gym_visible'
                    CHECK (leaderboard_privacy IN ('public','gym_visible','anonymous','private')),
  onboarding_complete BOOLEAN NOT NULL DEFAULT false,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

### 4.3 `exercises`

Global seed exercises plus gym-specific custom exercises.

```sql
CREATE TABLE exercises (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  gym_id        UUID REFERENCES gyms(id),   -- NULL = global exercise
  name          TEXT NOT NULL,
  category      TEXT NOT NULL CHECK (category IN (
                  'barbell','dumbbell','machine','cable','bodyweight',
                  'cardio','stretch','other'
                )),
  muscle_groups TEXT[] NOT NULL DEFAULT '{}',
  equipment     TEXT[] NOT NULL DEFAULT '{}',
  instructions  TEXT,
  video_url     TEXT,
  is_archived   BOOLEAN NOT NULL DEFAULT false,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

### 4.4 `workout_sessions`

A logged workout session (one per visit to the gym).

```sql
CREATE TABLE workout_sessions (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES profiles(id),
  gym_id          UUID NOT NULL REFERENCES gyms(id),
  program_id      UUID REFERENCES programs(id),
  program_day_id  UUID REFERENCES program_days(id),
  title           TEXT,
  notes           TEXT,
  started_at      TIMESTAMPTZ NOT NULL,
  ended_at        TIMESTAMPTZ,
  duration_seconds INTEGER,                  -- computed on end
  xp_earned       INTEGER NOT NULL DEFAULT 0,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

### 4.5 `workout_sets`

Individual sets within a session.

```sql
CREATE TABLE workout_sets (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id        UUID NOT NULL REFERENCES workout_sessions(id) ON DELETE CASCADE,
  exercise_id       UUID NOT NULL REFERENCES exercises(id),
  set_number        SMALLINT NOT NULL,
  reps              SMALLINT,
  weight_kg         NUMERIC(6,2),
  duration_seconds  INTEGER,                 -- for time-based sets
  distance_meters   NUMERIC(8,2),            -- for cardio
  rpe               SMALLINT CHECK (rpe BETWEEN 1 AND 10),
  is_personal_record BOOLEAN NOT NULL DEFAULT false,
  completed_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

### 4.6 `programs`

Template-based training programs. Can be gym-created templates or member-created.

```sql
CREATE TABLE programs (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  gym_id          UUID NOT NULL REFERENCES gyms(id),
  creator_id      UUID REFERENCES profiles(id),
  name            TEXT NOT NULL,
  description     TEXT,
  goal            TEXT CHECK (goal IN (
                    'strength','muscle_gain','fat_loss','fitness',
                    'cardio','power','mobility','general_health'
                  )),
  difficulty      TEXT CHECK (difficulty IN ('beginner','intermediate','advanced')),
  duration_weeks  SMALLINT NOT NULL DEFAULT 4,
  is_public       BOOLEAN NOT NULL DEFAULT false,  -- visible to all gym members
  is_gym_template BOOLEAN NOT NULL DEFAULT false,  -- pinned by gym staff
  is_archived     BOOLEAN NOT NULL DEFAULT false,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

### 4.7 `program_weeks` / `program_days` / `program_exercises`

```sql
CREATE TABLE program_weeks (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  program_id  UUID NOT NULL REFERENCES programs(id) ON DELETE CASCADE,
  week_number SMALLINT NOT NULL,
  UNIQUE (program_id, week_number)
);

CREATE TABLE program_days (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  week_id     UUID NOT NULL REFERENCES program_weeks(id) ON DELETE CASCADE,
  day_number  SMALLINT NOT NULL,   -- 1-7
  name        TEXT,                -- e.g. "Push Day", "Rest"
  UNIQUE (week_id, day_number)
);

CREATE TABLE program_exercises (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  day_id        UUID NOT NULL REFERENCES program_days(id) ON DELETE CASCADE,
  exercise_id   UUID NOT NULL REFERENCES exercises(id),
  order_index   SMALLINT NOT NULL,
  target_sets   SMALLINT,
  target_reps   TEXT,              -- e.g. "8-12" or "AMRAP"
  target_weight TEXT,              -- e.g. "70% 1RM" or notes
  rest_seconds  SMALLINT,
  notes         TEXT
);
```

### 4.8 `member_programs`

Tracks which member is enrolled in which program and progress.

```sql
CREATE TABLE member_programs (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES profiles(id),
  program_id      UUID NOT NULL REFERENCES programs(id),
  started_at      DATE NOT NULL DEFAULT CURRENT_DATE,
  current_week    SMALLINT NOT NULL DEFAULT 1,
  current_day     SMALLINT NOT NULL DEFAULT 1,
  completed_at    DATE,
  is_active       BOOLEAN NOT NULL DEFAULT true,
  UNIQUE (user_id, program_id, started_at)
);
```

### 4.9 `xp_events`

Append-only audit log of every XP award. Source of truth for the `xp_total` column.

```sql
CREATE TABLE xp_events (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES profiles(id),
  gym_id      UUID NOT NULL REFERENCES gyms(id),
  event_type  TEXT NOT NULL CHECK (event_type IN (
                'workout_complete','streak_bonus','personal_record',
                'program_day_complete','program_complete',
                'achievement_earned','first_workout','profile_complete'
              )),
  xp_amount   INTEGER NOT NULL,
  metadata    JSONB,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

### 4.10 `achievements`

Seeded globally; gym-specific achievements possible in future.

```sql
CREATE TABLE achievements (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name            TEXT NOT NULL,
  description     TEXT NOT NULL,
  icon_key        TEXT NOT NULL,         -- asset reference
  category        TEXT NOT NULL CHECK (category IN (
                    'streak','volume','milestone','social','special'
                  )),
  criteria_type   TEXT NOT NULL,         -- e.g. 'streak_days', 'workouts_count', 'xp_total'
  criteria_value  INTEGER NOT NULL,
  xp_reward       INTEGER NOT NULL DEFAULT 0,
  is_hidden       BOOLEAN NOT NULL DEFAULT false,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

### 4.11 `member_achievements`

```sql
CREATE TABLE member_achievements (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES profiles(id),
  achievement_id  UUID NOT NULL REFERENCES achievements(id),
  earned_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, achievement_id)
);
```

### 4.12 `gym_invitations`

```sql
CREATE TABLE gym_invitations (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  gym_id      UUID NOT NULL REFERENCES gyms(id),
  email       TEXT NOT NULL,
  role        TEXT NOT NULL DEFAULT 'member' CHECK (role IN ('gym_staff','member')),
  token       TEXT NOT NULL UNIQUE,
  invited_by  UUID REFERENCES profiles(id),
  accepted_at TIMESTAMPTZ,
  expires_at  TIMESTAMPTZ NOT NULL DEFAULT (now() + INTERVAL '7 days'),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

### 4.13 `leaderboard_snapshots`

Pre-computed, cached leaderboard data. Rebuilt by Edge Function on schedule.

```sql
CREATE TABLE leaderboard_snapshots (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  gym_id          UUID NOT NULL REFERENCES gyms(id),
  board_type      TEXT NOT NULL CHECK (board_type IN ('progress','consistency','performance')),
  scope           TEXT NOT NULL DEFAULT 'gym',    -- 'gym' in MVP; future: 'city','country'
  goal_filter     TEXT,                           -- NULL = all goals
  age_band_filter TEXT,                           -- NULL = all age bands
  exp_filter      TEXT,                           -- NULL = all experience levels
  period          TEXT NOT NULL CHECK (period IN ('weekly','monthly','all_time')),
  entries         JSONB NOT NULL DEFAULT '[]',
  -- entries: Array<{ rank, user_id, display_name, avatar_config, score,
  --                   delta, privacy_mode }>
  computed_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (gym_id, board_type, scope, goal_filter, age_band_filter, exp_filter, period)
);
```

### 4.14 `baseline_metrics`

Stored at onboarding to compute progress delta for leaderboards.

```sql
CREATE TABLE baseline_metrics (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID NOT NULL REFERENCES profiles(id) UNIQUE,
  recorded_at   DATE NOT NULL DEFAULT CURRENT_DATE,
  body_weight_kg NUMERIC(5,2),
  -- Goal-specific primary metrics:
  bench_1rm_kg  NUMERIC(5,2),
  squat_1rm_kg  NUMERIC(5,2),
  deadlift_1rm_kg NUMERIC(5,2),
  run_5k_seconds INTEGER,
  pushups_max   SMALLINT,
  -- Extensible via JSONB for future metrics:
  extra_metrics JSONB DEFAULT '{}'::jsonb
);
```

---

## 5. User Roles & Permissions

### 5.1 Role Hierarchy

| Role | Scope | Description |
|------|-------|-------------|
| `platform_admin` | Global | L3velUp team. Manages gyms, subscriptions. Not in Supabase Auth JWT claim — handled via separate admin portal or direct DB access. |
| `gym_owner` | Gym | Full control over one gym: settings, staff, members, programs, branding. |
| `gym_staff` | Gym | Can manage members, programs, exercises. Cannot change gym settings or billing. |
| `member` | Gym | Full member experience. Data access limited to own records + leaderboard display names of others. |

### 5.2 Permission Matrix

| Action | gym_owner | gym_staff | member |
|--------|-----------|-----------|--------|
| View/edit gym settings | ✓ | ✗ | ✗ |
| Manage gym branding | ✓ | ✗ | ✗ |
| Invite staff | ✓ | ✗ | ✗ |
| Invite members | ✓ | ✓ | ✗ |
| View member list | ✓ | ✓ | ✗ |
| View member workout history | ✓ | ✓ | ✗ |
| Create gym template programs | ✓ | ✓ | ✗ |
| Create personal programs | ✓ | ✓ | ✓ |
| Log own workouts | ✓ | ✓ | ✓ |
| View own workouts | ✓ | ✓ | ✓ |
| View leaderboard | ✓ | ✓ | ✓ |
| Customize own avatar | ✓ | ✓ | ✓ |
| Manage exercise library | ✓ | ✓ | ✗ |

### 5.3 RLS Policy Summary

All RLS policies use a helper function:

```sql
CREATE OR REPLACE FUNCTION current_user_gym_id()
RETURNS UUID LANGUAGE sql STABLE AS $$
  SELECT (auth.jwt() -> 'app_metadata' ->> 'gym_id')::UUID
$$;

CREATE OR REPLACE FUNCTION current_user_role()
RETURNS TEXT LANGUAGE sql STABLE AS $$
  SELECT auth.jwt() -> 'app_metadata' ->> 'role'
$$;
```

Key policies:
- `profiles`: SELECT allowed where `gym_id = current_user_gym_id()`. UPDATE allowed only on own row. Staff/owner can SELECT all profiles in their gym.
- `workout_sessions`: SELECT/INSERT/UPDATE only where `user_id = auth.uid()`. Staff/owner SELECT all within their gym.
- `programs`: SELECT where `gym_id = current_user_gym_id()` AND (`is_public = true` OR `creator_id = auth.uid()` OR role is staff/owner).
- `leaderboard_snapshots`: SELECT where `gym_id = current_user_gym_id()`.
- `xp_events`: INSERT only via Edge Function (service role). SELECT only own records.
- `gyms`: SELECT where `id = current_user_gym_id()`. UPDATE where `owner_id = auth.uid()`.

---

## 6. XP & Level System

### 6.1 XP Event Values

| Event | XP | Conditions |
|-------|----|------------|
| Workout complete | 50 | Session ≥ 15 minutes |
| Streak continuation | +10 per day | Applied on workout complete |
| Personal record | 25 | Per PR set in session |
| Program day complete | 15 | Extra, stacks with workout_complete |
| Program complete | 200 | On finishing all weeks |
| Achievement earned | Varies | Set per achievement |
| Profile complete | 50 | One-time, all fields filled |
| First workout | 100 | One-time |

### 6.2 Level Curve

Level thresholds follow an exponential curve: `xp_for_level(n) = 100 * n^1.8`.

| Level | XP Needed | Cumulative XP |
|-------|-----------|---------------|
| 1 | 0 | 0 |
| 2 | 100 | 100 |
| 3 | 245 | 345 |
| 5 | 691 | 1,554 |
| 10 | 2,512 | 9,745 |
| 20 | 8,932 | 63,280 |

This logic lives in `packages/shared/src/scoring/levels.ts` and is mirrored in the Edge Function.

### 6.3 Streak Rules

- A streak increments when a member logs a workout on a new calendar day (gym timezone).
- A streak breaks if a member goes 48 hours without logging (one rest day allowed).
- Streak freeze mechanic is a future feature.

---

## 7. Leaderboard Scoring Logic

### 7.1 Progress Board Score

Measures improvement from baseline. Score = weighted average of % improvements in the member's goal-specific primary metrics.

Goal-to-primary-metric mapping:
- `strength`, `power`: bench_1rm, squat_1rm, deadlift_1rm (max of best recent set × Epley formula)
- `muscle_gain`: volume load (sets × reps × weight) for primary compound lifts, 4-week trailing average
- `fat_loss`, `general_health`: body weight delta (% toward goal) + consistency score
- `cardio`, `fitness`: run pace or cardio volume
- `mobility`: workout frequency in mobility category

Score capped at 100. Negative progress results in score of 0 (not penalized publicly).

### 7.2 Consistency Board Score

`consistency_score = (workouts_logged / committed_sessions) × 100`

Where `committed_sessions` = member's self-declared sessions per week × weeks since joining (or since last reset).

Capped at 100. A 7-day rolling window for weekly view.

### 7.3 Performance Board Score

Raw XP earned in the period, normalized to level (so a level 2 member earning 500 XP is comparable to a level 10 member earning 500 XP — both show 500). Filtered by matching goal/age band/experience level when enough members qualify (minimum 5 per filter group; falls back to broader filter if fewer).

---

## 8. Mobile App Screens

### 8.1 Auth / Onboarding Flow

| Screen | Purpose |
|--------|---------|
| Welcome | App intro, CTA to join gym or log in |
| Login | Email/password + magic link |
| Register | Name, email, password |
| Join Gym | Enter gym code or QR scan; or accept invitation link |
| Goal Selection | 8 goal cards with descriptions |
| Experience Level | 3 options with descriptions |
| Age Band | Picker |
| Avatar Setup (basic) | Pick body, skin, and one clothing set |
| Baseline Metrics (optional) | Capture starting metrics for progress board |

### 8.2 Main Tab Navigation

| Tab | Icon | Primary Content |
|-----|------|----------------|
| Home | Dashboard | Daily summary: streak, XP progress bar, today's program day, recent achievements, quick-log CTA |
| Log | Dumbbell | Start workout: blank or from program; exercise search/add |
| Programs | Calendar | Browse gym templates + own programs; enroll/start |
| Leaderboard | Trophy | Board type selector; filtered ranking list |
| Profile | Avatar | XP/level, stats, achievements gallery, avatar editor link |

### 8.3 Workout Logging Flow

1. **Start Screen** — choose "Blank Workout" or "From Program" (shows today's program day if enrolled).
2. **Active Session** — timer running, exercise list, add set (reps/weight or time/distance), RPE picker, rest timer, PR indicator.
3. **Finish Screen** — summary: duration, sets, volume, XP earned, achievements unlocked. Option to add notes.
4. **Workout History** — calendar view + list; tap to see session detail.

### 8.4 Leaderboard Screen

- Board type tabs: Progress | Consistency | Performance
- Filter chips: Goal (matches own by default), Period (weekly/monthly/all-time)
- Ranked list: position, avatar, display name (or "Athlete #N" if anonymous), score, delta arrow
- Own entry always visible (highlighted) even if outside top 20
- Minimum 5 members required to display any board; otherwise shows "Not enough members yet"

### 8.5 Avatar Editor

- Full-screen canvas showing current character
- Scrollable layer selector at bottom (tabs per slot)
- Tapping an asset previews it live
- Save button updates `avatar_config` in profile
- Locked assets shown greyed with a level requirement badge

---

## 9. Admin Panel Screens

### 9.1 Dashboard

- Member count, active this week, new this month
- Top 5 members by XP this month
- Recent workout sessions feed
- Leaderboard snapshot preview

### 9.2 Members

- Sortable/searchable table: name, goal, level, XP, streak, last active, status
- Member detail: profile info, workout history (list), achievement list, XP event log
- Actions: Invite member, Deactivate account

### 9.3 Programs

- Program library (gym templates + member-public programs)
- Create/edit program: week/day builder with exercise search
- Mark as gym template (pins to top for members)

### 9.4 Exercise Library

- Table of global exercises + gym-specific custom exercises
- Add custom exercise: name, category, muscle groups, instructions, optional video URL
- Archive exercises (soft delete)

### 9.5 Leaderboards

- View all three board types with the same filter controls as mobile
- Identify top performers for manual staff recognition
- Board status indicator (active / too few members)

### 9.6 Settings

- **Gym Profile:** Name, slug, logo upload, contact info
- **Branding:** Primary color picker, accent color, custom app name
- **Staff:** Invite staff, manage roles, revoke access
- **Invite Links:** Generate join codes / QR codes for member onboarding

---

## 10. Future-Ready Structure (Not MVP)

The following are explicitly excluded from MVP but the data model and architecture accommodate them without breaking changes:

- **City/Country Leaderboards:** The `scope` column on `leaderboard_snapshots` already has values `'city'` and `'country'` reserved. The `profiles` table would add `city` and `country` columns populated from gym location. The scoring logic in `packages/shared/src/scoring/leaderboard.ts` is scope-agnostic.
- **Clans/Teams:** A `clans` table with `gym_id`, membership, and team scores can be added. Nothing in the current schema conflicts.
- **Challenges:** A `challenges` table with time-boxed goals and participant tracking.
- **Premium Avatar Packs:** Asset keys are strings (`"hair_front/curly_01"`), making storage-backed packs a non-breaking addition.
- **Multi-Gym Membership:** The `profiles` table has one `gym_id` today. Multi-gym would require a `member_gym_memberships` junction table and adjustments to RLS.
