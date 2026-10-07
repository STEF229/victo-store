import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

const SOURCE = readFileSync("src/app/compte/commandes/[numero]/page.tsx", 'utf8');
const ATTENDUS = ["function Detail({ client, numero }: { client: Client; numero: string }) {\n  const session = useSession();", "  const commande = (session.commandes ?? commandesDe(client)).find((c) => c.numero === numero);", "  const adresse = commande.adresse ?? client.adresses.find((a) => a.id === commande.adresseId);"];

describe("comptes Medusa — src/app/compte/commandes/[numero]/page.tsx", () => {
  it('passe par Medusa en mode Medusa, comme avant en démonstration', () => {
    for (const a of ATTENDUS) expect(SOURCE, a.split('\n')[0]).toContain(a);
  });
});
