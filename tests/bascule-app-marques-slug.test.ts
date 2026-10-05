import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

const SOURCE = readFileSync("src/app/marques/[slug]/page.tsx", 'utf8');
const ATTENDUS = ["import { chargerCatalogue } from '@/lib/catalogue-source';", "  const catalogue = await chargerCatalogue();\n  const marque = catalogue.marques.find((m) => m.slug === slug);", "produits={catalogue.produits.filter((p) => p.marque.slug === slug)}"];

describe("bascule — src/app/marques/[slug]/page.tsx", () => {
  it('lit le catalogue du site', () => {
    for (const a of ATTENDUS) expect(SOURCE, a.split('\n')[0]).toContain(a);
    expect(SOURCE).not.toContain("from '@/lib/donnees'");
  });
});
