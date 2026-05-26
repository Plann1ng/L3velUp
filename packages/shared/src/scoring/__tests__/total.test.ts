import { describe, expect, it } from 'vitest';
import type { Goal } from '../../types/user';
import { GOAL_WEIGHTS, calculateTotalScore } from '../total';

const ALL_GOALS: Goal[] = [
  'strength', 'muscle_gain', 'fat_loss', 'fitness',
  'cardio', 'power', 'mobility', 'general_health',
];

describe('GOAL_WEIGHTS', () => {
  it.each(ALL_GOALS)(
    'weights for "%s" sum to exactly 1.0',
    (goal) => {
      const w = GOAL_WEIGHTS[goal];
      expect(w.consistency + w.progress + w.performance).toBeCloseTo(1.0, 10);
    }
  );

  it('every weight is between 0 and 1 (exclusive)', () => {
    for (const goal of ALL_GOALS) {
      const w = GOAL_WEIGHTS[goal];
      expect(w.consistency).toBeGreaterThan(0);
      expect(w.consistency).toBeLessThan(1);
      expect(w.progress).toBeGreaterThan(0);
      expect(w.progress).toBeLessThan(1);
      expect(w.performance).toBeGreaterThan(0);
      expect(w.performance).toBeLessThan(1);
    }
  });

  it('fat_loss has the highest consistency weight of all goals', () => {
    for (const goal of ALL_GOALS) {
      if (goal === 'fat_loss') continue;
      expect(GOAL_WEIGHTS['fat_loss'].consistency).toBeGreaterThanOrEqual(
        GOAL_WEIGHTS[goal].consistency
      );
    }
  });

  it('strength has higher progress weight than fat_loss', () => {
    expect(GOAL_WEIGHTS['strength'].progress).toBeGreaterThan(GOAL_WEIGHTS['fat_loss'].progress);
  });
});

describe('calculateTotalScore', () => {
  // ── Edge cases: all-zero and all-100 ────────────────────────────────────
  it('returns 0 when all component scores are 0', () => {
    for (const goal of ALL_GOALS) {
      expect(
        calculateTotalScore(goal, { consistency: 0, progress: 0, performance: 0 })
      ).toBe(0);
    }
  });

  it('returns 100 when all component scores are 100', () => {
    for (const goal of ALL_GOALS) {
      expect(
        calculateTotalScore(goal, { consistency: 100, progress: 100, performance: 100 })
      ).toBe(100);
    }
  });

  // ── Correctness of weighted sum ──────────────────────────────────────────
  it('returns the correct weighted sum for strength', () => {
    // weights: consistency 0.30, progress 0.45, performance 0.25
    // scores: 80, 60, 40
    // expected: 0.30×80 + 0.45×60 + 0.25×40 = 24 + 27 + 10 = 61
    const score = calculateTotalScore('strength', {
      consistency: 80,
      progress: 60,
      performance: 40,
    });
    expect(score).toBeCloseTo(61);
  });

  it('returns the correct weighted sum for fat_loss', () => {
    // weights: consistency 0.60, progress 0.30, performance 0.10
    // scores: 80, 60, 40
    // expected: 0.60×80 + 0.30×60 + 0.10×40 = 48 + 18 + 4 = 70
    const score = calculateTotalScore('fat_loss', {
      consistency: 80,
      progress: 60,
      performance: 40,
    });
    expect(score).toBeCloseTo(70);
  });

  it('different goals produce different scores with the same inputs', () => {
    const input = { consistency: 70, progress: 50, performance: 30 };
    const strengthScore = calculateTotalScore('strength', input);
    const fatLossScore  = calculateTotalScore('fat_loss', input);
    // fat_loss weights consistency higher, so its score is higher here
    expect(fatLossScore).toBeGreaterThan(strengthScore);
  });

  // ── Out-of-range input clamping ──────────────────────────────────────────
  it('clamps component scores above 100 before applying weights', () => {
    const score = calculateTotalScore('strength', {
      consistency: 200, // should be treated as 100
      progress: 200,    // should be treated as 100
      performance: 200, // should be treated as 100
    });
    expect(score).toBe(100);
  });

  it('clamps negative component scores to 0 before applying weights', () => {
    const score = calculateTotalScore('strength', {
      consistency: -50, // treated as 0
      progress: -50,    // treated as 0
      performance: -50, // treated as 0
    });
    expect(score).toBe(0);
  });

  it('handles mixed valid and out-of-range scores correctly', () => {
    // strength weights: 0.30, 0.45, 0.25
    // consistency = 100 (clamped from 200), progress = 50, performance = 0 (clamped from -10)
    // expected = 0.30×100 + 0.45×50 + 0.25×0 = 30 + 22.5 = 52.5
    const score = calculateTotalScore('strength', {
      consistency: 200,
      progress: 50,
      performance: -10,
    });
    expect(score).toBeCloseTo(52.5);
  });

  // ── All goals produce scores in [0, 100] ─────────────────────────────────
  it.each(ALL_GOALS)(
    'score for "%s" is always between 0 and 100',
    (goal) => {
      const score = calculateTotalScore(goal, { consistency: 67, progress: 43, performance: 88 });
      expect(score).toBeGreaterThanOrEqual(0);
      expect(score).toBeLessThanOrEqual(100);
    }
  );

  // ── Real-world scenario: active beginner ─────────────────────────────────
  it('models a consistent beginner with no progress data', () => {
    // Beginner: consistent (shows up), no progress score yet (no baseline), low XP
    const score = calculateTotalScore('strength', {
      consistency: 80,
      progress: 0,     // no baseline yet
      performance: 20, // just started, low XP
    });
    // 0.30×80 + 0.45×0 + 0.25×20 = 24 + 0 + 5 = 29
    expect(score).toBeCloseTo(29);
  });

  it('models an advanced member with high all-round scores', () => {
    const score = calculateTotalScore('muscle_gain', {
      consistency: 95,
      progress: 85,
      performance: 90,
    });
    // weights: 0.35×95 + 0.45×85 + 0.20×90 = 33.25 + 38.25 + 18 = 89.5
    expect(score).toBeCloseTo(89.5);
  });
});
