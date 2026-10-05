import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

const SOURCE = readFileSync("src/components/catalogue/VueCatalogue.tsx", 'utf8');
const ATTENDUS = ["import { useCatalogue } from '@/components/catalogue/CatalogueProvider';\nimport { taillesDe } from '@/lib/donnees';", "  const catalogue = useCatalogue();\n  const [criteres, setCriteres] = useState<Criteres>({});", "tailles={taillesDe(catalogue.produits)}"];

describe("bascule — src/components/catalogue/VueCatalogue.tsx", () => {
  it('lit le catalogue du site', () => {
    for (const a of ATTENDUS) expect(SOURCE, a.split('\n')[0]).toContain(a);
  });
});
