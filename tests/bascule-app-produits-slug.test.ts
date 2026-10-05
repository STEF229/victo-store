import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

const SOURCE = readFileSync("src/app/produits/[slug]/page.tsx", 'utf8');
const ATTENDUS = ["import { chargerCatalogue } from '@/lib/catalogue-source';", "  const catalogue = await chargerCatalogue();\n  const produit = catalogue.produits.find((p) => p.slug === slug);", "produitsSimilaires(produit, catalogue.produits)"];

describe("bascule — src/app/produits/[slug]/page.tsx", () => {
  it('lit le catalogue du site', () => {
    for (const a of ATTENDUS) expect(SOURCE, a.split('\n')[0]).toContain(a);
    expect(SOURCE).not.toContain("from '@/lib/donnees'");
  });
});
