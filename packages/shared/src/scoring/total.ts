import type { Goal } from '../types/user';
import { clamp } from './utils';

export interface GoalWeights {
  consistency: number;
  progress: number;
  performance: number;
}

/**
 * Weight triplets for each goal. All three weights sum to 1.0.
 *
 * Design rationale:
 * - fat_loss prioritises consistency because showing up consistently
 *   is the dominant driver of body composition change.
 * - strength / power prioritise progress (1RM improvement) most.
 * - muscle_gain weights progress and consistency almost equally.
 * - mobility / general_health weight consistency highest since
 *   the habit of regular practice matters more than measurable gains.
 */
export const GOAL_WEIGHTS: Record<Goal, GoalWeights> = {
  strength:       { consistency: 0.30, progress: 0.45, performance: 0.25 },
  muscle_gain:    { consistency: 0.35, progress: 0.45, performance: 0.20 },
  fat_loss:       { consistency: 0.60, progress: 0.30, performance: 0.10 },
  cardio:         { consistency: 0.35, progress: 0.45, performance: 0.20 },
  fitness:        { consistency: 0.40, progress: 0.35, performance: 0.25 },
  general_health: { consistency: 0.50, progress: 0.30, performance: 0.20 },
  mobility:       { consistency: 0.50, progress: 0.35, performance: 0.15 },
  power:          { consistency: 0.30, progress: 0.45, performance: 0.25 },
};

export interface ComponentScores {
  /** 0–100 consistency score. */
  consistency: number;
  /** 0–100 progress score. */
  progress: number;
  /** 0–100 performance (XP) score. */
  performance: number;
}

/**
 * Returns a 0–100 composite leaderboard score weighted by goal.
 *
 * Each component score is clamped to [0, 100] before multiplication so that
 * out-of-range caller inputs cannot corrupt the final score.
 */
export function calculateTotalScore(goal: Goal, scores: ComponentScores): number {
  const w = GOAL_WEIGHTS[goal];
  const raw =
    w.consistency  * clamp(scores.consistency,  0, 100) +
    w.progress     * clamp(scores.progress,     0, 100) +
    w.performance  * clamp(scores.performance,  0, 100);
  return clamp(raw, 0, 100);
}
