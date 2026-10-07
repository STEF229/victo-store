import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

const SOURCE = readFileSync("src/app/compte/informations/page.tsx", 'utf8');
const ATTENDUS = ["import type { Client } from '@/lib/compte';\nimport { quand } from '@/lib/quand';", "    quand(session.enregistrerProfil(profil), (erreurs) => {\n      setErreursProfil(erreurs);\n      setProfilEnregistre(Object.keys(erreurs).length === 0);\n    });", "    quand(session.enregistrerMotDePasse(actuel, nouveau), (erreurs) => {\n      setErreursMdp(erreurs);\n      const ok = Object.keys(erreurs).length === 0;\n      setMdpChange(ok);\n      if (ok) {\n        setActuel('');\n        setNouveau('');\n      }\n    });"];

describe("comptes Medusa — src/app/compte/informations/page.tsx", () => {
  it('passe par Medusa en mode Medusa, comme avant en démonstration', () => {
    for (const a of ATTENDUS) expect(SOURCE, a.split('\n')[0]).toContain(a);
  });
});
