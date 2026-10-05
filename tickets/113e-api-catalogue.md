TICKET 113e — le catalogue servi aux composants du navigateur

Crée `src/app/api/catalogue/route.ts`. Route `GET /api/catalogue` : renvoie le catalogue en JSON (`produits`, `marques`, `source`). Utilise `Response.json`, standard.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : recopie le fichier tel quel (il n'utilise
  aucun accès par index ; `.find`, `.filter`, `.map`, `.reduce`, `.some`).
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.

## Fichier complet
Taille attendue : ~10 lignes.
```ts
import { chargerCatalogue } from '@/lib/catalogue-source';

/** Le catalogue, pour les composants du navigateur (recherche, menus, panier). Revalidé chaque minute. */
export const revalidate = 60;

export async function GET() {
  return Response.json(await chargerCatalogue());
}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
