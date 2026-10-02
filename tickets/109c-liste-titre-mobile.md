TICKET 109c — sur téléphone, le compteur passe sous le titre de la liste

Modifie `src/components/catalogue/VueCatalogue.tsx`. Une seule valeur de classe change.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.

## Le remplacement
Sur le `<div>` qui contient le titre (`data-testid="liste-titre"`) et le compteur
(`data-testid="compteur"`), remplace exactement
`className="flex items-end justify-between gap-8"`
par
`className="flex items-end justify-between gap-8 max-sm:flex-col max-sm:items-start max-sm:gap-3"`
(au-dessus de 640 px, rien ne change ; en dessous, le compteur passe sous le titre).

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont les tests de `VueCatalogue`.
