# L3velUp — Build Roadmap

## MVP Definition

The MVP delivers a fully working gym engagement experience for a **single gym** (white-label ready but tested with one tenant). It excludes city/country leaderboards, clans, challenges, and multi-gym membership. The MVP can be shipped to a beta gym partner for real use.

**MVP success criteria:**
- A gym owner can set up their gym, brand it, and invite members from the admin panel.
- Members can onboard, choose a goal, and log workouts from their phone.
- Members earn XP, progress through levels, and maintain streaks.
- Three leaderboard types are live and fair (filtered by goal/age/experience).
- Members can customize a 2D layered avatar.
- Admin can view member activity, manage programs, and see leaderboard standings.

---

## Milestone Overview

| Milestone | Name | Duration | Cumulative |
|-----------|------|----------|------------|
| M0 | Scaffolding & Infrastructure | 1.5 weeks | 1.5 weeks |
| M1 | Auth, Gym Setup & Onboarding | 2 weeks | 3.5 weeks |
| M2 | Exercise Library & Workout Logging | 2.5 weeks | 6 weeks |
| M3 | XP, Levels & Streaks | 1.5 weeks | 7.5 weeks |
| M4 | Achievements | 1 week | 8.5 weeks |
| M5 | Training Programs | 2.5 weeks | 11 weeks |
| M6 | Avatar System | 2 weeks | 13 weeks |
| M7 | Leaderboards | 2 weeks | 15 weeks |
| M8 | Admin Panel | 2.5 weeks | 17.5 weeks |
| M9 | Polish, QA & Beta Launch | 2 weeks | 19.5 weeks |

Total estimated: **~20 weeks** for a 1-2 engineer team.

---

## Milestone Detail

---

### M0 — Scaffolding & Infrastructure (1.5 weeks)

**Goal:** Working monorepo skeleton, CI, and Supabase project ready. No product features.

**Deliverables:**

1. **Monorepo setup**
   - pnpm workspaces + Turborepo
   - `apps/mobile` (Expo SDK 52+, TypeScript strict, Expo Router)
   - `apps/admin` (Next.js 14 App Router, TypeScript strict, Tailwind CSS, shadcn/ui)
   - `packages/shared` (TypeScript library, Zod, tsup build)
   - `packages/database` (Supabase type generation script)

2. **Supabase project**
   - Local dev via `supabase start`
   - All 9 migration files created and runnable: gyms, users, exercises, workouts, programs, gamification, leaderboards, RLS, functions
   - `supabase/seed/` with global exercises (~200 exercises seeded) and demo gym
   - Type generation script wired to `packages/database`

3. **CI pipeline** (GitHub Actions)
   - `pnpm lint` on all packages
   - `pnpm typecheck` on all packages
   - `supabase db push --dry-run` to validate migrations
   - `pnpm test` (Vitest for shared package)

4. **Shared package baseline**
   - All TypeScript types exported from `packages/shared`
   - All Zod schemas for workout, program, user
   - Scoring utility stubs (functions exist, body is placeholder)
   - Constants: goals array, age bands array, experience levels array

5. **Environment configuration**
   - `.env.example` for mobile (Supabase URL + anon key)
   - `.env.example` for admin (Supabase URL + anon key + service key)
   - Supabase client singleton in each app

**Done when:** `supabase db reset` runs cleanly, `pnpm build` passes all packages, a blank Expo app and a blank Next.js app both launch.

---

### M1 — Auth, Gym Setup & Onboarding (2 weeks)

**Goal:** A gym owner can configure their gym; a member can register, join the gym, and complete onboarding.

**Deliverables:**

**Admin (Next.js):**
- Login screen (Supabase Auth email/password)
- Gym settings page: name, slug, logo upload (Supabase Storage), theme color picker
- Staff invitation: send email invite, manage pending invites
- Member invitation: generate join code + email invite with magic link
- Gym branding applied to admin panel via CSS variables from `theme_config`

