import { describe, expect, it } from 'vitest';
import {
  calculateCardioProgressScore,
  calculateFatLossProgressScore,
  calculateGenericProgressScore,
  calculateStrengthProgressScore,
  calculateVolumeProgressScore,
  calculateProgressScore,
  estimateBest1RM,
} from '../progress';

describe('calculateStrengthProgressScore', () => {
  // ── Beginner / no-history cases ──────────────────────────────────────────
  it('returns 0 when baseline is 0 (new member, no history)', () => {
    expect(calculateStrengthProgressScore({ currentBest1RMkg: 100, baselineBest1RMkg: 0 })).toBe(0);
  });

  it('returns 0 when current is 0 (no recent data)', () => {
    expect(calculateStrengthProgressScore({ currentBest1RMkg: 0, baselineBest1RMkg: 100 })).toBe(0);
  });

  it('returns 0 when both are 0', () => {
    expect(calculateStrengthProgressScore({ currentBest1RMkg: 0, baselineBest1RMkg: 0 })).toBe(0);
  });

  // ── No improvement ───────────────────────────────────────────────────────
  it('returns 0 for no change (same as baseline)', () => {
    expect(calculateStrengthProgressScore({ currentBest1RMkg: 100, baselineBest1RMkg: 100 })).toBe(0);
  });

  // ── Positive progress ────────────────────────────────────────────────────
  it('returns 10 for a 10% improvement', () => {
    expect(
      calculateStrengthProgressScore({ currentBest1RMkg: 110, baselineBest1RMkg: 100 })
    ).toBeCloseTo(10);
  });

  it('returns 25 for a 25% improvement', () => {
    expect(
      calculateStrengthProgressScore({ currentBest1RMkg: 125, baselineBest1RMkg: 100 })
    ).toBeCloseTo(25);
  });

  it('returns 50 for a 50% improvement', () => {
    expect(
      calculateStrengthProgressScore({ currentBest1RMkg: 150, baselineBest1RMkg: 100 })
    ).toBeCloseTo(50);
  });

  // ── Extreme progress → clamped to 100 ───────────────────────────────────
  it('clamps a 100% improvement to 100', () => {
    expect(
      calculateStrengthProgressScore({ currentBest1RMkg: 200, baselineBest1RMkg: 100 })
    ).toBe(100);
  });

  it('clamps extreme progress (1000% improvement) to 100', () => {
    expect(
      calculateStrengthProgressScore({ currentBest1RMkg: 1100, baselineBest1RMkg: 100 })
    ).toBe(100);
  });

  // ── Regression (negative progress) → clamped to 0 ───────────────────────
  it('returns 0 for regression — not penalised on leaderboard', () => {
    expect(
      calculateStrengthProgressScore({ currentBest1RMkg: 80, baselineBest1RMkg: 100 })
    ).toBe(0);
  });

  it('returns 0 for severe regression', () => {
    expect(
      calculateStrengthProgressScore({ currentBest1RMkg: 10, baselineBest1RMkg: 100 })
    ).toBe(0);
  });

  // ── Fractional kg values ─────────────────────────────────────────────────
  it('handles fractional kg values', () => {
    expect(
      calculateStrengthProgressScore({ currentBest1RMkg: 102.5, baselineBest1RMkg: 100 })
    ).toBeCloseTo(2.5);
  });
});

describe('calculateCardioProgressScore', () => {
  it('returns 0 when baseline pace is 0 (no history)', () => {
    expect(
      calculateCardioProgressScore({ currentPaceSecsPerKm: 300, baselinePaceSecsPerKm: 0 })
    ).toBe(0);
  });

  it('returns 0 when current pace is 0 (no data)', () => {
    expect(
      calculateCardioProgressScore({ currentPaceSecsPerKm: 0, baselinePaceSecsPerKm: 360 })
    ).toBe(0);
  });

  it('returns 0 for no improvement (same pace)', () => {
    expect(
      calculateCardioProgressScore({ currentPaceSecsPerKm: 360, baselinePaceSecsPerKm: 360 })
    ).toBe(0);
  });

  it('returns ~10 for a 10% pace improvement (faster)', () => {
    // baseline 360 s/km → current 324 s/km = 10% faster
    expect(
      calculateCardioProgressScore({ currentPaceSecsPerKm: 324, baselinePaceSecsPerKm: 360 })
    ).toBeCloseTo(10);
  });

  it('returns ~25 for a 25% pace improvement', () => {
    expect(
      calculateCardioProgressScore({ currentPaceSecsPerKm: 270, baselinePaceSecsPerKm: 360 })
    ).toBeCloseTo(25);
  });

  it('approaches 100 for extreme (near-impossible) pace improvement', () => {
    // (360-1)/360 = 99.72% — cannot exceed 100% with this formula unless pace=0
    expect(
      calculateCardioProgressScore({ currentPaceSecsPerKm: 1, baselinePaceSecsPerKm: 360 })
    ).toBeGreaterThan(99);
  });

  it('returns 0 for getting slower (regression → 0)', () => {
    expect(
      calculateCardioProgressScore({ currentPaceSecsPerKm: 420, baselinePaceSecsPerKm: 360 })
    ).toBe(0);
  });
});

