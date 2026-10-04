TICKET 110f — le champ de l'infolettre garde sa hauteur sur téléphone

Modifie `src/components/accueil/Infolettre.tsx`. Dans le formulaire en colonne (téléphone), `flex-1` réduisait la hauteur du champ à presque rien : `max-sm:flex-none` lui rend ses 56 px.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier. Les classes d'origine restent toutes ; on en ajoute.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
className="h-14 w-full min-w-0 flex-1 rounded-full bg-[var(--vs-blanc)] px-6 text-[var(--vs-noir)] focus:outline-none focus:ring-2 focus:ring-[var(--vs-noir)]"
```
Après :
```tsx
className="h-14 w-full min-w-0 flex-1 rounded-full bg-[var(--vs-blanc)] px-6 text-[var(--vs-noir)] focus:outline-none focus:ring-2 focus:ring-[var(--vs-noir)] max-sm:flex-none"
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
