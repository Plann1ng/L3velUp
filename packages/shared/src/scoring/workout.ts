export interface SetForVolume {
  reps: number | null;
  weightKg: number | null;
}

/**
 * Total volume load in kg across all strength sets (reps × weight).
 * Skips sets where either value is null or non-positive.
 */
export function calculateStrengthVolume(sets: SetForVolume[]): number {
  return sets.reduce((total, set) => {
    if (set.reps == null || set.weightKg == null) return total;
    if (set.reps <= 0 || set.weightKg <= 0) return total;
    return total + set.reps * set.weightKg;
  }, 0);
}

/** Alias for general volume calculation — all sets including cardio/bodyweight. */
export function calculateVolume(sets: SetForVolume[]): number {
  return sets.reduce((total, set) => {
    if (set.reps == null || set.weightKg == null) return total;
    return total + set.reps * set.weightKg;
  }, 0);
}

/** Epley formula: estimated 1-rep max from a working set. */
export function epley1RM(weightKg: number, reps: number): number {
  if (reps <= 0 || weightKg <= 0) return 0;
  if (reps === 1) return weightKg;
  return weightKg * (1 + reps / 30);
}

export interface SetForPR {
  weightKg: number | null;
  reps: number | null;
}

/**
 * Returns true if currentSet's estimated 1RM beats every set in history.
 * Empty history (beginner's first set) returns true.
 */
export function isPersonalRecord(currentSet: SetForPR, history: SetForPR[]): boolean {
  if (currentSet.weightKg == null || currentSet.reps == null) return false;
  if (currentSet.weightKg <= 0 || currentSet.reps <= 0) return false;
  const current1RM = epley1RM(currentSet.weightKg, currentSet.reps);
  return history.every((set) => {
    if (set.weightKg == null || set.reps == null) return true;
    if (set.weightKg <= 0 || set.reps <= 0) return true;
    return epley1RM(set.weightKg, set.reps) < current1RM;
  });
}
