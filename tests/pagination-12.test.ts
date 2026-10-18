import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

describe('listes — 12 produits par page', () => {
  it('pagine par 12, divisible par 2, 3 et 4 colonnes', () => {
    expect(readFileSync('src/components/catalogue/VueCatalogue.tsx', 'utf8')).toContain('paginer(resultats, page, 12)');
  });
});
