import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

const SOURCE = readFileSync("src/app/recherche/page.tsx", 'utf8');
const ATTENDUS = ["import { chargerCatalogue } from '@/lib/catalogue-source';", "  const catalogue = await chargerCatalogue();\n  const resultats = rechercherProduits(catalogue.produits, terme);", "{catalogue.marques.map((m) => (", "produits={catalogue.produits.slice(0, 4)}"];

describe("bascule — src/app/recherche/page.tsx", () => {
  it('lit le catalogue du site', () => {
    for (const a of ATTENDUS) expect(SOURCE, a.split('\n')[0]).toContain(a);
    expect(SOURCE).not.toContain("from '@/lib/donnees'");
  });
});
