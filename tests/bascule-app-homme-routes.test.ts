import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

const SOURCE = readFileSync("src/app/homme/[...chemin]/page.tsx", 'utf8');
const ATTENDUS = ["import { PageSousCategorie } from '@/components/catalogue/PageSousCategorie';\nimport { chargerCatalogue } from '@/lib/catalogue-source';", "  const { produits } = await chargerCatalogue();\n  return <PageSousCategorie rubrique=\"homme\" chemin={chemin} produits={produits} />;"];

describe("bascule — src/app/homme/[...chemin]/page.tsx", () => {
  it('lit le catalogue du site', () => {
    for (const a of ATTENDUS) expect(SOURCE, a.split('\n')[0]).toContain(a);
    expect(SOURCE).not.toContain("from '@/lib/donnees'");
  });
});
