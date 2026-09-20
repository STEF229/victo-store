export function formatPrice(cents: number): string {
  // Validate input
  if (
    typeof cents !== 'number' ||
    !Number.isFinite(cents) ||
    !Number.isInteger(cents)
  ) {
    throw new TypeError('formatPrice: cents doit être un entier fini');
  }

  // Handle negative numbers
  const isNegative = cents < 0;
  let absoluteCents = Math.abs(cents);

  // Convert to dollars and cents
  const dollars = Math.floor(absoluteCents / 100);
  const remainingCents = absoluteCents % 100;

  // Format the dollars part with thousand separators
  const dollarsStr = dollars.toString();
  let formattedDollars = '';
  
  // Add thousand separators
  for (let i = 0; i < dollarsStr.length; i++) {
    if (i > 0 && (dollarsStr.length - i) % 3 === 0) {
      formattedDollars += '\u00A0';
    }
    formattedDollars += dollarsStr[i];
  }

  // Format cents with always 2 digits
  const centsStr = remainingCents.toString().padStart(2, '0');

  // Construct the final string
  const sign = isNegative ? '-' : '';
  return `${sign}${formattedDollars},${centsStr}\u00A0$`;
}
