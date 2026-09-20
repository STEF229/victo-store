export function clampQuantity(value: number, min: number = 1, max: number = 99): number {
  // Validate bounds first
  if (
    typeof min !== 'number' ||
    !Number.isFinite(min) ||
    !Number.isInteger(min)
  ) {
    throw new TypeError('clampQuantity: min et max doivent être des entiers finis');
  }

  if (
    typeof max !== 'number' ||
    !Number.isFinite(max) ||
    !Number.isInteger(max)
  ) {
    throw new TypeError('clampQuantity: min et max doivent être des entiers finis');
  }

  if (min > max) {
    throw new RangeError('clampQuantity: min ne peut pas dépasser max');
  }

  // Handle invalid value
  if (
    typeof value !== 'number' ||
    Number.isNaN(value)
  ) {
    return min;
  }

  // Apply floor rounding
  const flooredValue = Math.floor(value);

  // Clamp between min and max
  return Math.min(Math.max(flooredValue, min), max);
}
