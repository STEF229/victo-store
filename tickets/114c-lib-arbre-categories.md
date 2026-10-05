TICKET 114c — l’arbre lit le vrai type du produit, et gagne Survêtements

Modifie `src/lib/arbre-categories.ts`. Le type d'un produit vient d'abord de Medusa (`p.type`), sinon du classement de démonstration ; Survêtements rejoint les vêtements, comme dans Medusa.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
feuille('vestes', 'Vestes')] },
```
Après :
```tsx
feuille('vestes', 'Vestes'), feuille('survetements', 'Survêtements')] },
```

## Remplacement 2 (chacune des **deux** occurrences)
Avant :
```tsx
TYPES_DEMO[p.slug] === type
```
Après :
```tsx
(p.type ?? TYPES_DEMO[p.slug]) === type
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
