TICKET 108f — la page Chaussures affiche ses sous-catégories

Modifie `src/app/chaussures/page.tsx`. La page est correcte et testée : elle garde exactement son
titre, sa description et ses produits ; elle ajoute seulement ses sous-catégories en
vignettes, sous le titre.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Un seul export : l'export par défaut, inchangé. Pas de `'use client'`.

## Les deux changements
1. Ajoute, à la suite des imports existants :
   ```tsx
   import { SousCategories } from '@/components/catalogue/SousCategories';
   import { sousCategories } from '@/lib/arbre-categories';
   ```
   (`listerProduits` est déjà importé depuis `'@/lib/donnees'` ; s'il ne l'est pas, ajoute-le.)
2. Sur l'élément `<VueCatalogue …>`, ajoute l'attribut exactement :
   ```tsx
   entete={<SousCategories titre="Sous-catégories de Chaussures" forme="vignettes" elements={sousCategories(listerProduits(), 'chaussures', [])} />}
   ```
   Ses autres attributs ne changent pas.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
