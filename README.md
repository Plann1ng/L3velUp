# L3velUp — Gym Member Engagement Platform

A white-label gym engagement app with gamification, 2D avatar customization, and fair leaderboards.

## Monorepo Structure

```
L3velUp/
├── apps/
│   ├── mobile/        # Expo React Native (SDK 56, TypeScript)
│   └── admin/         # Next.js 16 admin dashboard (TypeScript, Tailwind CSS 4)
├── packages/
│   └── shared/        # Shared types, Zod schemas, scoring utilities
├── supabase/
│   ├── migrations/    # Postgres migrations (run via Supabase CLI)
│   └── functions/     # Edge Functions
└── docs/              # Product spec, build roadmap, privacy model
```

## Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| Node.js | ≥ 22 | [nodejs.org](https://nodejs.org) |
| pnpm | ≥ 10 | `npm i -g pnpm` |
| Expo CLI | ≥ 56 | `npm i -g expo` |
| Supabase CLI | latest | [supabase.com/docs/guides/cli](https://supabase.com/docs/guides/cli) |

## Installation

```bash
# Install all workspace dependencies from the repo root
pnpm install

# Build the shared package (required before running apps)
pnpm shared:build
```

## Running the Mobile App

```bash
# Copy and fill in environment variables
cp apps/mobile/.env.example apps/mobile/.env

# Start the Expo dev server
pnpm --filter @l3velup/mobile start

# Or target a specific platform
pnpm --filter @l3velup/mobile android
pnpm --filter @l3velup/mobile ios
pnpm --filter @l3velup/mobile web
```

Scan the QR code in your terminal with the **Expo Go** app on your phone, or press `a`/`i` to open on a connected emulator.

> **Note:** Install Expo Go from the [App Store](https://apps.apple.com/app/expo-go/id982107779) or [Play Store](https://play.google.com/store/apps/details?id=host.exp.exponent).

## Running the Admin App

```bash
# Copy and fill in environment variables
cp apps/admin/.env.example apps/admin/.env

# Start the Next.js dev server
pnpm --filter @l3velup/admin dev
```

Open [http://localhost:3000](http://localhost:3000) in your browser.

## Configuring Supabase

### Local development

```bash
# Install Supabase CLI (if not already installed)
brew install supabase/tap/supabase   # macOS
# or: npm i -g supabase              # cross-platform

# Start local Supabase stack (Postgres, Auth, Storage, Studio)
supabase start

# The CLI will print your local URL and keys — copy them into your .env files
```

Your local Supabase credentials will look like:

```
API URL: http://127.0.0.1:54321
anon key: eyJ...
service_role key: eyJ...
DB URL: postgresql://postgres:postgres@127.0.0.1:54322/postgres
Studio: http://127.0.0.1:54323
```

### Running migrations

```bash
supabase db push
```

### Remote project

1. Create a project at [supabase.com](https://supabase.com).
2. Copy the **Project URL** and **anon key** from **Settings → API**.
3. Copy the **service_role key** — keep it secret, only use it in `apps/admin/.env`.
4. Link your CLI: `supabase link --project-ref <your-ref>`
5. Push migrations: `supabase db push`

## Environment Variables

### `apps/mobile/.env`

| Variable | Description |
|----------|-------------|
| `EXPO_PUBLIC_SUPABASE_URL` | Your Supabase project URL |
| `EXPO_PUBLIC_SUPABASE_ANON_KEY` | Public anon key (safe for mobile) |

> The `EXPO_PUBLIC_` prefix is required — Expo strips all other env vars from the client bundle.

### `apps/admin/.env`

| Variable | Description | Client? |
|----------|-------------|---------|
| `NEXT_PUBLIC_SUPABASE_URL` | Your Supabase project URL | ✅ |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Public anon key | ✅ |
| `SUPABASE_SERVICE_ROLE_KEY` | Service role key — **server only** | ❌ |

> **Security:** Never prefix the service role key with `NEXT_PUBLIC_`. It must only be used in Server Components and Route Handlers via `createAdminSupabaseClient()`.

## Development Commands

```bash
# Run from the repo root

pnpm build          # Build all packages and apps
pnpm dev            # Start all dev servers (via Turborepo)
pnpm lint           # Lint all packages
pnpm typecheck      # TypeScript type-check all packages
pnpm format         # Format all files with Prettier
pnpm format:check   # Check formatting without writing

# Scoped commands
pnpm --filter @l3velup/shared build       # Build shared package
pnpm --filter @l3velup/admin dev          # Run admin only
pnpm --filter @l3velup/mobile start       # Run mobile only
```

## Packages

### `@l3velup/shared`

Shared TypeScript types, Zod schemas, and scoring utilities used by both apps.

**Exports:**
- **Types:** `Goal`, `Profile`, `Gym`, `WorkoutSession`, `AvatarConfig`, `LeaderboardSnapshot`, etc.
- **Constants:** `GOALS`, `GOAL_LABELS`, `GOAL_DESCRIPTIONS`, `AGE_BANDS`, `XP_EVENTS`
- **Schemas:** `updateProfileSchema`, `finishWorkoutSchema`, `workoutSetSchema`
- **Scoring:** `getLevel()`, `getXpProgress()`, `epley1RM()`, `calculateVolume()`, `isPersonalRecord()`

```ts
import { GOALS, getXpProgress, finishWorkoutSchema } from '@l3velup/shared';
```

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile | Expo SDK 56, React Native 0.85, Expo Router, TypeScript |
| Admin | Next.js 16, React 19, Tailwind CSS 4, TypeScript |
| Shared | TypeScript, Zod, tsup |
| Backend | Supabase (Postgres 17, Auth, Storage, Edge Functions, RLS) |
| Monorepo | pnpm workspaces, Turborepo |
| Linting | ESLint 9 (flat config), Prettier 3 |

## Documentation

- [`docs/product-spec.md`](docs/product-spec.md) — Full technical spec, data models, screens, and architecture decisions
- [`docs/build-roadmap.md`](docs/build-roadmap.md) — MVP milestone breakdown (~20 weeks)
- [`docs/privacy-model.md`](docs/privacy-model.md) — Leaderboard privacy design and RLS policies
