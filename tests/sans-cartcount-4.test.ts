import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

describe('098e4 — compteur laissé au panier', () => {
  it('ne passe plus l’attribut cartCount à l’en-tête', () => {
    expect(readFileSync('src/components/catalogue/VueCatalogue.tsx', 'utf8')).not.toMatch(/cartCount=\{/);
  });
});
