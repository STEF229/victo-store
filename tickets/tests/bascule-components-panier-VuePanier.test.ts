import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

const SOURCE = readFileSync("src/components/panier/VuePanier.tsx", 'utf8');
const ATTENDUS = ["import { useCatalogue } from '@/components/catalogue/CatalogueProvider';", "  const panier = usePanier();\n  const catalogue = useCatalogue();", "detaillerPanier(panier.lignes, (slug) => catalogue.produits.find((p) => p.slug === slug))"];

describe("bascule — src/components/panier/VuePanier.tsx", () => {
  it('lit le catalogue du site', () => {
    for (const a of ATTENDUS) expect(SOURCE, a.split('\n')[0]).toContain(a);
    expect(SOURCE).not.toContain("from '@/lib/donnees'");
  });
});
