# L3velUp — Privacy Model

## 1. Principles

1. **Minimum necessary exposure.** Leaderboards show only a computed score and a display identity — never raw workout data, weight, body composition, or health metrics of another member.
2. **Member control.** Each member independently controls their leaderboard visibility. The default is `gym_visible`, not `public`.
3. **Gym-scoped isolation.** Member data is never visible to members of another gym, including for leaderboard comparisons. All queries are RLS-enforced at the database layer.
4. **Pseudonymity as a first-class option.** Members who do not want their name associated with their rank can appear as "Athlete #N" with only their avatar visible.
5. **Opting out fully is always possible.** A member can remove themselves from all leaderboards entirely without affecting their ability to log workouts and earn XP.
6. **Fairness through grouping, not exposure.** Fair comparison is achieved by filtering leaderboards to comparable peers (same goal, age band, experience level), not by sharing personal attributes between members.

---

## 2. Member Privacy Tiers

Each member sets a `leaderboard_privacy` value on their profile. This is configurable in Profile > Settings.

| Tier | Value | What is shown on leaderboard |
|------|-------|------------------------------|
| **Full** | `gym_visible` (default) | Display name + avatar |
| **Anonymous** | `anonymous` | "Athlete #N" + avatar |
| **Private** | `private` | Not included on any leaderboard |

There is also a `public` tier reserved for future city/country leaderboards. In MVP, `public` behaves identically to `gym_visible` since no cross-gym boards exist.

### 2.1 Tier Behavior Details

**`gym_visible` (default)**
- Display name and avatar shown to all members of the same gym.
- Score (computed metric) shown. Raw workout data not shown.
- Visible to gym staff and owner in admin panel.

**`anonymous`**
- Display name replaced server-side with "Athlete #N" in `leaderboard_snapshots.entries`.
- `N` is a stable opaque integer derived from a hash of `user_id + gym_id + period_start` — consistent within a period, changes between periods.
- Avatar is still shown (members chose their avatar; it does not reveal identity).
- Anonymous members are still ranked and counted toward leaderboard minimums.
- Even gym staff see "Athlete #N" in leaderboard views; only the admin-only Member Detail page (behind staff role check) reveals the link.

**`private`**
- Excluded from `leaderboard_snapshots.entries` entirely — not ranked, not counted in the minimum threshold check.
- Own rank card on mobile shows "You are not on this leaderboard (privacy: private)."
- No indication given to other members that the user exists.

### 2.2 Changing Privacy Tier

- Members can change their tier at any time in Profile > Settings.
- Change takes effect at next leaderboard snapshot computation (within 24 hours for nightly schedule; immediate if manual recompute is triggered).
- Downsizing privacy (e.g., `gym_visible` → `private`) is instant in the mobile app: own rank card hides immediately on client; snapshot cleans up on next compute.

---

## 3. What Leaderboards Show vs. What They Hide

### 3.1 Shown

| Field | Purpose |
|-------|---------|
| Rank position | Core leaderboard function |
| Display name (or "Athlete #N") | Identity, subject to privacy tier |
| Avatar | Visual identity, chosen by member |
| Score | Computed metric (%, adherence %, or XP) |
| Delta | Score change since last snapshot (↑3, ↓1) |
| Goal tag | Only on leaderboards filtered to a single goal |

### 3.2 Never Shown to Other Members

| Data | Reason |
|------|--------|
| Raw workout sets (reps, weight, time) | Health and performance data |
| Body weight or body composition | Sensitive health data |
| Baseline metrics | Used only for progress computation |
| Date of birth (only age band is stored) | PII reduction |
| Specific exercise history | Performance and injury sensitivity |
| Email address | Direct PII |
| Streak count | Only shown on own profile |
| XP total | Only shown on own profile; performance board uses period XP, not total |
| RPE values | Subjective effort, health indicator |

---

## 4. Fair Comparison & Sensitive Attributes

Leaderboards use goal, age band, and experience level to group comparable members. These attributes are voluntarily self-reported during onboarding.

### 4.1 Attribute Storage

- **Goal:** Plain text enum. Not sensitive. Visible in your own profile.
- **Age band:** Stored as a range (e.g., `25-34`), not date of birth. Date of birth is never collected.
- **Experience level:** Self-declared categorical (beginner/intermediate/advanced). Not sensitive.

### 4.2 Attribute Use in Leaderboards

Filter combinations are computed server-side in the Edge Function. The leaderboard entry a member sees does not expose another member's age band or experience level. The member only sees "filtered leaderboard: your goal, your age group, your experience level" — they infer others in the group have similar attributes but no individual's attributes are disclosed.

If a filtered group has fewer than 5 members, the board falls back to a broader filter (first drops experience filter, then age band filter, then falls back to goal-only). The minimum-5 rule prevents de-anonymization by inference in very small gyms.

### 4.3 De-anonymization Risk Mitigation

| Risk | Mitigation |
|------|-----------|
| Small gym + specific filters could identify a member | Minimum 5 members per filter combination before rendering that board |
| Athlete #N could be guessed by process of elimination | Opaque hash changes each period; N is not sequential by join date |
| Avatar uniqueness could reveal identity | Avatar is chosen by the member; they control how distinctive it is |
| Delta arrows could reveal workout timing | Delta is score delta (aggregate), not timing information |

---

## 5. Data Access Controls (RLS)

All access control is enforced at the Postgres layer via Row Level Security. Application-layer checks are a secondary defense, not the primary one.

### 5.1 Critical Policies

