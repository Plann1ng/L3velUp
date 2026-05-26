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

export type LeaderboardPrivacy = 'public' | 'gym_visible' | 'anonymous' | 'private';

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
  leaderboardPrivacy: LeaderboardPrivacy;
  onboardingComplete: boolean;
  createdAt: string;
  updatedAt: string;
}
