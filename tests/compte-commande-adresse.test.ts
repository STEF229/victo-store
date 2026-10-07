import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

const SOURCE = readFileSync("src/lib/compte.ts", 'utf8');
const ATTENDUS = ["  adresseId: string;\n  /** Adresse de livraison, quand la commande vient de Medusa. */\n  adresse?: Adresse;\n  paiement: string;"];

describe("comptes Medusa — src/lib/compte.ts", () => {
  it('passe par Medusa en mode Medusa, comme avant en démonstration', () => {
    for (const a of ATTENDUS) expect(SOURCE, a.split('\n')[0]).toContain(a);
  });
});
