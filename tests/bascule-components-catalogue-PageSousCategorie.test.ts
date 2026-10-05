import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

const SOURCE = readFileSync("src/components/catalogue/PageSousCategorie.tsx", 'utf8');
const ATTENDUS = ["import type { Produit } from '@/lib/catalogue';\nimport { listerProduits } from '@/lib/donnees';", "export function PageSousCategorie({ rubrique, chemin, produits }: { rubrique: Rubrique; chemin: string[]; produits?: Produit[] | undefined }) {", "  const tous = produits ?? listerProduits();"];

describe("bascule — src/components/catalogue/PageSousCategorie.tsx", () => {
  it('lit le catalogue du site', () => {
    for (const a of ATTENDUS) expect(SOURCE, a.split('\n')[0]).toContain(a);
  });
});
