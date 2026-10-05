import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

describe('catalogue — type de produit', () => {
  it('ajoute un champ « type » facultatif au produit', () => {
    const s = readFileSync('src/lib/catalogue.ts', 'utf8');
    const produit = s.slice(s.indexOf('export interface Produit'));
    expect(produit.slice(0, produit.indexOf('\n}'))).toContain('  type?: string;');
  });
});
