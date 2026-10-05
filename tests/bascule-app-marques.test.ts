import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

const SOURCE = readFileSync("src/app/marques/page.tsx", 'utf8');
const ATTENDUS = ["import { chargerCatalogue } from '@/lib/catalogue-source';", "export default async function PageMarques() {\n  const { produits, marques } = await chargerCatalogue();\n  const resumes = resumerMarques(marques, produits);"];

describe("bascule — src/app/marques/page.tsx", () => {
  it('lit le catalogue du site', () => {
    for (const a of ATTENDUS) expect(SOURCE, a.split('\n')[0]).toContain(a);
    expect(SOURCE).not.toContain("from '@/lib/donnees'");
  });
});
