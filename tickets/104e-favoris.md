TICKET 104e — favoris, gardés dans le navigateur

Crée `src/components/favoris/FavorisProvider.tsx`, avec les exports nommés
`CLE_FAVORIS`, `FavorisProvider` et `useFavoris`, et le type `ContexteFavoris`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index ;
  utilise `.includes`, `.filter`, `.every`.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Tout accès à `localStorage` est dans un `try { … } catch { }`.

## Bloc d'imports exact
```tsx
'use client';

import { createContext, useContext, useEffect, useState, type ReactNode } from 'react';
```

## Contrat
Taille attendue : ~55 lignes.
```ts
export const CLE_FAVORIS = 'victo-favoris';
export interface ContexteFavoris {
  favoris: string[];
  pret: boolean;
  estFavori: (slug: string) => boolean;
  basculer: (slug: string) => void;
}
```
**Valeur par défaut du contexte** (hors fournisseur) : `favoris: []`, `pret: true`,
`estFavori` renvoie `false`, `basculer` ne fait rien.

`export function useFavoris(): ContexteFavoris` renvoie `useContext(...)`.

`export function FavorisProvider({ children }: { children: ReactNode })` :
1. états `favoris` (`string[]`, `[]`) et `pret` (`false`) ;
2. **au montage** (effet `[]`), dans un `try` : lit `window.localStorage.getItem(CLE_FAVORIS)` ;
   si le texte existe, `const valeur: unknown = JSON.parse(texte);` puis, si
   `Array.isArray(valeur) && valeur.every((s) => typeof s === 'string')`,
   `setFavoris(valeur)` ; enfin, hors du `try`, `setPret(true)` ;
3. **quand `favoris` change**, seulement si `pret` (effet `[favoris, pret]`) :
   `setItem(CLE_FAVORIS, JSON.stringify(favoris))` ;
4. `estFavori(slug)` : `favoris.includes(slug)` ;
5. `basculer(slug)` :
   `setFavoris((f) => (f.includes(slug) ? f.filter((s) => s !== slug) : [...f, slug]))` ;
6. rend le fournisseur du contexte autour de `children`.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
