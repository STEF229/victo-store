TICKET 110c — les bonnes affaires, titre en gras et cartes plus petites

Modifie `src/components/accueil/SectionBonnesAffaires.tsx`. `font-900` n'existe pas dans Tailwind : `font-black` est ajouté. « Tout voir » ne passe plus à la ligne (simple lien souligné sur téléphone) ; cartes de 170 px sur téléphone.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier. Les classes d'origine restent toutes ; on en ajoute.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
className="text-xs uppercase text-[var(--vs-promo)]"
```
Après :
```tsx
className="text-xs font-extrabold uppercase tracking-[0.14em] text-[var(--vs-promo)]"
```

## Remplacement 2 (l'occurrence unique)
Avant :
```tsx
className="text-3xl font-900 mt-1"
```
Après :
```tsx
className="text-3xl font-900 font-black tracking-tight mt-1 max-sm:text-2xl"
```

## Remplacement 3 (l'occurrence unique)
Avant :
```tsx
className="border border-[var(--vs-noir)] text-[var(--vs-noir)] px-4 py-2 rounded-full"
```
Après :
```tsx
className="border border-[var(--vs-noir)] text-[var(--vs-noir)] px-4 py-2 rounded-full shrink-0 whitespace-nowrap font-bold max-sm:border-0 max-sm:px-0 max-sm:underline max-sm:underline-offset-4"
```

## Remplacement 4 (l'occurrence unique)
Avant :
```tsx
className="flex gap-4 overflow-x-auto snap-x snap-mandatory md:grid md:grid-cols-4 md:gap-5 md:overflow-visible mt-6"
```
Après :
```tsx
className="flex gap-4 overflow-x-auto snap-x snap-mandatory md:grid md:grid-cols-4 md:gap-5 md:overflow-visible mt-6 max-sm:gap-3"
```

## Remplacement 5 (l'occurrence unique)
Avant :
```tsx
className="w-[250px] shrink-0 snap-start md:w-auto"
```
Après :
```tsx
className="w-[250px] shrink-0 snap-start md:w-auto max-sm:w-[170px]"
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