**Mobile (Expo):**
- Welcome / intro screen
- Login screen (email + password)
- Register screen (name, email, password)
- Join gym screen: enter 6-character gym code or scan QR code; resolves to `gym_id`; creates profile row
- Magic link flow: deep link handling (`l3velup://join?token=...`)
- Onboarding wizard (only shown once, `onboarding_complete = false`):
  - Step 1: Goal selection (8 illustrated cards)
  - Step 2: Experience level (3 options)
  - Step 3: Age band picker
  - Step 4: Basic avatar setup (body + skin only)
  - Step 5: Optional baseline metrics entry
  - Completion: awards "Profile Complete" XP, sets `onboarding_complete = true`
- Authenticated route guard (redirects based on onboarding state)

**Supabase:**
- JWT `app_metadata` enrichment: custom auth hook populates `gym_id` and `role` into JWT on sign-in
- RLS policies for `gyms`, `profiles`, `gym_invitations` live and tested
- `handle_new_user` trigger: creates `profiles` row on `auth.users` insert

**Done when:** Full flow works end-to-end: gym owner sets up gym in admin → creates invite code → member joins on mobile → completes onboarding → profile visible in admin.

---

### M2 — Exercise Library & Workout Logging (2.5 weeks)

**Goal:** Members can search exercises, log a workout session with sets, and view their history.

**Deliverables:**

**Mobile:**
- Exercise library browser: search by name, filter by category and muscle group
  - Global exercises + gym-specific exercises merged; gym custom shown with tag
- Start Workout screen: select "Blank" or "From Program" (stub for M5)
- Active Workout screen:
  - Running timer
  - Add exercise (opens exercise library, selectable)
  - Per-exercise: add sets with reps + weight OR duration + distance (auto-detect by exercise category)
  - RPE picker (1-10) per set
  - PR detection: compare vs previous best set for same exercise; show PR badge inline
  - Rest timer: configurable seconds, counts down after each set
  - Swipe-to-delete set
  - Reorder exercises (drag handle)
- Finish Workout screen:
  - Summary: duration, total sets, volume (kg), PRs set
  - Add title and notes (optional)
  - Confirm / discard
- Workout History screen: calendar heat-map + list of past sessions; tap → session detail

**Supabase:**
- `workout_sessions` and `workout_sets` tables and RLS verified
- `exercises` seeded (~200 global) with categories, muscle groups
- Query: `get_exercise_history(user_id, exercise_id)` — last 5 sessions for an exercise (used to show suggested weight)

**Shared Package:**
- Volume calculation utility (total sets × reps × weight)
- Epley 1RM formula: `weight × (1 + reps / 30)`
- `detectPR(newSet, history): boolean`

**Done when:** A member can log a full workout from scratch, see it in history, and the data is correctly in the database.

---

### M3 — XP, Levels & Streaks (1.5 weeks)

**Goal:** Every workout awards XP and potentially levels up the member. Streaks are tracked.

**Deliverables:**

**Supabase Edge Function: `award-xp`**
- Called after workout session is saved (Postgres trigger on `workout_sessions` insert)
- Calculates XP events: `workout_complete` (50 XP base), `streak_bonus` (+10 per streak day), `personal_record` (+25 per PR in session)
- Inserts into `xp_events`
- Updates `profiles.xp_total`, `xp_level` (using level curve from shared package compiled to deno-compatible module)
- Updates `profiles.streak_current`, `streak_best`, `last_workout_date`
- Returns awarded XP breakdown

**Postgres: `update_streak` function**
- Called by trigger; handles streak increment / break logic
- Uses gym's timezone setting (stored in `gyms.theme_config.timezone`)

**Mobile:**
- Home dashboard: XP progress bar (current level XP / next level XP), level badge, streak counter with flame icon
- Post-workout XP celebration screen (shown after finish): animated XP gain, level-up animation if applicable
- Level-up modal with new level display

