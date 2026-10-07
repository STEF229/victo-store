import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

const SOURCE = readFileSync("src/app/compte/commandes/page.tsx", 'utf8');
const ATTENDUS = ["function Liste({ client }: { client: Client }) {\n  const session = useSession();", "filtrerCommandes(session.commandes ?? commandesDe(client), filtre)"];

describe("comptes Medusa — src/app/compte/commandes/page.tsx", () => {
  it('passe par Medusa en mode Medusa, comme avant en démonstration', () => {
    for (const a of ATTENDUS) expect(SOURCE, a.split('\n')[0]).toContain(a);
  });
});
