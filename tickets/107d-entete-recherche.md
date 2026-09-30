TICKET 107d — l'en-tête utilise le champ de recherche

Modifie `src/components/ui/SiteHeader.tsx`. Le champ de recherche actuel est
décoratif : il est remplacé par le composant `ChampRecherche`, qui garde la même
étiquette, le même identifiant et le même texte indicatif.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Rien d'autre ne change : le bouton de menu, le bouton « Rechercher » (la loupe du
  téléphone), la navigation, « Mon compte » et le panier restent tels quels.

## Les deux changements
1. Ajoute, à la suite des imports existants :
   `import { ChampRecherche } from '@/components/recherche/ChampRecherche';`
2. Remplace l'élément `<label htmlFor="recherche-entete" …>…</label>` **et** l'élément
   qui le suit, celui qui contient `<input … id="recherche-entete" …>`, par exactement :
   ```tsx
   <div className="hidden lg:block">
     <ChampRecherche />
   </div>
   ```
   Il ne doit plus rester, dans `SiteHeader.tsx`, ni `htmlFor="recherche-entete"` ni
   `id="recherche-entete"` : ils sont dans `ChampRecherche`.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont `tests/entete-v3.test.tsx`
et `tests/finitions-SiteHeader.test.tsx`.
