TICKET 109b — le filigrane du pied de page reste dans l'écran

Modifie `src/components/ui/SiteFooter.tsx`. Le grand « VICTO » en filigrane fait 200 px de
haut : sur téléphone, il est plus large que l'écran et élargit toute la page. Il est rogné
à la largeur disponible ; rien d'autre ne change.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.

## Le remplacement
Remplace exactement la valeur de classe
`select-none text-[200px] font-black leading-none text-[#1E1E26]`
par
`block max-w-full select-none overflow-hidden whitespace-nowrap text-[200px] font-black leading-none text-[#1E1E26]`
(les classes d'origine restent toutes ; quatre s'ajoutent).

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
