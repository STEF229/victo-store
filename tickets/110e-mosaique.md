TICKET 110e — la mosaïque des catégories, lisible sur téléphone

Modifie `src/components/accueil/MosaiqueCategories.tsx`. Titres en gras (`font-black`), marge sous « Par catégorie », flèches visibles (icône blanche sur rond noir, noire sur rond blanc), texte blanc sur la carte Soldes (la classe d'origine contient une faute de frappe : la bonne est ajoutée à côté), libellés plus petits sur téléphone.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier. Les classes d'origine restent toutes ; on en ajoute.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
className="text-3xl font-900">Par catégorie
```
Après :
```tsx
className="text-3xl font-900 font-black tracking-tight mb-6 max-sm:mb-4 max-sm:text-2xl">Par catégorie
```

## Remplacement 2 (chacune des **deux** occurrences)
Avant :
```tsx
className="relative flex h-full min-h-[190px] flex-col justify-end p-7"
```
Après :
```tsx
className="relative flex h-full min-h-[190px] flex-col justify-end p-7 max-sm:min-h-[160px] max-sm:p-5"
```

## Remplacement 3 (l'occurrence unique)
Avant :
```tsx
className="text-3xl font-900 relative"
```
Après :
```tsx
className="text-3xl font-900 font-black relative max-sm:text-lg"
```

## Remplacement 4 (l'occurrence unique)
Avant :
```tsx
className="flex h-12 w-12 items-center justify-center rounded-full bg-[var(--vs-noir)]"
```
Après :
```tsx
className="flex h-12 w-12 items-center justify-center rounded-full bg-[var(--vs-noir)] text-[var(--vs-blanc)] max-sm:h-10 max-sm:w-10"
```

## Remplacement 5 (l'occurrence unique)
Avant :
```tsx
className="flex h-12 w-12 items-center justify-center rounded-full bg-[var(--vs-blanc)]"
```
Après :
```tsx
className="flex h-12 w-12 items-center justify-center rounded-full bg-[var(--vs-blanc)] text-[var(--vs-noir)] max-sm:h-10 max-sm:w-10"
```

## Remplacement 6 (l'occurrence unique)
Avant :
```tsx
text-[var(--vs-blanc])">
```
Après :
```tsx
text-[var(--vs-blanc]) text-[var(--vs-blanc)]">
```

## Remplacement 7 (l'occurrence unique)
Avant :
```tsx
className="text-sm uppercase"
```
Après :
```tsx
className="text-sm font-extrabold uppercase tracking-[0.14em]"
```

## Remplacement 8 (l'occurrence unique)
Avant :
```tsx
className="text-4xl font-900"
```
Après :
```tsx
className="text-4xl font-900 font-black max-sm:text-[28px]"
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
