export function calculateVolume(
  sets: Array<{ reps: number | null; weightKg: number | null }>
): number {
  return sets.reduce((total, set) => {
    if (set.reps == null || set.weightKg == null) return total;
    return total + set.reps * set.weightKg;
  }, 0);
}

/** Epley formula: estimated 1-rep max from a working set */
export function epley1RM(weightKg: number, reps: number): number {
  if (reps === 1) return weightKg;
  return weightKg * (1 + reps / 30);
}

export function isPersonalRecord(
  currentSet: { weightKg: number | null; reps: number | null },
  history: Array<{ weightKg: number | null; reps: number | null }>
): boolean {
  if (currentSet.weightKg == null || currentSet.reps == null) return false;
  const current1RM = epley1RM(currentSet.weightKg, currentSet.reps);
  return history.every((set) => {
    if (set.weightKg == null || set.reps == null) return true;
    return epley1RM(set.weightKg, set.reps) < current1RM;
  });
}
