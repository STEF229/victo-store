TICKET 111e — la bande des bonnes affaires sans barre de défilement

Modifie `src/components/accueil/SectionBonnesAffaires.tsx`. La barre de défilement grise sous les cartes est masquée : on fait défiler du doigt.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
md:overflow-visible mt-6 max-sm:gap-3"
```
Après :
```tsx
md:overflow-visible mt-6 max-sm:gap-3 [scrollbar-width:none] [&::-webkit-scrollbar]:hidden"
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
