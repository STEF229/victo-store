import { readdirSync, readFileSync, statSync } from 'node:fs';
import { join } from 'node:path';
import { describe, expect, it } from 'vitest';

// Garde permanente : tout var(--vs-…) employé dans src/ doit être défini dans le
// fichier généré par `npm run tokens`. Un jeton inventé donne une couleur vide,
// invisible pour jsdom : c'est ainsi que les pastilles du 093 sont devenues blanc
// sur blanc (--vs-principal, --vs-fond).
const JETONS = new Set(
  Array.from(readFileSync('src/styles/tokens.css', 'utf8').matchAll(/(--vs-[a-z0-9-]+)\s*:/g), (m) => m[1] ?? ''),
);

// Fichiers couverts par leur propre test en attendant leur ticket.
// FiltresBarre.tsx : tickets/tests/FiltresBarre-v2.test.tsx (ticket 095).
const EN_ATTENTE = new Set(['src/components/catalogue/FiltresBarre.tsx']);

function sources(dossier: string): string[] {
  return readdirSync(dossier).flatMap((nom) => {
    const chemin = join(dossier, nom);
    if (statSync(chemin).isDirectory()) return sources(chemin);
    return /\.(ts|tsx)$/.test(nom) ? [chemin.split('\\').join('/')] : [];
  });
}

describe('garde — jetons de couleur', () => {
  it('lit les jetons générés', () => {
    expect(JETONS.has('--vs-noir')).toBe(true);
  });

  it("n'emploie dans src/ que des jetons définis", () => {
    const inconnus = sources('src')
      .filter((f) => !EN_ATTENTE.has(f))
      .flatMap((f) =>
        Array.from(readFileSync(f, 'utf8').matchAll(/var\((--vs-[a-z0-9-]+)\)/g), (m) => m[1] ?? '')
          .filter((j) => !JETONS.has(j))
          .map((j) => `${f} : ${j}`),
      );
    expect([...new Set(inconnus)]).toEqual([]);
  });
});
