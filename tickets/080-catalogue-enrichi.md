TICKET 080 — modèle de domaine : genre, catégorie, fiche

Modifie `src/lib/catalogue.ts`. Ajoute ce que la fiche produit et les pages de
catégorie consomment, **sans rien casser** : tout le reste du fichier reste identique.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif. Exports **nommés**, sauf
  les fichiers `page.tsx` qui n'ont **qu'un export par défaut**.
- **Ne modifie aucun fichier de test.** Ne modifie aucun autre fichier que celui du ticket.
- **Aucun fichier baril n'existe.** N'importe que des modules réels ; leurs
  déclarations de types exactes te sont fournies en lecture seule.
- Icônes : uniquement `lucide-react`, avec `aria-hidden`.
- Classes imposées en toutes lettres ; les tests les vérifient.
- Accès aux tableaux : `t[0]` est `T | undefined` ; pas de `!` ni de `as`.
- **Les tests existants qui touchent ce fichier doivent rester verts.**
## Ajouts exacts

```ts
export type Genre = 'femme' | 'homme' | 'mixte';
export type Categorie = 'chaussures' | 'vetements' | 'accessoires';

export const LIBELLES_CATEGORIE: Record<Categorie, string> = {
  chaussures: 'Chaussures',
  vetements: 'Vêtements',
  accessoires: 'Accessoires',
};
```

Dans l'interface `Produit` existante, ajoute ces cinq champs, **tous optionnels** :
```ts
  genre?: Genre;
  categorie?: Categorie;
  description?: string;
  composition?: string;
  images?: string[];
```
Ils doivent rester optionnels : de nombreux tests construisent des produits sans eux,
et les rendre obligatoires ferait échouer toute la suite.

## Fonctions à ajouter

- `imagesProduit(produit: Produit): string[]` — une **copie** de `produit.images`
  si ce tableau existe et n'est pas vide, sinon `[produit.imageUrl]`.
- `correspondAuGenre(produit: Produit, genre: 'femme' | 'homme'): boolean` — vrai si
  `produit.genre` vaut `genre` **ou** `'mixte'`. Un produit sans genre ne
  correspond à aucun.
- `economieCents(produit: Produit): number` — `prixCompareCents - prixCents` si
  `estEnPromotion(produit)`, sinon `0`.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
