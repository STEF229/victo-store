TICKET 110g — les engagements, en lignes compactes sur téléphone

Modifie `src/components/accueil/Reassurance.tsx`. Sur téléphone, chaque engagement devient une ligne : l'icône à gauche, le titre et le texte à droite (enveloppés dans un `<div>`).

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier. Les classes d'origine restent toutes ; on en ajoute.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
className="grid grid-cols-1 gap-8 sm:grid-cols-3 lg:gap-12"
```
Après :
```tsx
className="grid grid-cols-1 gap-8 sm:grid-cols-3 lg:gap-12 max-sm:gap-5"
```

## Remplacement 2 (l'occurrence unique)
Avant :
```tsx
<li key={e.titre} className="flex flex-col">
```
Après :
```tsx
<li key={e.titre} className="flex flex-col max-sm:flex-row max-sm:items-start max-sm:gap-4">
```

## Remplacement 3 (l'occurrence unique)
Avant :
```tsx
className="flex items-center justify-center w-13 h-13 rounded-lg bg-[var(--vs-surface)] mb-4"
```
Après :
```tsx
className="flex items-center justify-center w-13 h-13 rounded-lg bg-[var(--vs-surface)] mb-4 shrink-0 max-sm:mb-0 max-sm:h-11 max-sm:w-11"
```

## Remplacement 4 (l'occurrence unique)
Avant :
```tsx
            <h3 className="text-lg font-bold mb-2">{e.titre}</h3>
            <p className="text-[var(--vs-gris)]">{e.texte}</p>
```
Après :
```tsx
            <div>
              <h3 className="text-lg font-bold mb-2 max-sm:mb-1 max-sm:text-base">{e.titre}</h3>
              <p className="text-[var(--vs-gris)] max-sm:text-sm">{e.texte}</p>
            </div>
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
