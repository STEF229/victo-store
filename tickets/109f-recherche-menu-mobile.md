TICKET 109f — la recherche dans le menu mobile

Modifie `src/components/navigation/MenuMobile.tsx`. Sur téléphone, l'en-tête n'a pas de
champ de recherche : le menu en propose un, tout en haut du premier niveau.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Rien d'autre ne change. Aucun `<button>` de plus (la touche Entrée lance la recherche).

## Les deux changements
1. Ajoute `Search` à l'import depuis `'lucide-react'`.
2. Dans `niveau1`, **avant** le `navItems.map(…)`, ajoute exactement :
   ```tsx
   <form role="search" action="/recherche" method="get" className="my-3">
     <label htmlFor="recherche-mobile" className="sr-only">Rechercher dans la boutique</label>
     <div className="flex h-12 items-center gap-2.5 rounded-full bg-[var(--vs-surface)] px-4">
       <Search aria-hidden size={17} className="shrink-0 text-[var(--vs-gris)]" />
       <input id="recherche-mobile" name="q" type="search" placeholder="Rechercher" autoComplete="off"
         className="h-10 min-w-0 flex-1 border-none bg-transparent text-base text-[var(--vs-noir)] outline-none" />
     </div>
   </form>
   ```
   (`text-base` fait 16 px : en dessous, l'iPhone zoome sur le champ.)

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont `tests/MenuMobile.test.tsx`.