```sql
-- Members can read their own profile; staff can read all profiles in their gym
CREATE POLICY "profiles_select" ON profiles
  FOR SELECT USING (
    id = auth.uid()
    OR (
      gym_id = current_user_gym_id()
      AND current_user_role() IN ('gym_owner', 'gym_staff')
    )
  );

-- Members cannot read other members' workout sessions
CREATE POLICY "workout_sessions_select" ON workout_sessions
  FOR SELECT USING (
    user_id = auth.uid()
    OR (
      gym_id = current_user_gym_id()
      AND current_user_role() IN ('gym_owner', 'gym_staff')
    )
  );

-- Leaderboard snapshots are readable by all gym members (privacy already applied in entries JSONB)
CREATE POLICY "leaderboard_snapshots_select" ON leaderboard_snapshots
  FOR SELECT USING (gym_id = current_user_gym_id());

-- Leaderboard snapshots are writable only by service role (Edge Function)
CREATE POLICY "leaderboard_snapshots_insert" ON leaderboard_snapshots
  FOR INSERT WITH CHECK (auth.role() = 'service_role');

-- XP events: members can read own; staff can read all in gym; inserts only via service role
CREATE POLICY "xp_events_select" ON xp_events
  FOR SELECT USING (
    user_id = auth.uid()
    OR (
      gym_id = current_user_gym_id()
      AND current_user_role() IN ('gym_owner', 'gym_staff')
    )
  );

CREATE POLICY "xp_events_insert" ON xp_events
  FOR INSERT WITH CHECK (auth.role() = 'service_role');

-- Baseline metrics: only own data, never readable by other members or staff
CREATE POLICY "baseline_metrics_select" ON baseline_metrics
  FOR SELECT USING (user_id = auth.uid());

-- Cross-gym isolation: enforce at gym_id level on every table
-- (above policies already enforce this via current_user_gym_id())
```

### 5.2 Service Role Usage

The Supabase `service_role` key is used **only** in Supabase Edge Functions, never in client-side code. Edge Functions that write XP events and leaderboard snapshots use the service role to bypass RLS where necessary (since they act on behalf of all users). The service role key is stored as a Supabase secret, never in the client app bundle.

### 5.3 Gym Isolation Verification

At project launch, run the following test assertions to verify cross-gym isolation:

1. Create two test gyms with one member each.
2. Log in as Gym A's member. Attempt `SELECT * FROM profiles WHERE gym_id = '<gym_b_id>'` via Supabase client. Must return 0 rows.
3. Attempt `SELECT * FROM workout_sessions WHERE gym_id = '<gym_b_id>'`. Must return 0 rows.
4. Attempt `SELECT * FROM leaderboard_snapshots WHERE gym_id = '<gym_b_id>'`. Must return 0 rows.
5. Repeat as Gym B's member against Gym A. All must return 0 rows.

These assertions must be added as automated integration tests in `supabase/functions/tests/rls.test.ts`.

---

## 6. Data Retention & Deletion

### 6.1 Member Account Deletion

When a member deletes their account (or a gym owner deactivates a member):

- `auth.users` row is deleted → cascades to `profiles` via `ON DELETE CASCADE`
- `workout_sessions` and `workout_sets` are cascade-deleted
- `xp_events`, `member_achievements`, `member_programs` are cascade-deleted
- `baseline_metrics` is cascade-deleted
- `leaderboard_snapshots.entries` JSONB is stale until next compute; the nightly job will exclude the deleted user

No hard-delete of other members' data is triggered by a single account deletion.

### 6.2 Gym Offboarding

When a gym's subscription ends:
- Gym is marked `is_active = false`
- Members are not immediately deleted — 30-day grace period for export
- After grace period, all gym data (profiles, workouts, programs, snapshots) is deleted via a maintenance job

### 6.3 Workout Data

Workout data is retained indefinitely while the account is active. There is no automatic aging or deletion of historical workout sets. Members may request full data export (future feature; planned as JSON download from profile settings).

---

## 7. Regulatory Considerations

This section identifies areas that require legal review before public launch. L3velUp is not a medical app and does not collect health data in the regulatory sense (no biometric data, no diagnosis, no treatment recommendations).

| Area | Status | Notes |
|------|--------|-------|
| GDPR (EU users) | Future review | Age band is not DOB; no special category health data collected. If EU gyms are targeted, DPA agreements with Supabase needed, right-to-erasure flow needed. |
| CCPA (California users) | Future review | No personal data sold. Data export capability needed for CCPA compliance. |
| COPPA (Under-13) | Enforced | Minimum age band is 16-24; onboarding includes age band selection; terms must require 16+ minimum. Do not collect data from users under 16. |
| Health data (Apple/Google) | Not triggered | App does not integrate with Apple Health or Google Fit in MVP. No HealthKit / Health Connect entitlements requested. |
| Supabase DPA | Required | Supabase offers a Data Processing Agreement for GDPR. Sign before EU launch. |

---

## 8. Privacy UI Checklist

The following privacy controls must be surfaced to members in the mobile app:

- [ ] Privacy tier selector in Profile > Settings (gym_visible / anonymous / private)
- [ ] Explanation of what each tier means (in-app tooltip or help text)
- [ ] "What data do we use for leaderboards?" expandable info section on leaderboard screen
- [ ] Account deletion request option in Profile > Settings (triggers support email in MVP; automated in Phase 2)
- [ ] Link to privacy policy (external URL, provided by gym owner for white-label) on registration screen
- [ ] Cookie/tracking consent banner not required in MVP (no third-party analytics trackers; Sentry is error tracking only, not behavioral analytics)
