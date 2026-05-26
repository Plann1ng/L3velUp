import type { AvatarConfig } from './avatar';
import type { AgeBand, ExperienceLevel, Goal, LeaderboardPrivacy } from './user';

export type BoardType = 'progress' | 'consistency' | 'performance';

export type BoardScope = 'gym' | 'city' | 'country';

export type BoardPeriod = 'weekly' | 'monthly' | 'all_time';

export interface LeaderboardEntry {
  rank: number;
  userId: string;
  displayName: string;
  avatarConfig: AvatarConfig;
  score: number;
  delta: number;
  privacyMode: LeaderboardPrivacy;
}

export interface LeaderboardSnapshot {
  id: string;
  gymId: string;
  boardType: BoardType;
  scope: BoardScope;
  goalFilter: Goal | null;
  ageBandFilter: AgeBand | null;
  expFilter: ExperienceLevel | null;
  period: BoardPeriod;
  entries: LeaderboardEntry[];
  computedAt: string;
}
