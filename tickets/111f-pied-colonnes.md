TICKET 111f — le pied de page, Boutique et Aide côte à côte sur téléphone

Modifie `src/components/ui/SiteFooter.tsx`. Sous 768 px, les colonnes « Boutique » et « Aide » sont côte à côte au lieu d'être empilées.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
className="grid grid-cols-1 md:grid-cols-2 gap-8"
```
Après :
```tsx
className="grid grid-cols-1 md:grid-cols-2 gap-8 max-md:grid-cols-2 max-md:gap-6"
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
