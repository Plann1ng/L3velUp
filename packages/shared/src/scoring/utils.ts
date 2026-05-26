/**
 * Constrains a number to [min, max] inclusive.
 * Safe when min > max: returns min in that degenerate case.
 */
export function clamp(value: number, min: number, max: number): number {
  if (min > max) return min;
  return Math.max(min, Math.min(max, value));
}

/**
 * Returns ((current - baseline) / baseline) * 100.
 * Returns 0 when baseline is zero to avoid division by zero.
 * Returns 0 when either argument is NaN or Infinity.
 */
export function safePercentChange(current: number, baseline: number): number {
  if (!Number.isFinite(baseline) || baseline === 0) return 0;
  if (!Number.isFinite(current)) return 0;
  return ((current - baseline) / baseline) * 100;
}
