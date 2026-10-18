TICKET 118a — des pages de 12 produits, pour des lignes toujours pleines

Modifie `src/components/catalogue/VueCatalogue.tsx`. La grille a 2, 3 ou 4 colonnes selon l'écran ; 12 se divise par chacun, donc chaque page n'a que des lignes pleines (avec 6, une ligne de 4 puis une ligne de 2).

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** le remplacement ci-dessous, rien d'autre. L'« avant » est recopié tel qu'il est dans le
  fichier ; quand l'« après » a plus de lignes, **écris toutes ses lignes**.

## Remplacement 1 — 12 produits par page au lieu de 6
Avant :
```tsx
  const pagine = paginer(resultats, page, 6);
```
Après :
```tsx
  const pagine = paginer(resultats, page, 12);
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
