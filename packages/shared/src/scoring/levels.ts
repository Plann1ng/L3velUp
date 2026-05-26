export function xpForLevel(level: number): number {
  if (level <= 1) return 0;
  return Math.floor(100 * Math.pow(level - 1, 1.8));
}

export function getLevel(xpTotal: number): number {
  let level = 1;
  while (xpForLevel(level + 1) <= xpTotal) {
    level++;
  }
  return level;
}

export interface XpProgress {
  level: number;
  currentXp: number;
  nextLevelXp: number;
  /** 0–1 fraction through the current level */
  progress: number;
}

export function getXpProgress(xpTotal: number): XpProgress {
  const level = getLevel(xpTotal);
  const currentLevelFloor = xpForLevel(level);
  const nextLevelCeiling = xpForLevel(level + 1);
  const currentXp = xpTotal - currentLevelFloor;
  const rangeXp = nextLevelCeiling - currentLevelFloor;
  return {
    level,
    currentXp,
    nextLevelXp: rangeXp,
    progress: rangeXp > 0 ? currentXp / rangeXp : 0,
  };
}
