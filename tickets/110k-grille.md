TICKET 110k — les listes de produits sur deux colonnes sur téléphone

Modifie `src/components/catalogue/GrilleProduits.tsx`. Une seule colonne laissait un produit par écran : deux colonnes sur téléphone, comme les maquettes.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier. Les classes d'origine restent toutes ; on en ajoute.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
className={`grid grid-cols-1 gap-6 sm:grid-cols-2 ${COLONNES[colonnes]} ${className}`}
```
Après :
```tsx
className={`grid grid-cols-1 gap-6 sm:grid-cols-2 max-sm:grid-cols-2 max-sm:gap-x-3 max-sm:gap-y-6 ${COLONNES[colonnes]} ${className}`}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
