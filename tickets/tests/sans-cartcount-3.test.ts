import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

describe('098e3 — compteur laissé au panier', () => {
  it('ne passe plus cartCount à l’en-tête', () => {
    expect(readFileSync('src/app/page.tsx', 'utf8')).not.toContain('cartCount');
  });
});
