TICKET 110j — l'espace client, moins d'espace sous le menu sur téléphone

Modifie `src/components/compte/EspaceClient.tsx`. L'écart entre le menu et le contenu passe de 40 à 24 px sur téléphone.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier. Les classes d'origine restent toutes ; on en ajoute.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
className="grid gap-10 lg:grid-cols-[280px_minmax(0,1fr)] lg:items-start lg:gap-14"
```
Après :
```tsx
className="grid gap-10 lg:grid-cols-[280px_minmax(0,1fr)] lg:items-start lg:gap-14 max-sm:gap-6"
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
