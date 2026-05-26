import { describe, expect, it } from 'vitest';
import { getLevel, getXpProgress, xpForLevel } from '../levels';

describe('xpForLevel', () => {
  it('returns 0 for level 1', () => {
    expect(xpForLevel(1)).toBe(0);
  });

  it('returns 0 for level ≤ 1', () => {
    expect(xpForLevel(0)).toBe(0);
    expect(xpForLevel(-5)).toBe(0);
  });

  it('returns 100 for level 2', () => {
    // floor(100 × (2-1)^1.8) = floor(100 × 1) = 100
    expect(xpForLevel(2)).toBe(100);
  });

  it('returns increasing values for higher levels', () => {
    expect(xpForLevel(3)).toBeGreaterThan(xpForLevel(2));
    expect(xpForLevel(10)).toBeGreaterThan(xpForLevel(5));
    expect(xpForLevel(20)).toBeGreaterThan(xpForLevel(10));
  });
});

describe('getLevel', () => {
  it('returns level 1 for 0 XP (new member)', () => {
    expect(getLevel(0)).toBe(1);
  });

  it('returns level 1 just before level 2 threshold', () => {
    expect(getLevel(99)).toBe(1);
  });

  it('returns level 2 at the level 2 threshold', () => {
    expect(getLevel(100)).toBe(2);
  });

  it('returns level 2 mid-range', () => {
    expect(getLevel(150)).toBe(2);
  });

  it('advances levels correctly', () => {
    expect(getLevel(xpForLevel(5))).toBe(5);
    expect(getLevel(xpForLevel(10))).toBe(10);
    expect(getLevel(xpForLevel(20))).toBe(20);
  });

  it('stays at the correct level just below the next threshold', () => {
    expect(getLevel(xpForLevel(5) - 1)).toBe(4);
  });
});

describe('getXpProgress', () => {
  it('returns level 1 with correct progress for 0 XP', () => {
    const p = getXpProgress(0);
    expect(p.level).toBe(1);
    expect(p.currentXp).toBe(0);
    expect(p.progress).toBe(0);
  });

  it('returns progress fraction between 0 and 1', () => {
    const p = getXpProgress(150); // level 2 starts at 100, level 3 at ~245
    expect(p.level).toBe(2);
    expect(p.progress).toBeGreaterThan(0);
    expect(p.progress).toBeLessThan(1);
  });

  it('returns progress = 0 at a level boundary', () => {
    const boundary = xpForLevel(5);
    const p = getXpProgress(boundary);
    expect(p.level).toBe(5);
    expect(p.currentXp).toBe(0);
    expect(p.progress).toBe(0);
  });

  it('returns positive nextLevelXp', () => {
    const p = getXpProgress(500);
    expect(p.nextLevelXp).toBeGreaterThan(0);
  });
});
