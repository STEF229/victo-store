TICKET 098e2 — laisser le panier fixer le compteur

Modifie `src/app/design/page.tsx`. Un seul changement : sur chaque élément `<SiteHeader`
de ce fichier, retire l'attribut `cartCount`, avec sa valeur. Rien d'autre ne
change : ni les autres attributs, ni les imports, ni les exports.

L'en-tête lit désormais le nombre d'articles du panier ; une valeur passée ici
l'écraserait et figerait le compteur.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Garde le fichier identique à la lettre, en dehors de cet attribut.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
