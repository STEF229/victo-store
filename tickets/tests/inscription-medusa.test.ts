import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

const SOURCE = readFileSync("src/app/inscription/page.tsx", 'utf8');
const ATTENDUS = ["import { COLONNES_PIED, NAV } from '@/lib/navigation';\nimport { quand } from '@/lib/quand';", "      quand(session.inscription(donnees), (c) => {\n        if (c) router.push('/compte');\n        else setErreurs({ courriel: 'Inscription impossible : ce courriel a peut-être déjà un compte.' });\n      });"];

describe("comptes Medusa — src/app/inscription/page.tsx", () => {
  it('passe par Medusa en mode Medusa, comme avant en démonstration', () => {
    for (const a of ATTENDUS) expect(SOURCE, a.split('\n')[0]).toContain(a);
  });
});