**Shared Package:**
- `getLevel(xpTotal): number` — level from total XP
- `xpForLevel(level): number` — cumulative XP to reach a level
- `xpProgress(xpTotal): { level, currentXp, nextLevelXp, progress }` — for progress bar

**Done when:** Completing a workout awards correct XP, streaks increment, level-ups occur correctly, all reflected in home dashboard.

---

### M4 — Achievements (1 week)

**Goal:** Members earn achievements automatically. Achievement gallery visible on profile.

**Deliverables:**

**Seed data: 30 achievements**
- Streak: 3-day, 7-day, 14-day, 30-day, 100-day streak
- Volume: 10, 50, 100, 500 workouts logged
- Milestone: First workout, First PR, First program completed
- XP: Reach level 5, 10, 15, 20, 25
- Special: Early adopter (first 50 members of a gym), Perfect week (7/7 days), etc.

**Supabase Edge Function: `check-achievements`**
- Called after `award-xp` completes
- Queries current member stats: streak, workout count, xp level, program completions
- Compares against each achievement's `criteria_type` + `criteria_value`
- Inserts newly unlocked achievements into `member_achievements`
- Awards achievement XP via `award-xp` recursion guard (flag to skip achievement re-check)
- Returns newly unlocked achievements (displayed in post-workout screen)

**Mobile:**
- Post-workout screen: achievement unlock cards (shown above XP summary)
- Profile > Achievements tab: grid of earned (full color) and locked (greyed) achievements
- Achievement detail modal: name, description, earned date (or "Locked")

**Done when:** All 30 achievements unlock automatically at the right conditions, visible on profile.

---

### M5 — Training Programs (2.5 weeks)

**Goal:** Members can enroll in gym-provided programs and log workouts directly from program days. Staff can create program templates.

**Deliverables:**

**Admin (Next.js):**
- Programs list: all programs in the gym (templates + member-public)
- Create Program flow:
  - Basic info: name, description, goal, difficulty, duration (weeks), visibility
  - Week/day builder: drag-to-reorder days, add exercises per day, set target sets/reps/notes
  - Mark as gym template (pins to top for members)
- Edit Program (same UI as create, pre-populated)
- Archive Program

**Mobile:**
- Programs tab > Browse screen:
  - Two sections: "Gym Programs" (templates) and "Community" (member-public)
  - Card: program name, goal tag, difficulty, duration, enrolled count
  - Filter by goal, difficulty
- Program Detail screen: description, week-by-week exercise preview, "Start Program" CTA
- My Programs section: enrolled programs with current week/day progress
- "Start Today's Workout" shortcut: loads program day into active session with pre-filled exercises
- Program completion screen: celebration, XP award, option to re-enroll

**Supabase:**
- `programs`, `program_weeks`, `program_days`, `program_exercises`, `member_programs` tables and RLS verified
- `start_program(user_id, program_id)`: checks for existing active enrollment, creates `member_programs` row
- `advance_program_day(member_program_id)`: increments current day/week, marks complete when finished
- Trigger: on `workout_sessions` insert with `program_day_id`, calls `advance_program_day`

**Done when:** Admin creates a 4-week strength program → member sees it, enrolls, logs each day following the plan → program marks complete → XP awarded.

---

### M6 — Avatar System (2 weeks)

**Goal:** Members can fully customize their 2D layered character. Avatar renders consistently across the app.

**Deliverables:**

**Asset production (non-engineer):**
- Design and export layered PNG assets for each slot (see product-spec.md §3.4)
- Minimum viable asset counts: 4 bodies, 8 skin tones, 6 hair_back, 6 hair_front, 6 face expressions, 8 tops, 6 bottoms, 6 shoes, 8 accessories, 4 equipment, 6 backgrounds
- Naming convention: `{slot}/{variant_id}.png` — e.g., `hair_front/curly_01.png`
- All assets same canvas size (512×512) with transparent background
- Export @2x and @3x for Expo

