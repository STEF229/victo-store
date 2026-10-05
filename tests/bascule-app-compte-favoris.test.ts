import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

const SOURCE = readFileSync("src/app/compte/favoris/page.tsx", 'utf8');
const ATTENDUS = ["import { useCatalogue } from '@/components/catalogue/CatalogueProvider';", "  const favoris = useFavoris();\n  const catalogue = useCatalogue();\n  const produits = favoris.favoris.flatMap((slug) => {\n    const p = catalogue.produits.find((x) => x.slug === slug);"];

describe("bascule — src/app/compte/favoris/page.tsx", () => {
  it('lit le catalogue du site', () => {
    for (const a of ATTENDUS) expect(SOURCE, a.split('\n')[0]).toContain(a);
    expect(SOURCE).not.toContain("from '@/lib/donnees'");
  });
});