describe('calculateFatLossProgressScore', () => {
  it('returns 0 when baseline weight is 0', () => {
    expect(calculateFatLossProgressScore({ currentWeightKg: 80, baselineWeightKg: 0 })).toBe(0);
  });

  it('returns 0 when no weight change', () => {
    expect(calculateFatLossProgressScore({ currentWeightKg: 90, baselineWeightKg: 90 })).toBe(0);
  });

  it('returns 50 for 5% weight loss (10% = 100 scale)', () => {
    // 5% of 90kg = 4.5kg lost → score = 50
    expect(
      calculateFatLossProgressScore({ currentWeightKg: 85.5, baselineWeightKg: 90 })
    ).toBeCloseTo(50);
  });

  it('returns 100 for exactly 10% weight loss', () => {
    expect(
      calculateFatLossProgressScore({ currentWeightKg: 81, baselineWeightKg: 90 })
    ).toBeCloseTo(100);
  });

  it('clamps to 100 for more than 10% loss', () => {
    expect(
      calculateFatLossProgressScore({ currentWeightKg: 70, baselineWeightKg: 90 })
    ).toBe(100);
  });

  it('returns 0 for weight gain (regression)', () => {
    expect(
      calculateFatLossProgressScore({ currentWeightKg: 95, baselineWeightKg: 90 })
    ).toBe(0);
  });
});

describe('calculateVolumeProgressScore', () => {
  it('returns 0 when baseline volume is 0 (beginner)', () => {
    expect(
      calculateVolumeProgressScore({ currentVolumeKg: 5000, baselineVolumeKg: 0 })
    ).toBe(0);
  });

  it('returns 0 for no change', () => {
    expect(
      calculateVolumeProgressScore({ currentVolumeKg: 5000, baselineVolumeKg: 5000 })
    ).toBe(0);
  });

  it('returns ~20 for a 20% volume increase', () => {
    expect(
      calculateVolumeProgressScore({ currentVolumeKg: 6000, baselineVolumeKg: 5000 })
    ).toBeCloseTo(20);
  });

  it('clamps extreme volume gains to 100', () => {
    expect(
      calculateVolumeProgressScore({ currentVolumeKg: 100000, baselineVolumeKg: 5000 })
    ).toBe(100);
  });

  it('returns 0 for volume regression', () => {
    expect(
      calculateVolumeProgressScore({ currentVolumeKg: 4000, baselineVolumeKg: 5000 })
    ).toBe(0);
  });
});

describe('calculateGenericProgressScore', () => {
  it('returns 0 for zero baseline', () => {
    expect(calculateGenericProgressScore({ currentValue: 10, baselineValue: 0 })).toBe(0);
  });

  it('returns correct score for higher-is-better metric (default)', () => {
    expect(
      calculateGenericProgressScore({ currentValue: 15, baselineValue: 10 })
    ).toBeCloseTo(50);
  });

  it('returns correct score for lower-is-better metric', () => {
    // baseline = 100s, current = 80s → 20% improvement
    expect(
      calculateGenericProgressScore({ currentValue: 80, baselineValue: 100, higherIsBetter: false })
    ).toBeCloseTo(20);
  });

  it('returns 0 for regression on higher-is-better', () => {
    expect(
      calculateGenericProgressScore({ currentValue: 8, baselineValue: 10 })
    ).toBe(0);
  });
});

describe('estimateBest1RM', () => {
  it('returns 0 for empty set list (beginner, no history)', () => {
    expect(estimateBest1RM([])).toBe(0);
  });

  it('returns 0 when all sets have null values', () => {
    expect(estimateBest1RM([{ reps: null, weightKg: null }])).toBe(0);
  });

  it('returns the single-rep weight for a 1-rep set', () => {
    expect(estimateBest1RM([{ reps: 1, weightKg: 140 }])).toBeCloseTo(140);
  });

  it('uses Epley to estimate 1RM from a multi-rep set', () => {
    // 100kg × 5 reps → Epley = 100 × (1 + 5/30) = 116.67
    expect(estimateBest1RM([{ reps: 5, weightKg: 100 }])).toBeCloseTo(116.67, 1);
  });

  it('picks the best 1RM across multiple sets', () => {
    const sets = [
      { reps: 5, weightKg: 100 }, // 116.67
      { reps: 1, weightKg: 120 }, // 120
      { reps: 3, weightKg: 110 }, // 10 × (1 + 3/30) = 110 × 1.1 = 121
    ];
    expect(estimateBest1RM(sets)).toBeCloseTo(121, 0);
  });
});

describe('calculateProgressScore (goal dispatcher)', () => {
  it('dispatches strength to strength scorer', () => {
    const score = calculateProgressScore('strength', {
      currentBest1RMkg: 110,
      baselineBest1RMkg: 100,
    });
    expect(score).toBeCloseTo(10);
  });

  it('dispatches power to strength scorer', () => {
    const score = calculateProgressScore('power', {
      currentBest1RMkg: 150,
      baselineBest1RMkg: 100,
    });
    expect(score).toBeCloseTo(50);
  });

  it('dispatches muscle_gain to volume scorer', () => {
    const score = calculateProgressScore('muscle_gain', {
      currentVolumeKg: 6000,
      baselineVolumeKg: 5000,
    });
    expect(score).toBeCloseTo(20);
  });

  it('dispatches fat_loss to fat loss scorer', () => {
    const score = calculateProgressScore('fat_loss', {
      currentWeightKg: 85.5,
      baselineWeightKg: 90,
    });
    expect(score).toBeCloseTo(50);
  });

  it('dispatches cardio to cardio scorer', () => {
    const score = calculateProgressScore('cardio', {
      currentPaceSecsPerKm: 324,
      baselinePaceSecsPerKm: 360,
    });
    expect(score).toBeCloseTo(10);
  });

  it('returns 0 when params are missing for the goal — beginner no-history case', () => {
    expect(calculateProgressScore('strength', {})).toBe(0);
    expect(calculateProgressScore('fat_loss', {})).toBe(0);
    expect(calculateProgressScore('cardio', {})).toBe(0);
  });
});
