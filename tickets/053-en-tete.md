TICKET 053 — SiteHeader : style de la maquette

Modifie `src/components/ui/SiteHeader.tsx`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif. Exports **nommés**.
- **Ne modifie aucun fichier de test.** Ne crée ni ne modifie aucun autre fichier
  que celui du ticket.
- **Aucun fichier baril n'existe** : n'importe jamais depuis un dossier.
- **Classes imposées** : recopie-les en toutes lettres dans une chaîne littérale.
  Tailwind ne génère que les classes qu'il lit dans le code ; une classe construite
  par interpolation n'existera jamais. Les tests vérifient leur présence. Tu peux en
  ajouter, jamais en retirer.
- Couleurs : tokens `var(--vs-*)` en priorité (`--vs-noir`, `--vs-blanc`,
  `--vs-surface`, `--vs-ligne`, `--vs-gris`, `--vs-accent` cobalt, `--vs-promo`
  rouge). Seules ces teintes décoratives sont autorisées en valeur directe :
  `#1E1E26` `#C70026` `#E9E4DA` `#D9D2C4` `#EEF1F8` `#B5B5BA` `#FFD3DB`.
- Toute icône `<svg>` porte `aria-hidden="true"`. Toute image purement décorative
  porte `alt=""`.
- Accès aux tableaux : `t[0]` a le type `T | undefined`. Pas de `!`, pas de `as` ;
  utilise `.map`, `.filter`, `.slice` ou des constantes nommées.
- `'use client'` en première ligne **seulement** si le composant a un état ou un effet.
## Contrats existants à conserver absolument
`tests/SiteHeader.test.tsx` doit continuer à passer : rôle `banner` ; lien de
marque `data-testid="entete-marque"` vers `/` contenant `VICTO` ; **une seule**
`<nav aria-label="Navigation principale">` avec **un seul** lien par entrée ;
`data-testid="entete-panier"` vers `/panier`, `data-cart-count`, `aria-label`
`Panier, N article` ou `Panier, N articles` ; pastille
`data-testid="entete-panier-compte"` **seulement** si le panier n'est pas vide.

## Nouveautés
1. Exporte le type :
   ```ts
   export interface NavItem { label: string; href: string; promo?: boolean }
   ```
   Le `<a>` d'une entrée `promo: true` porte **lui-même** la classe imposée
   `text-[var(--vs-promo)]` ; les autres `<a>` ne l'ont pas. Le texte du lien est
   directement `label`, sans `<span>` intermédiaire.
2. Disposition en trois zones : un conteneur aux classes imposées
   `grid grid-cols-3 items-center`, qui contient dans l'ordre la navigation, la
   marque centrée, puis les actions alignées à droite.
3. La `<nav>` porte les classes imposées `hidden lg:flex`.
4. Trois boutons, tous `type="button"`, icône `<svg aria-hidden="true">`, 44 px :
   - `aria-label="Ouvrir le menu"`, classe imposée `lg:hidden`, placé dans la zone
     de gauche ; il n'ouvre rien pour l'instant et ne rend **aucune** autre liste de
     liens ;
   - `aria-label="Rechercher"` et `aria-label="Mon compte"`, dans la zone de droite,
     avant le lien panier.
5. Le lien panier contient une icône de sac `<svg aria-hidden="true">` ; la pastille
   de compte porte la classe imposée `bg-[var(--vs-accent)]`, texte blanc, ronde.
6. Marque : `VICTO STORE`, 26 px, graisse 900, lettres espacées.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
