TICKET 081 — catalogue complet

Modifie `src/lib/donnees.ts`. Chaque produit reçoit les cinq nouveaux champs, et
deux fonctions d'accès aux marques s'ajoutent.

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
## Contraintes conservées
Tout ce que vérifie `tests/donnees.test.ts` reste vrai : 6 marques, 12 produits,
identifiants et slugs uniques, au moins 4 promotions, au moins une rupture, visuels
`imageUrl` parmi `/img/pegasus.svg`, `/img/chuck70.svg`, `/img/polo.svg`.
Garde les constantes de marques nommées (`NIKE`, `ADIDAS`…) et leur réutilisation.

## Nouveaux champs, pour chacun des 12 produits
- `genre` : `'femme'`, `'homme'` ou `'mixte'`.
- `categorie` : `'chaussures'`, `'vetements'` ou `'accessoires'`, cohérente avec
  le produit (une sneaker est une chaussure, un polo un vêtement).
- `description` : deux phrases en français, **au moins 60 caractères**.
- `composition` : une phrase décrivant les matières, **au moins 20 caractères**.
- `images` : **exactement 4** chemins, dans cet ordre :
  `[imageUrl, '/img/produits/vue-2.svg', '/img/produits/vue-3.svg', '/img/produits/vue-4.svg']`.

## Répartition exigée
- au moins **4** produits pour lesquels `correspondAuGenre(p, 'femme')` est vrai ;
- au moins **4** pour `correspondAuGenre(p, 'homme')` ;
- au moins **5** produits de catégorie `'chaussures'` ;
- au moins **3** de catégorie `'vetements'`.

## Fonctions à ajouter
- `trouverMarque(slug: string): Marque | undefined`
- `produitsDeMarque(slug: string): Produit[]` — les produits dont `marque.slug`
  vaut `slug`, dans l'ordre de `PRODUITS`, en **nouveau tableau**.

## Import à utiliser
```ts
import type { Marque, Produit } from '@/lib/catalogue';
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
