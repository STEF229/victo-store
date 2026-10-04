TICKET 110b — l'accueil, des sections moins espacées sur téléphone

Modifie `src/app/page.tsx`. Les espacements de 96 px entre sections passent à 48 px sur téléphone.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier. Les classes d'origine restent toutes ; on en ajoute.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
className="mx-auto max-w-[1440px] px-5 py-24 lg:px-20"
```
Après :
```tsx
className="mx-auto max-w-[1440px] px-5 py-24 lg:px-20 max-sm:py-12"
```

## Remplacement 2 (chacune des **deux** occurrences)
Avant :
```tsx
className="mx-auto max-w-[1440px] px-5 pb-24 lg:px-20"
```
Après :
```tsx
className="mx-auto max-w-[1440px] px-5 pb-24 lg:px-20 max-sm:pb-12"
```

## Remplacement 3 (l'occurrence unique)
Avant :
```tsx
className="mx-auto max-w-[1440px] px-5 py-14 lg:px-20"
```
Après :
```tsx
className="mx-auto max-w-[1440px] px-5 py-14 lg:px-20 max-sm:py-8"
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
