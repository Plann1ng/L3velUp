import { describe, expect, it } from 'vitest';
import { clamp, safePercentChange } from '../utils';

describe('clamp', () => {
  it('returns the value when within range', () => {
    expect(clamp(50, 0, 100)).toBe(50);
    expect(clamp(0, 0, 100)).toBe(0);
    expect(clamp(100, 0, 100)).toBe(100);
  });

  it('clamps values below min', () => {
    expect(clamp(-10, 0, 100)).toBe(0);
    expect(clamp(-0.001, 0, 100)).toBe(0);
  });

  it('clamps values above max', () => {
    expect(clamp(150, 0, 100)).toBe(100);
    expect(clamp(100.001, 0, 100)).toBe(100);
  });

  it('handles min === max', () => {
    expect(clamp(50, 5, 5)).toBe(5);
    expect(clamp(0, 5, 5)).toBe(5);
  });

  it('handles negative ranges', () => {
    expect(clamp(-50, -100, -10)).toBe(-50);
    expect(clamp(0, -100, -10)).toBe(-10);
    expect(clamp(-200, -100, -10)).toBe(-100);
  });

  it('handles decimal precision', () => {
    expect(clamp(0.5, 0, 1)).toBeCloseTo(0.5);
    expect(clamp(1.5, 0, 1)).toBeCloseTo(1);
  });
});

describe('safePercentChange', () => {
  it('returns correct percent increase', () => {
    expect(safePercentChange(110, 100)).toBeCloseTo(10);
    expect(safePercentChange(150, 100)).toBeCloseTo(50);
    expect(safePercentChange(200, 100)).toBeCloseTo(100);
  });

  it('returns correct percent decrease', () => {
    expect(safePercentChange(90, 100)).toBeCloseTo(-10);
    expect(safePercentChange(50, 100)).toBeCloseTo(-50);
    expect(safePercentChange(0, 100)).toBeCloseTo(-100);
  });

  it('returns 0 for no change', () => {
    expect(safePercentChange(100, 100)).toBe(0);
    expect(safePercentChange(0, 0)).toBe(0);
  });

  it('returns 0 when baseline is 0 — division-by-zero guard', () => {
    expect(safePercentChange(50, 0)).toBe(0);
    expect(safePercentChange(0, 0)).toBe(0);
    expect(safePercentChange(-10, 0)).toBe(0);
  });

  it('handles non-finite inputs safely', () => {
    expect(safePercentChange(Infinity, 100)).toBe(0);
    expect(safePercentChange(100, Infinity)).toBe(0);
    expect(safePercentChange(NaN, 100)).toBe(0);
    expect(safePercentChange(100, NaN)).toBe(0);
  });

  it('handles fractional values', () => {
    expect(safePercentChange(1.1, 1.0)).toBeCloseTo(10);
    expect(safePercentChange(0.5, 1.0)).toBeCloseTo(-50);
  });
});
