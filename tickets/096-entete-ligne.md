TICKET 096 — repère de test sur la rangée de l'en-tête

Modifie `src/components/ui/SiteHeader.tsx`. Un seul changement : la rangée en
grille de la barre noire reçoit un `data-testid`. Rien d'autre ne bouge.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif. Exports inchangés.
- **Ne modifie aucun test.** Ne modifie aucun autre fichier que celui du ticket.
- **Garde le bloc d'imports actuel du fichier à l'identique**, ligne pour ligne.
- Ne change aucune classe, aucun texte, aucun autre attribut, aucune prop.

## Le changement
L'élément qui porte les classes `grid`, `h-20`, `grid-cols-[auto_1fr_auto]` et
`items-center` reçoit l'attribut `data-testid="entete-ligne"`. C'est le seul
élément de ce type dans le fichier. Il reste à l'intérieur de l'élément
`data-testid="entete"`, à la même place.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent ;
`tests/entete-v3.test.tsx` est vert.
