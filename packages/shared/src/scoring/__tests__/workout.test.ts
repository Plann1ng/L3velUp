import { describe, expect, it } from 'vitest';
import {
  calculateStrengthVolume,
  calculateVolume,
  epley1RM,
  isPersonalRecord,
} from '../workout';

describe('epley1RM', () => {
  it('returns weight unchanged for a single rep', () => {
    expect(epley1RM(100, 1)).toBe(100);
    expect(epley1RM(140, 1)).toBe(140);
  });

  it('estimates 1RM correctly for 5 reps', () => {
    // 100 × (1 + 5/30) = 100 × 1.1667 = 116.67
    expect(epley1RM(100, 5)).toBeCloseTo(116.67, 1);
  });

  it('estimates 1RM correctly for 10 reps', () => {
    // 80 × (1 + 10/30) = 80 × 1.333 = 106.67
    expect(epley1RM(80, 10)).toBeCloseTo(106.67, 1);
  });

  it('returns 0 for zero weight', () => {
    expect(epley1RM(0, 5)).toBe(0);
  });

  it('returns 0 for zero reps', () => {
    expect(epley1RM(100, 0)).toBe(0);
  });

  it('returns 0 for negative values', () => {
    expect(epley1RM(-100, 5)).toBe(0);
    expect(epley1RM(100, -5)).toBe(0);
  });
});

describe('calculateStrengthVolume', () => {
  it('returns 0 for empty array', () => {
    expect(calculateStrengthVolume([])).toBe(0);
  });

  it('returns 0 when all values are null', () => {
    expect(calculateStrengthVolume([{ reps: null, weightKg: null }])).toBe(0);
  });

  it('calculates volume for a single set', () => {
    expect(calculateStrengthVolume([{ reps: 10, weightKg: 50 }])).toBe(500);
  });

  it('sums volume across multiple sets', () => {
    const sets = [
      { reps: 5, weightKg: 100 }, // 500
      { reps: 8, weightKg: 80 },  // 640
      { reps: 10, weightKg: 60 }, // 600
    ];
    expect(calculateStrengthVolume(sets)).toBe(1740);
  });

  it('skips sets with null reps', () => {
    expect(calculateStrengthVolume([{ reps: null, weightKg: 50 }])).toBe(0);
  });

  it('skips sets with null weight', () => {
    expect(calculateStrengthVolume([{ reps: 10, weightKg: null }])).toBe(0);
  });

  it('skips sets with zero weight (bodyweight marker)', () => {
    expect(calculateStrengthVolume([{ reps: 10, weightKg: 0 }])).toBe(0);
  });

  it('skips sets with zero reps', () => {
    expect(calculateStrengthVolume([{ reps: 0, weightKg: 50 }])).toBe(0);
  });

  it('handles mixed valid and invalid sets', () => {
    const sets = [
      { reps: 5, weightKg: 100 }, // 500 — valid
      { reps: null, weightKg: 80 }, // skip
      { reps: 8, weightKg: 0 },   // skip — zero weight
      { reps: 10, weightKg: 60 }, // 600 — valid
    ];
    expect(calculateStrengthVolume(sets)).toBe(1100);
  });
});

describe('calculateVolume (general)', () => {
  it('includes bodyweight sets (weightKg = 0) unlike calculateStrengthVolume', () => {
    // calculateVolume does NOT skip zero-weight sets
    expect(calculateVolume([{ reps: 10, weightKg: 0 }])).toBe(0);
  });

  it('returns correct total for standard sets', () => {
    expect(calculateVolume([{ reps: 5, weightKg: 100 }, { reps: 8, weightKg: 80 }])).toBe(1140);
  });
});

describe('isPersonalRecord', () => {
  // ── Beginner first-ever set ──────────────────────────────────────────────
  it('returns true for first ever set (empty history)', () => {
    expect(isPersonalRecord({ weightKg: 100, reps: 5 }, [])).toBe(true);
  });

  // ── Null / invalid current set ───────────────────────────────────────────
  it('returns false when currentSet has null weight', () => {
    expect(isPersonalRecord({ weightKg: null, reps: 5 }, [])).toBe(false);
  });

  it('returns false when currentSet has null reps', () => {
    expect(isPersonalRecord({ weightKg: 100, reps: null }, [])).toBe(false);
  });

  it('returns false when currentSet has zero weight', () => {
    expect(isPersonalRecord({ weightKg: 0, reps: 5 }, [])).toBe(false);
  });

  // ── Clear new PR ─────────────────────────────────────────────────────────
  it('returns true when current 1RM is higher than all history', () => {
    const history = [
      { weightKg: 90, reps: 5 },  // Epley ~108
      { weightKg: 95, reps: 3 },  // Epley ~104.5
    ];
    // 100 × (1 + 5/30) ≈ 116.67 — beats all history
    expect(isPersonalRecord({ weightKg: 100, reps: 5 }, history)).toBe(true);
  });

  // ── Not a PR ─────────────────────────────────────────────────────────────
  it('returns false when a history set has a higher 1RM', () => {
    const history = [{ weightKg: 120, reps: 1 }]; // Epley = 120
    // 100 × (1 + 5/30) ≈ 116.67 — does NOT beat 120
    expect(isPersonalRecord({ weightKg: 100, reps: 5 }, history)).toBe(false);
  });

  it('returns false for a repeated identical set', () => {
    const history = [{ weightKg: 100, reps: 5 }];
    expect(isPersonalRecord({ weightKg: 100, reps: 5 }, history)).toBe(false);
  });

  // ── History with invalid sets ────────────────────────────────────────────
  it('treats null-weight history sets as cleared — new set beats them', () => {
    const history = [{ weightKg: null, reps: 5 }];
    expect(isPersonalRecord({ weightKg: 50, reps: 1 }, history)).toBe(true);
  });
});
