TICKET 100g — résumé des marques

Crée `src/lib/marques.ts`. Fonctions **pures** : aucune ne modifie ses arguments.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index ;
  utilise `.map`, `.filter`, `.sort` sur un tableau neuf.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.

## Bloc d'imports exact
```ts
import { estEnPromotion, type Marque, type Produit } from '@/lib/catalogue';
```

## Exports exacts
Taille attendue : ~30 lignes.
```ts
export interface ResumeMarque {
  marque: Marque;
  nombre: number;
  enSoldes: number;
}
export function resumerMarques(marques: Marque[], produits: Produit[]): ResumeMarque[];
export function libelleMarques(n: number): string;
export function libelleProduits(n: number): string;
```

## Règles
**`resumerMarques`** :
1. pour chaque marque `m` (avec `.map`), `const siens = produits.filter((p) => p.marque.slug === m.slug);`
   puis `{ marque: m, nombre: siens.length, enSoldes: siens.filter(estEnPromotion).length }` ;
2. garde seulement les résumés dont `nombre > 0` (`.filter`) ;
3. trie ce **nouveau** tableau par nom de marque avec
   `.sort((a, b) => a.marque.nom.localeCompare(b.marque.nom, 'fr'))`.

**`libelleMarques`** et **`libelleProduits`** renvoient exactement
```ts
`${n} ${n > 1 ? 'marques' : 'marque'}`
`${n} ${n > 1 ? 'produits' : 'produit'}`
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
