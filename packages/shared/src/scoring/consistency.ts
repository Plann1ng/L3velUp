import { clamp } from './utils';

export interface ConsistencyScoreInput {
  /** Actual workouts logged in the period. */
  workoutsLogged: number;
  /** Member's self-declared sessions per week (1–7). */
  targetWorkoutsPerWeek: number;
  /** Number of weeks in the scoring period (e.g. 1, 4, 52). */
  periodWeeks: number;
}

/**
 * Returns a 0–100 score measuring how closely the member hit their
 * self-declared workout target.
 *
 * - Zero target or zero weeks → 0 (guard against division by zero).
 * - Over-performing (more than target) → clamped to 100.
 */
export function calculateConsistencyScore(input: ConsistencyScoreInput): number {
  const { workoutsLogged, targetWorkoutsPerWeek, periodWeeks } = input;

  if (targetWorkoutsPerWeek <= 0 || periodWeeks <= 0) return 0;
  if (workoutsLogged <= 0) return 0;

  const targetTotal = targetWorkoutsPerWeek * periodWeeks;
  return clamp((workoutsLogged / targetTotal) * 100, 0, 100);
}
