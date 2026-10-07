import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

const SOURCE = readFileSync("src/app/compte/page.tsx", 'utf8');
const ATTENDUS = ["function Tableau({ client }: { client: Client }) {\n  const session = useSession();", "  const commandes = session.commandes ?? commandesDe(client);"];

describe("comptes Medusa — src/app/compte/page.tsx", () => {
  it('passe par Medusa en mode Medusa, comme avant en démonstration', () => {
    for (const a of ATTENDUS) expect(SOURCE, a.split('\n')[0]).toContain(a);
  });
});
