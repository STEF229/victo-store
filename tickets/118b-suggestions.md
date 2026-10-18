TICKET 118b — un clic dans les suggestions n’est plus perdu

Modifie `src/components/recherche/ChampRecherche.tsx`. Un clic dans la zone des suggestions garde le focus dans le champ : la zone ne se ferme plus avant que le clic arrive (Safari ne donne pas le focus à un lien cliqué). Les liens des produits, des marques et « Voir les résultats » fonctionnent.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** le remplacement ci-dessous, rien d'autre. L'« avant » est recopié tel qu'il est dans le
  fichier ; quand l'« après » a plus de lignes, **écris toutes ses lignes**.

## Remplacement 1 — **une ligne s'ajoute** entre `data-testid` et `className`, qui restent
Avant :
```tsx
        <div data-testid="suggestions-recherche"
          className=
```
Après :
```tsx
        <div data-testid="suggestions-recherche"
          onMouseDown={(e) => e.preventDefault()}
          className=
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
