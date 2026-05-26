import type { BoardPeriod, BoardScope, BoardType } from '../types/leaderboard';
import type { LeaderboardVisibility } from '../types/user';

export const BOARD_TYPES: BoardType[] = ['progress', 'consistency', 'performance'];

export const BOARD_TYPE_LABELS: Record<BoardType, string> = {
  progress: 'Progress',
  consistency: 'Consistency',
  performance: 'Performance',
};

export const BOARD_TYPE_DESCRIPTIONS: Record<BoardType, string> = {
  progress: 'Percentage improvement in your primary goal metric vs. your baseline',
  consistency: 'How closely you hit your target workout schedule',
  performance: 'XP earned in the period, normalized among similar members',
};

export const BOARD_SCOPES: BoardScope[] = ['gym', 'city', 'country'];

export const BOARD_SCOPE_LABELS: Record<BoardScope, string> = {
  gym: 'My Gym',
  city: 'My City',
  country: 'My Country',
};

export const BOARD_PERIODS: BoardPeriod[] = ['weekly', 'monthly', 'all_time'];

export const BOARD_PERIOD_LABELS: Record<BoardPeriod, string> = {
  weekly: 'This Week',
  monthly: 'This Month',
  all_time: 'All Time',
};

/** A leaderboard won't render until this many qualifying members exist. */
export const LEADERBOARD_MIN_MEMBERS = 5;

export const LEADERBOARD_VISIBILITY_LABELS: Record<LeaderboardVisibility, string> = {
  public_name: 'Show my name',
  nickname: 'Show avatar only (anonymous)',
  private: 'Hide me from leaderboards',
};

/** Maximum XP expected in a period — used to normalise performance scores. */
export const PERFORMANCE_MAX_XP: Record<BoardPeriod, number> = {
  weekly: 600,
  monthly: 2400,
  all_time: 50000,
};
