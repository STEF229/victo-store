TICKET 115b — la route de la passerelle

Crée `src/app/api/medusa/[...chemin]/route.ts`. Le dossier s'appelle exactement `[...chemin]`. Chaque méthode (GET, POST, DELETE) confie la requête à la passerelle.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index, le fichier utilise
  `.find`, `.map`, `.filter`, `.some` et la déstructuration, jamais `t[i]`. Recopie-le tel quel.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.

## Fichier complet
Taille attendue : ~10 lignes.
```ts
import { relayer } from '@/lib/medusa/passerelle';

type Contexte = { params: Promise<{ chemin: string[] }> };

export async function GET(requete: Request, contexte: Contexte) {
  return relayer(requete, (await contexte.params).chemin);
}
export const POST = GET;
export const DELETE = GET;
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
