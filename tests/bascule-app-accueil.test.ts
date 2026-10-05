import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

const SOURCE = readFileSync("src/app/page.tsx", 'utf8');
const ATTENDUS = ["import { chargerCatalogue } from '@/lib/catalogue-source';", "export async function AccueilPage() {\n  const catalogue = await chargerCatalogue();\n  const bonnesAffaires = catalogue.produits.filter(estEnPromotion).slice(0, 4);", "<BandeMarques marques={catalogue.marques} />"];

describe("bascule — src/app/page.tsx", () => {
  it('lit le catalogue du site', () => {
    for (const a of ATTENDUS) expect(SOURCE, a.split('\n')[0]).toContain(a);
    expect(SOURCE).not.toContain("from '@/lib/donnees'");
  });
});
