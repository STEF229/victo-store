TICKET 111c — les sous-catégories tiennent sur une ligne qui défile, sur téléphone

Modifie `src/components/catalogue/SousCategories.tsx`. Sur téléphone : les vignettes deviennent un bandeau de carrés de 112 px qui défile, et les pastilles une seule ligne qui défile, sans barre de défilement visible. Rien ne change au-dessus de 640 px.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
className="grid grid-cols-2 gap-4 sm:grid-cols-3 lg:grid-cols-4"
```
Après :
```tsx
className="grid grid-cols-2 gap-4 sm:grid-cols-3 lg:grid-cols-4 max-sm:-mx-5 max-sm:flex max-sm:gap-3 max-sm:overflow-x-auto max-sm:px-5 [scrollbar-width:none] [&::-webkit-scrollbar]:hidden"
```

## Remplacement 2 (l'occurrence unique)
Avant :
```tsx
className="flex flex-col gap-2.5 text-[var(--vs-noir)]"
```
Après :
```tsx
className="flex flex-col gap-2.5 text-[var(--vs-noir)] max-sm:w-[112px] max-sm:shrink-0 max-sm:gap-1.5"
```

## Remplacement 3 (l'occurrence unique)
Avant :
```tsx
className="h-[150px] rounded-[20px] bg-[var(--vs-surface)]"
```
Après :
```tsx
className="h-[150px] rounded-[20px] bg-[var(--vs-surface)] max-sm:h-[112px] max-sm:rounded-[18px]"
```

## Remplacement 4 (l'occurrence unique)
Avant :
```tsx
className="text-base font-extrabold"
```
Après :
```tsx
className="text-base font-extrabold max-sm:text-sm"
```

## Remplacement 5 (l'occurrence unique)
Avant :
```tsx
className="flex flex-wrap gap-2.5"
```
Après :
```tsx
className="flex flex-wrap gap-2.5 max-sm:-mx-5 max-sm:flex-nowrap max-sm:overflow-x-auto max-sm:px-5 [scrollbar-width:none] [&::-webkit-scrollbar]:hidden"
```

## Remplacement 6 (l'occurrence unique)
Avant :
```tsx
className={`${PILULE} ${e.href === actif ? PILULE_ON : PILULE_OFF}`}
```
Après :
```tsx
className={`${PILULE} ${e.href === actif ? PILULE_ON : PILULE_OFF} max-sm:shrink-0 max-sm:whitespace-nowrap`}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
