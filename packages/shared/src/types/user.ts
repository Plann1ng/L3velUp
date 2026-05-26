import type { AvatarConfig } from './avatar';

export type Goal =
  | 'strength'
  | 'muscle_gain'
  | 'fat_loss'
  | 'fitness'
  | 'cardio'
  | 'power'
  | 'mobility'
  | 'general_health';

export type AgeBand = '16-24' | '25-34' | '35-44' | '45-54' | '55+';

export type ExperienceLevel = 'beginner' | 'intermediate' | 'advanced';

export type UserRole = 'gym_owner' | 'gym_staff' | 'member';

/** Controls how a member appears on leaderboards. Matches DB enum. */
export type LeaderboardVisibility = 'public_name' | 'nickname' | 'private';

export interface Profile {
  id: string;
  gymId: string;
  role: UserRole;
  displayName: string;
  avatarConfig: AvatarConfig;
  goal: Goal | null;
  ageBand: AgeBand | null;
  experienceLevel: ExperienceLevel | null;
  xpTotal: number;
  xpLevel: number;
  streakCurrent: number;
  streakBest: number;
  lastWorkoutDate: string | null;
  leaderboardVisibility: LeaderboardVisibility;
  cityLeaderboardOptIn: boolean;
  countryLeaderboardOptIn: boolean;
  onboardingComplete: boolean;
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
}

/** One entry in the history of a member's goal choices. */
export interface MemberGoal {
  id: string;
  profileId: string;
  goal: Goal;
  isCurrent: boolean;
  startedAt: string;
  endedAt: string | null;
  createdAt: string;
}

/** Stored once at onboarding; drives the progress leaderboard computation. */
export interface BaselineMetrics {
  id: string;
  profileId: string;
  recordedAt: string;
  bodyWeightKg: number | null;
  bench1RMkg: number | null;
  squat1RMkg: number | null;
  deadlift1RMkg: number | null;
  run5kSeconds: number | null;
  pushupsMax: number | null;
  extraMetrics: Record<string, number>;
}
