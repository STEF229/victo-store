TICKET 110h — le pied de page, aligné et aéré, sans filigrane ni devise en double sur téléphone

Modifie `src/components/ui/SiteFooter.tsx`. Marges : 48 px en haut, alignement sur la page (20 px sur téléphone, 80 px sur grand écran). Le filigrane est rogné, et masqué sur téléphone ; la devise répétée dans les mentions est masquée sur téléphone (elle reste en haut).

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier. Les classes d'origine restent toutes ; on en ajoute.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
mx-auto px-4"
```
Après :
```tsx
mx-auto px-4 pt-12 pb-8 max-sm:px-5 sm:px-10 lg:px-20 lg:pt-16"
```

## Remplacement 2 (l'occurrence unique)
Avant :
```tsx
className="select-none text-[200px] font-black leading-none text-[#1E1E26]"
```
Après :
```tsx
className="block max-w-full select-none overflow-hidden whitespace-nowrap text-[200px] font-black leading-none text-[#1E1E26] max-sm:hidden"
```

## Remplacement 3 (l'occurrence unique)
Avant :
```tsx
className="mt-8 pt-8 border-t border-[#B5B5BA] flex flex-col md:flex-row justify-between items-center"
```
Après :
```tsx
className="mt-8 pt-8 border-t border-[#B5B5BA] flex flex-col md:flex-row justify-between items-center max-sm:mt-10 max-sm:items-start"
```

## Remplacement 4 (l'occurrence unique)
Avant :
```tsx
className="text-[var(--vs-blanc)] mb-4 md:mb-0"
```
Après :
```tsx
className="text-[var(--vs-blanc)] mb-4 md:mb-0 max-sm:hidden"
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
