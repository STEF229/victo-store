TICKET 109e — les liens du méga-menu changent de couleur au survol

Modifie `src/components/navigation/NavigationPrincipale.tsx`. Au survol, les liens des
panneaux passent en bleu (`--vs-accent`), avec une transition douce. Rien d'autre ne change.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Les classes existantes restent toutes : tu **ajoutes** seulement
  ` transition-colors hover:text-[var(--vs-accent)]` à la fin de chacune des six valeurs
  de classe ci-dessous.

## Les six valeurs de classe, et leur nouvelle forme
| Lien | Avant | Après |
| --- | --- | --- |
| « Tout voir … » (en-tête du panneau) | `flex items-center gap-1.5 text-[15px] font-extrabold` | `flex items-center gap-1.5 text-[15px] font-extrabold transition-colors hover:text-[var(--vs-accent)]` |
| vignette d'une marque | `flex h-[110px] items-center justify-center rounded-[18px] bg-[var(--vs-surface)] text-lg font-black tracking-wide` | `flex h-[110px] items-center justify-center rounded-[18px] bg-[var(--vs-surface)] text-lg font-black tracking-wide transition-colors hover:text-[var(--vs-accent)]` |
| vignette de Chaussures | `flex flex-col gap-2.5` | `flex flex-col gap-2.5 transition-colors hover:text-[var(--vs-accent)]` |
| titre d'une sous-catégorie | `mb-1.5 text-base font-black` | `mb-1.5 text-base font-black transition-colors hover:text-[var(--vs-accent)]` |
| sous-sous-catégorie | `py-1.5 text-[15px] font-medium` | `py-1.5 text-[15px] font-medium transition-colors hover:text-[var(--vs-accent)]` |
| « Tout … » d'une colonne | `mt-1.5 text-sm font-bold text-[var(--vs-gris)] underline` | `mt-1.5 text-sm font-bold text-[var(--vs-gris)] underline transition-colors hover:text-[var(--vs-accent)]` |

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont `tests/NavigationPrincipale.test.tsx`.
