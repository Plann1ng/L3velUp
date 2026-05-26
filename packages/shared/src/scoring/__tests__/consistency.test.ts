import { describe, expect, it } from 'vitest';
import { calculateConsistencyScore } from '../consistency';

describe('calculateConsistencyScore', () => {
  // ── Division-by-zero guards ──────────────────────────────────────────────
  it('returns 0 when targetWorkoutsPerWeek is 0', () => {
    expect(
      calculateConsistencyScore({ workoutsLogged: 5, targetWorkoutsPerWeek: 0, periodWeeks: 4 })
    ).toBe(0);
  });

  it('returns 0 when periodWeeks is 0', () => {
    expect(
      calculateConsistencyScore({ workoutsLogged: 5, targetWorkoutsPerWeek: 3, periodWeeks: 0 })
    ).toBe(0);
  });

  it('returns 0 when both target and weeks are 0', () => {
    expect(
      calculateConsistencyScore({ workoutsLogged: 5, targetWorkoutsPerWeek: 0, periodWeeks: 0 })
    ).toBe(0);
  });

  // ── No workouts logged ───────────────────────────────────────────────────
  it('returns 0 when no workouts logged', () => {
    expect(
      calculateConsistencyScore({ workoutsLogged: 0, targetWorkoutsPerWeek: 3, periodWeeks: 4 })
    ).toBe(0);
  });

  // ── Perfect adherence ────────────────────────────────────────────────────
  it('returns 100 for perfect adherence', () => {
    expect(
      calculateConsistencyScore({ workoutsLogged: 12, targetWorkoutsPerWeek: 3, periodWeeks: 4 })
    ).toBe(100);
  });

  it('returns 100 for single week, single workout target', () => {
    expect(
      calculateConsistencyScore({ workoutsLogged: 1, targetWorkoutsPerWeek: 1, periodWeeks: 1 })
    ).toBe(100);
  });

  // ── Partial adherence ────────────────────────────────────────────────────
  it('returns 50 for half of target', () => {
    expect(
      calculateConsistencyScore({ workoutsLogged: 6, targetWorkoutsPerWeek: 3, periodWeeks: 4 })
    ).toBeCloseTo(50);
  });

  it('returns ~33 for one third of target', () => {
    expect(
      calculateConsistencyScore({ workoutsLogged: 4, targetWorkoutsPerWeek: 3, periodWeeks: 4 })
    ).toBeCloseTo(33.33, 1);
  });

  it('returns ~75 for three quarters of target', () => {
    expect(
      calculateConsistencyScore({ workoutsLogged: 9, targetWorkoutsPerWeek: 3, periodWeeks: 4 })
    ).toBeCloseTo(75);
  });

  // ── Over-performance → clamped to 100 ───────────────────────────────────
  it('clamps over-performance to 100', () => {
    expect(
      calculateConsistencyScore({ workoutsLogged: 20, targetWorkoutsPerWeek: 3, periodWeeks: 4 })
    ).toBe(100);
  });

  it('clamps extreme over-performance to 100', () => {
    expect(
      calculateConsistencyScore({ workoutsLogged: 1000, targetWorkoutsPerWeek: 1, periodWeeks: 1 })
    ).toBe(100);
  });

  // ── Weekly period ────────────────────────────────────────────────────────
  it('works correctly for a weekly period', () => {
    // 3 workouts, target 3/week, 1 week → 100
    expect(
      calculateConsistencyScore({ workoutsLogged: 3, targetWorkoutsPerWeek: 3, periodWeeks: 1 })
    ).toBe(100);
    // 2 workouts, target 3/week, 1 week → 66.67
    expect(
      calculateConsistencyScore({ workoutsLogged: 2, targetWorkoutsPerWeek: 3, periodWeeks: 1 })
    ).toBeCloseTo(66.67, 1);
  });

  // ── All-time (52 weeks) ──────────────────────────────────────────────────
  it('works for annual period', () => {
    // 52 × 3 = 156 target; logged 130 → 83.33%
    expect(
      calculateConsistencyScore({
        workoutsLogged: 130,
        targetWorkoutsPerWeek: 3,
        periodWeeks: 52,
      })
    ).toBeCloseTo(83.33, 1);
  });

  // ── Negative inputs ──────────────────────────────────────────────────────
  it('returns 0 for negative workoutsLogged', () => {
    expect(
      calculateConsistencyScore({ workoutsLogged: -5, targetWorkoutsPerWeek: 3, periodWeeks: 4 })
    ).toBe(0);
  });
});
