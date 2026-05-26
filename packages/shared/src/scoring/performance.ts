import type { BoardPeriod } from '../types/leaderboard';
import { PERFORMANCE_MAX_XP } from '../constants/leaderboard';
import { clamp } from './utils';

/**
 * Returns 0–100 representing XP earned in a period relative to the expected
 * maximum for that period type.
 *
 * This is intentionally simple — the Edge Function further normalises scores
 * among peers with the same goal/age band/experience level.
 *
 * @param xpEarned   XP earned by the member in the period.
 * @param period     The leaderboard period — drives the reference maximum.
 * @param customMax  Override the reference maximum (useful in tests).
 */
export function calculatePerformanceScore(
  xpEarned: number,
  period: BoardPeriod,
  customMax?: number
): number {
  const maxXp = customMax ?? PERFORMANCE_MAX_XP[period];
  if (maxXp <= 0) return 0;
  if (xpEarned <= 0) return 0;
  return clamp((xpEarned / maxXp) * 100, 0, 100);
}