**Mobile: Avatar Renderer Component (`packages/mobile/src/components/avatar/`)**
- `AvatarView`: accepts `AvatarConfig` prop; renders each layer as absolutely positioned `Image` stacked by z-index
- `AvatarThumbnail`: small variant (48px) for leaderboards and profile headers
- `AvatarEditor`: full-screen editor modal
  - Horizontal scroll of layer tabs at bottom
  - Grid of options for selected layer; tap to preview live
  - Skin tone picker uses color swatches (not asset images)
  - Save / Cancel actions; calls `updateAvatarConfig(config)` mutation
- Layer locking: `AVATAR_UNLOCK_LEVELS` constant in shared package maps asset key → required level; locked items show padlock overlay

**Mobile: Avatar in context**
- Profile header shows large avatar + level badge
- Leaderboard entries show `AvatarThumbnail`
- Post-workout completion screen shows avatar celebrating

**Shared Package:**
- `AvatarConfig` TypeScript type (all slots typed as string or null)
- `getDefaultAvatarConfig(): AvatarConfig` — safe starting config
- `AVATAR_UNLOCK_LEVELS: Record<string, number>` — asset → level requirement
- `isAssetUnlocked(assetKey, userLevel): boolean`

**Done when:** Member completes avatar setup, avatar renders correctly in profile, leaderboard, and post-workout screens. Lock system prevents under-level access.

---

### M7 — Leaderboards (2 weeks)

**Goal:** Three leaderboard types are live with fair filtering. Privacy modes respected.

**Deliverables:**

**Supabase Edge Function: `compute-leaderboard`**
- Scheduled via `pg_cron` (nightly + on-demand trigger after each workout)
- For each gym, computes all three board types × three periods (weekly, monthly, all_time)
- Progress board: pulls `baseline_metrics` + most recent equivalent metrics from `workout_sets`; computes % improvement
- Consistency board: pulls `workout_sessions` count in period vs. commitment
- Performance board: pulls `xp_events` sum in period
- Applies fair filters: loops over all combos of goal/age_band/experience_level with ≥5 qualifying members; also computes unfiltered "all goals" version
- Applies privacy: replaces display_name with "Athlete #N" for `anonymous` members; excludes `private` members entirely
- Upserts into `leaderboard_snapshots`

**Supabase:**
- `pg_cron` schedule: `0 2 * * *` (2am daily, gym timezone)
- Manual trigger: Postgres function `trigger_leaderboard_compute(gym_id)` callable from Edge Function

**Mobile:**
- Leaderboard tab with three sub-tabs: Progress | Consistency | Performance
- Period selector chip group: Weekly / Monthly / All Time
- Filter pills: "My Goal" (default), "All Goals"; "My Age Group" (default), "All Ages"; "My Level" (default), "All Levels"
- Ranked list card: rank number, avatar thumbnail, display name, score, delta (↑↓ vs last snapshot)
- "Fewer than 5 members qualify" empty state
- Own rank pinned at bottom if outside visible range
- Rank changes: show confetti animation on first view if rank improved since last session

**Done when:** Leaderboards update nightly, privacy modes are respected in API responses, all three boards display correctly on mobile with fair filtering.

---

### M8 — Admin Panel (2.5 weeks)

**Goal:** Gym owner and staff have a full operational view of their gym via the web admin.

**Deliverables:**

**Admin Dashboard (`/`):**
- Stat cards: total members, active this week (logged ≥1 workout), new this month, avg streak
- Bar chart: workouts per day (last 30 days) — Recharts
- Top 5 members by XP this month (with avatar thumbnail)
- Recent activity feed: last 20 workout sessions with member name, duration, XP

**Members (`/members`):**
- Sortable data table: avatar, name, goal tag, level badge, XP, streak, last active, status badge (active/inactive)
- Search by name
- Filter by goal, experience level
- Click row → Member Detail

