import type { AvatarConfig } from './avatar';
import type { AgeBand, ExperienceLevel, Goal, LeaderboardVisibility } from './user';

export type BoardType = 'progress' | 'consistency' | 'performance';

export type BoardScope = 'gym' | 'city' | 'country';

export type BoardPeriod = 'weekly' | 'monthly' | 'all_time';

export interface LeaderboardEntry {
  rank: number;
  profileId: string;
  displayName: string;
  avatarConfig: AvatarConfig;
  score: number;
  scoreDelta: number;
  /** Privacy mode at time of snapshot — 'private' entries are never included */
  visibilityMode: Exclude<LeaderboardVisibility, 'private'>;
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

export interface LeaderboardFilters {
  boardType: BoardType;
  period: BoardPeriod;
  goalFilter?: Goal;
  ageBandFilter?: AgeBand;
  expFilter?: ExperienceLevel;
}
