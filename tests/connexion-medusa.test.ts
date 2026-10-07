import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

const SOURCE = readFileSync("src/app/connexion/page.tsx", 'utf8');
const ATTENDUS = ["import { COLONNES_PIED, NAV } from '@/lib/navigation';\nimport { quand } from '@/lib/quand';\nimport { useCatalogue } from '@/components/catalogue/CatalogueProvider';", "  const session = useSession();\n  const demo = useCatalogue().source !== 'medusa';\n  const router = useRouter();", "    quand(session.connexion(courriel, motDePasse), (ok) => {\n      if (ok) {\n        setErreur(false);\n        router.push('/compte');\n      } else {\n        setErreur(true);\n      }\n    });", "            {demo && (\n              <p data-testid=\"connexion-demo\" className=\"rounded-2xl bg-[var(--vs-surface)] p-4 text-sm text-[var(--vs-noir)]\">\n                {`Compte de démonstration : ${COURRIEL_DEMO} — mot de passe ${MOT_DE_PASSE_DEMO}`}\n              </p>\n            )}"];

describe("comptes Medusa — src/app/connexion/page.tsx", () => {
  it('passe par Medusa en mode Medusa, comme avant en démonstration', () => {
    for (const a of ATTENDUS) expect(SOURCE, a.split('\n')[0]).toContain(a);
  });
});
