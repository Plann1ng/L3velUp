import type { Goal } from '../types/user';
import { clamp, safePercentChange } from './utils';
import { epley1RM } from './workout';

// ─── Strength ────────────────────────────────────────────────────────────────

export interface StrengthProgressInput {
  /** Current best estimated 1RM in kg (computed from recent sets via epley1RM). */
  currentBest1RMkg: number;
  /** Baseline 1RM in kg at time of onboarding / period start. 0 = no history. */
  baselineBest1RMkg: number;
}

/**
 * Returns 0–100 for strength/power progress.
 *
 * - No baseline (0) → 0: the member has nothing to compare against yet.
 * - Regression (currentBest1RMkg < baseline) → 0: we don't penalise regressions
 *   publicly; they are still visible as a delta on the member's own profile.
 * - 100% improvement → 100 (capped).
 */
export function calculateStrengthProgressScore(input: StrengthProgressInput): number {
  const { currentBest1RMkg, baselineBest1RMkg } = input;
  if (baselineBest1RMkg <= 0 || currentBest1RMkg <= 0) return 0;
  return clamp(safePercentChange(currentBest1RMkg, baselineBest1RMkg), 0, 100);
}

// ─── Cardio ──────────────────────────────────────────────────────────────────

export interface CardioProgressInput {
  /** Current pace in seconds per km. Lower is faster = better. */
  currentPaceSecsPerKm: number;
  /** Baseline pace in seconds per km. 0 = no history. */
  baselinePaceSecsPerKm: number;
}

/**
 * Returns 0–100 for cardio/fitness progress.
 *
 * - Improvement = (baseline − current) / baseline × 100.
 * - Getting slower → 0 (clamped, not negative on leaderboard).
 */
export function calculateCardioProgressScore(input: CardioProgressInput): number {
  const { currentPaceSecsPerKm, baselinePaceSecsPerKm } = input;
  if (baselinePaceSecsPerKm <= 0 || currentPaceSecsPerKm <= 0) return 0;
  const improvement = baselinePaceSecsPerKm - currentPaceSecsPerKm;
  return clamp((improvement / baselinePaceSecsPerKm) * 100, 0, 100);
}

// ─── Volume (muscle gain) ────────────────────────────────────────────────────

export interface VolumeProgressInput {
  /** Current period's total volume load (kg × reps). */
  currentVolumeKg: number;
  /** Baseline period's volume load. 0 = no history. */
  baselineVolumeKg: number;
}

/**
 * Returns 0–100 for muscle-gain progress based on volume load improvement.
 */
export function calculateVolumeProgressScore(input: VolumeProgressInput): number {
  const { currentVolumeKg, baselineVolumeKg } = input;
  if (baselineVolumeKg <= 0 || currentVolumeKg <= 0) return 0;
  return clamp(safePercentChange(currentVolumeKg, baselineVolumeKg), 0, 100);
}

// ─── Fat loss ────────────────────────────────────────────────────────────────

export interface FatLossProgressInput {
  /** Current body weight in kg. */
  currentWeightKg: number;
  /** Baseline body weight in kg at onboarding. 0 = not provided. */
  baselineWeightKg: number;
}

/**
 * Returns 0–100 for fat-loss progress based on percentage weight reduction.
 *
 * - Gaining weight → 0 (clamped, not negative).
 * - 10% body weight reduction → 100 (10% is considered excellent progress;
 *   anything beyond is capped).
 */
export function calculateFatLossProgressScore(input: FatLossProgressInput): number {
  const { currentWeightKg, baselineWeightKg } = input;
  if (baselineWeightKg <= 0 || currentWeightKg <= 0) return 0;
  const reduction = baselineWeightKg - currentWeightKg;
  // Scale: 10% body weight reduction = 100 points
  const percentReduction = (reduction / baselineWeightKg) * 100;
  return clamp(percentReduction * 10, 0, 100);
}

// ─── Generic (mobility, general_health) ──────────────────────────────────────

export interface GenericProgressInput {
  currentValue: number;
  baselineValue: number;
  /** Set to false when lower value is better (e.g. completion time). Default true. */
  higherIsBetter?: boolean;
}

export function calculateGenericProgressScore(input: GenericProgressInput): number {
  const { currentValue, baselineValue, higherIsBetter = true } = input;
  if (baselineValue <= 0) return 0;
  const pct = higherIsBetter
    ? safePercentChange(currentValue, baselineValue)
    : ((baselineValue - currentValue) / baselineValue) * 100;
  return clamp(pct, 0, 100);
}

// ─── Estimated best 1RM from a set of workout sets ───────────────────────────

export interface SetForEstimate {
  reps: number | null;
  weightKg: number | null;
}

/**
 * Finds the highest estimated 1RM across a list of sets using the Epley formula.
 * Returns 0 if no valid sets exist.
 */
export function estimateBest1RM(sets: SetForEstimate[]): number {
  let best = 0;
  for (const s of sets) {
    if (s.reps == null || s.weightKg == null || s.reps <= 0 || s.weightKg <= 0) continue;
    const estimated = epley1RM(s.weightKg, s.reps);
    if (estimated > best) best = estimated;
  }
  return best;
}

// ─── Goal dispatcher ─────────────────────────────────────────────────────────

export interface ProgressScoreParams {
  // Strength / power
  currentBest1RMkg?: number;
  baselineBest1RMkg?: number;
  // Cardio / fitness
  currentPaceSecsPerKm?: number;
  baselinePaceSecsPerKm?: number;
  // Muscle gain
  currentVolumeKg?: number;
  baselineVolumeKg?: number;
  // Fat loss
  currentWeightKg?: number;
  baselineWeightKg?: number;
  // Generic fallback (mobility, general_health)
  currentMetric?: number;
  baselineMetric?: number;
  higherIsBetter?: boolean;
}

/**
 * Dispatches to the correct progress scorer based on the member's goal.
 * All missing params default to 0, producing a score of 0 (no history).
 */
export function calculateProgressScore(goal: Goal, params: ProgressScoreParams): number {
  switch (goal) {
    case 'strength':
    case 'power':
      return calculateStrengthProgressScore({
        currentBest1RMkg: params.currentBest1RMkg ?? 0,
        baselineBest1RMkg: params.baselineBest1RMkg ?? 0,
      });
    case 'muscle_gain':
      return calculateVolumeProgressScore({
        currentVolumeKg: params.currentVolumeKg ?? 0,
        baselineVolumeKg: params.baselineVolumeKg ?? 0,
      });
    case 'fat_loss':
      return calculateFatLossProgressScore({
        currentWeightKg: params.currentWeightKg ?? 0,
        baselineWeightKg: params.baselineWeightKg ?? 0,
      });
    case 'cardio':
    case 'fitness':
      return calculateCardioProgressScore({
        currentPaceSecsPerKm: params.currentPaceSecsPerKm ?? 0,
        baselinePaceSecsPerKm: params.baselinePaceSecsPerKm ?? 0,
      });
    case 'mobility':
    case 'general_health':
      return calculateGenericProgressScore({
        currentValue: params.currentMetric ?? 0,
        baselineValue: params.baselineMetric ?? 0,
        higherIsBetter: params.higherIsBetter ?? true,
      });
    default:
      return 0;
  }
}
