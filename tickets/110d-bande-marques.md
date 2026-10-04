TICKET 110d — la bande des marques, en gras et plus basse sur téléphone

Modifie `src/components/accueil/BandeMarques.tsx`. `font-900` n'existe pas dans Tailwind : `font-black` est ajouté.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier. Les classes d'origine restent toutes ; on en ajoute.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
className="overflow-hidden border-b border-[var(--vs-ligne)] h-24"
```
Après :
```tsx
className="overflow-hidden border-b border-[var(--vs-ligne)] h-24 max-sm:h-16"
```

## Remplacement 2 (chacune des **deux** occurrences)
Avant :
```tsx
className="uppercase text-[26px] font-900"
```
Après :
```tsx
className="uppercase text-[26px] font-900 font-black tracking-wide max-sm:text-lg"
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
