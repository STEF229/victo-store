TICKET 112c — le carrousel montre sa photo en fond sur téléphone

Modifie `src/components/accueil/Carrousel.tsx`. Sur téléphone, la photo de la diapositive remplit le bandeau (300 px au moins), sous un dégradé sombre ; le texte, posé en bas et en blanc, reste lisible. Rien ne change au-dessus de 640 px (le dégradé y est masqué).

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
className="grid grid-cols-1 items-center gap-10 lg:grid-cols-2 max-sm:gap-0 max-sm:px-5 max-sm:pb-14 max-sm:pt-7"
```
Après :
```tsx
className="grid grid-cols-1 items-center gap-10 lg:grid-cols-2 max-sm:gap-0 max-sm:px-5 max-sm:pb-14 max-sm:pt-7 max-sm:relative max-sm:min-h-[300px] max-sm:items-end max-sm:overflow-hidden"
```

## Remplacement 2 (l'occurrence unique)
Avant :
```tsx
              <div>
                <span className="text-sm font-bold tracking-wider uppercase">
```
Après :
```tsx
              <div className="max-sm:relative max-sm:z-10 max-sm:text-[var(--vs-blanc)]">
                <span className="text-sm font-bold tracking-wider uppercase">
```

## Remplacement 3 (l'occurrence unique)
Avant :
```tsx
              <div className="max-sm:hidden">
                <img src={diapo.image} alt="" className="h-[520px] w-full rounded-[28px] object-cover" />
              </div>
```
Après :
```tsx
              <div className="max-sm:absolute max-sm:inset-0">
                <img src={diapo.image} alt="" className="h-[520px] w-full rounded-[28px] object-cover max-sm:h-full max-sm:rounded-none" />
                <span aria-hidden="true" data-testid="carrousel-degrade" className="absolute inset-0 hidden bg-[linear-gradient(180deg,rgba(16,16,20,0.05)_25%,rgba(16,16,20,0.72)_100%)] max-sm:block" />
              </div>
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