**Member Detail (`/members/[id]`):**
- Profile header: avatar, name, level, XP bar, streak, goal
- Workout history: paginated list of sessions with date, duration, exercises count, XP
- Achievements: grid of earned achievements
- XP event log: audit trail of XP awards
- Actions: Deactivate account button (confirmation modal)

**Programs (`/programs`):**
- Program list with filters
- Full create/edit program builder (as per M5 admin deliverables)

**Exercise Library (`/exercises`):**
- Merged table: global + gym-specific exercises
- Add custom exercise form (inline drawer)
- Archive exercise action

**Leaderboards (`/leaderboards`):**
- Same three board types visible to staff
- Read-only view of current snapshot with filter controls

**Settings (`/settings`):**
- Gym profile form: name, slug (read-only after set), contact email
- Branding: logo upload (drag-and-drop to Supabase Storage), primary/accent color pickers, live preview panel showing how colors look
- Staff management: list of staff, invite new staff (email), revoke access
- Member join codes: display current code, regenerate button, download QR code

**Done when:** A gym owner can fully operate the gym via admin with no direct database access needed.

---

### M9 — Polish, QA & Beta Launch (2 weeks)

**Goal:** App is stable, performant, and ready for a real beta gym.

**Deliverables:**

**Testing:**
- Unit tests for all `packages/shared` scoring utilities (Vitest), target 90%+ coverage
- Integration tests for Edge Functions (Supabase test helpers)
- E2E smoke test: Playwright on admin (login → create program → invite member)
- Manual test matrix covering all user flows on iOS and Android (Expo Go + dev build)

**Performance:**
- Leaderboard queries benchmarked < 100ms from snapshot (index review)
- Workout session save < 500ms including XP award
- Avatar render < 16ms per frame (no layout recomputation on re-renders)
- `react-query` / `@tanstack/react-query` caching configured for all mobile data fetches
- Optimistic updates on set logging (immediate UI feedback)

**Observability:**
- Sentry integration: mobile (Expo Sentry SDK) and admin (Next.js Sentry)
- Custom error boundary on active workout screen (data must not be lost)
- Supabase Postgres slow query log enabled and reviewed

**Polish:**
- Haptic feedback on set completion, PR badge, level-up (Expo Haptics)
- Skeleton loaders on all list screens
- Pull-to-refresh on workout history and leaderboard
- Empty states on all screens (no workouts yet, no programs, leaderboard not ready)
- Accessibility: all interactive elements have accessibilityLabel, minimum 44pt touch targets

**Deployment:**
- Admin: Vercel production deploy with environment variables
- Mobile: Expo EAS Build for TestFlight (iOS) and Play Store internal track (Android)
- Supabase: production project with connection pooling enabled
- Production seed: global exercise library, 30 achievements

**Done when:** Beta gym is live on production with real members using it, no P0 bugs, Sentry shows <1% error rate.

---

## Phase 2 Roadmap (Post-MVP, Not Scoped)

These features are future-ready by data model but not built in MVP:

| Feature | Dependency |
|---------|-----------|
| City & country leaderboards | Location data on profiles + gym; aggregated scoring job |
| Clans / Teams | `clans` table, team scoring, team leaderboard board type |
| Challenges | `challenges` table, time-boxed participation, prize XP |
| Premium avatar packs | Supabase Storage for gym-branded or seasonal packs; unlock via level or purchase |
| In-app messaging / coach notes | Realtime messaging between staff and members |
| Gym analytics export | CSV/PDF export of member activity for gym management |
| Multi-gym membership | Junction table replacing single `gym_id` on profile |
| Native Apple/Google sign-in | Expo Auth Session additions |
| Wearable integration | Apple Health / Google Fit for auto-workout sync |
| Streak freeze | Consumable item purchased with streak-shield tokens |
