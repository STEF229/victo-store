TICKET 098b — contexte du panier, gardé dans localStorage

Crée `src/components/panier/PanierProvider.tsx`, avec deux exports nommés :
`PanierProvider` (le fournisseur) et `usePanier` (le crochet de lecture).

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index
  (`tableau[i]`) ; utilise `.find`, `.map`, `.filter`. Première ligne : `'use client';`.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Tout le calcul passe par les fonctions de `@/lib/panier` (leurs déclarations te
  sont fournies en lecture seule) : ce fichier ne recalcule rien lui-même.
- Tout accès à `localStorage` est dans un `try { … } catch { }` : navigation
  privée ou stockage plein ne doivent jamais faire planter la page.

## Bloc d'imports exact
```tsx
'use client';

import { createContext, useContext, useEffect, useState, type ReactNode } from 'react';
import {
  ajouterAuPanier, changerQuantite, CLE_PANIER, ecrirePanier, lirePanier, nombreArticles, retirerDuPanier,
  type Panier,
} from '@/lib/panier';
```

## Contrat exporté
Taille attendue : ~70 lignes.
```ts
export interface ContextePanier {
  lignes: Panier;
  nombre: number;
  ajouter: (article: { slug: string; sku: string }, quantite: number, stock: number) => void;
  changerQuantite: (sku: string, quantite: number, stock: number) => void;
  retirer: (sku: string) => void;
  vider: () => void;
}
```
Le contexte est créé avec `createContext<ContextePanier>(…)` et une **valeur par
défaut** : `lignes` vaut `[]`, `nombre` vaut `0`, et les quatre fonctions ne font
rien. Ainsi un composant qui appelle `usePanier()` hors du fournisseur (dans un
test par exemple) voit un panier vide, sans erreur.

`export function usePanier(): ContextePanier` renvoie `useContext(...)` de ce contexte.

`export function PanierProvider({ children }: { children: ReactNode })` :
1. état `lignes` (type `Panier`), initialement `[]` ; état `pret` (booléen),
   initialement `false` ;
2. **au montage** (effet sans dépendance, tableau `[]`) : lit
   `window.localStorage.getItem(CLE_PANIER)`, passe le texte à `lirePanier`, met
   le résultat dans `lignes`, puis met `pret` à `true` ;
3. **à chaque changement de `lignes`**, seulement quand `pret` est vrai (effet
   dépendant de `[lignes, pret]`) : écrit `ecrirePanier(lignes)` sous `CLE_PANIER`.
   Tant que `pret` est faux, rien n'est écrit : sinon le panier vide du premier
   rendu écraserait le panier enregistré ;
4. les fonctions mettent à jour `lignes` **par la forme fonctionnelle**
   `setLignes((precedent) => …)` :
   `ajouter` → `ajouterAuPanier(precedent, article, quantite, stock)`,
   `changerQuantite` → `changerQuantite(precedent, sku, quantite, stock)`,
   `retirer` → `retirerDuPanier(precedent, sku)`, `vider` → `[]` ;
5. `nombre` vaut `nombreArticles(lignes)` ;
6. rend le fournisseur du contexte autour de `children`.

La fonction `changerQuantite` du contexte porte le même nom que celle importée :
à l'intérieur du composant, appelle l'importée en la qualifiant clairement, par
exemple en déclarant la fonction du contexte sous un autre nom local
(`const modifierQuantite = …`) et en la plaçant dans l'objet de contexte sous la
clé `changerQuantite`.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
