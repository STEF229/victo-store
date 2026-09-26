TICKET 099a — logique de la fiche produit

Crée `src/lib/fiche-produit.ts`. Fonctions **pures** : aucune ne modifie ses
arguments.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index
  (`tableau[i]`) ; utilise `.find`, `.map`, `.filter`, `.slice`.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- **Aucun fichier baril n'existe.**

## Bloc d'imports exact
```ts
import { hrefMarque, LIBELLES_CATEGORIE, type Produit } from '@/lib/catalogue';
```

## Exports exacts
Taille attendue : ~55 lignes.
```ts
export interface ElementFil {
  label: string;
  href?: string;
}
export const TEXTE_LIVRAISON =
  "Expédiée du Québec sous 48 heures, livraison offerte partout au Canada. Retours gratuits pendant 30 jours, article non porté dans sa boîte d'origine.";

export function filAriane(produit: Produit): ElementFil[];
export function texteStockBas(produit: Produit, taille: string | null): string | null;
export function produitsSimilaires(produit: Produit, tous: Produit[], nombre?: number): Produit[];
```

## Règles
**`filAriane`** renvoie, dans cet ordre :
1. `{ label: 'Accueil', href: '/' }` ;
2. seulement si `produit.categorie` est défini : si c'est `'chaussures'`,
   `{ label: LIBELLES_CATEGORIE[produit.categorie], href: '/chaussures' }` ; sinon
   `{ label: LIBELLES_CATEGORIE[produit.categorie] }`, **sans clé `href`** ;
3. `{ label: produit.marque.nom, href: hrefMarque(produit.marque) }` ;
4. `{ label: produit.nom }`, sans clé `href`.

Un élément sans lien ne contient pas la clé `href` du tout (pas `href: undefined`).

**`texteStockBas`** :
- `taille` vaut `null` → `null` ;
- `const variante = produit.variantes.find((v) => v.taille === taille);` ; si elle
  n'existe pas, ou si `variante.stock <= 0`, ou si `variante.stock > 3` → `null` ;
- sinon, avec `n = variante.stock`, renvoie exactement
  ```ts
  `Plus que ${n} ${unite} en ${taille}`
  ```
  où `unite` vaut, pour `produit.categorie === 'chaussures'`,
  `n > 1 ? 'paires' : 'paire'`, et pour toute autre catégorie (ou aucune),
  `n > 1 ? 'pièces' : 'pièce'`.

**`produitsSimilaires`** (`nombre` vaut 4 par défaut) :
1. `autres` = `tous` sans le produit lui-même (comparaison par `id`) ;
2. d'abord les `autres` de la même `categorie` que le produit, dans leur ordre,
   puis les `autres` d'une catégorie différente, dans leur ordre ;
3. renvoie les `nombre` premiers avec `.slice(0, nombre)`.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
