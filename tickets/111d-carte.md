TICKET 111d — les cartes d'une même ligne ont la même hauteur

Modifie `src/components/ui/ProductCard.tsx`. La carte s'étire à la hauteur de sa case : dans une ligne de la grille ou de la bande des bonnes affaires, toutes les cartes ont la même hauteur, même quand un nom tient sur deux lignes.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
className={`rounded-lg overflow-hidden bg-[var(--vs-surface)] ${className}`}
```
Après :
```tsx
className={`rounded-lg overflow-hidden bg-[var(--vs-surface)] h-full ${className}`}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
