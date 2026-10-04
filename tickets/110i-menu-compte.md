TICKET 110i — le menu de l'espace client, en pastilles défilantes sur téléphone

Modifie `src/components/compte/MenuCompte.tsx`. Sur téléphone, le menu tient sur une ligne qui défile horizontalement, au lieu de six lignes avant le contenu.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier. Les classes d'origine restent toutes ; on en ajoute.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
className="flex flex-col gap-1"
```
Après :
```tsx
className="flex flex-col gap-1 max-sm:-mx-5 max-sm:flex-row max-sm:gap-2 max-sm:overflow-x-auto max-sm:px-5 max-sm:pb-1"
```

## Remplacement 2 (l'occurrence unique)
Avant :
```tsx
className={e.cle === actif ? MENU_LIEN_ACTIF : MENU_LIEN}
```
Après :
```tsx
className={`${e.cle === actif ? MENU_LIEN_ACTIF : MENU_LIEN} max-sm:shrink-0 max-sm:whitespace-nowrap max-sm:border max-sm:border-[var(--vs-ligne)]`}
```

## Remplacement 3 (l'occurrence unique)
Avant :
```tsx
className="my-3 h-px bg-[var(--vs-ligne)]"
```
Après :
```tsx
className="my-3 h-px bg-[var(--vs-ligne)] max-sm:hidden"
```

## Remplacement 4 (l'occurrence unique)
Avant :
```tsx
className="flex h-[50px] items-center gap-3 rounded-full px-[18px] text-[15px] font-semibold text-[var(--vs-gris)]"
```
Après :
```tsx
className="flex h-[50px] items-center gap-3 rounded-full px-[18px] text-[15px] font-semibold text-[var(--vs-gris)] max-sm:shrink-0 max-sm:whitespace-nowrap"
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
