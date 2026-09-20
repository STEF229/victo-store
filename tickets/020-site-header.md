TICKET 020 — composant SiteHeader

Crée `src/components/ui/SiteHeader.tsx`, export nommé `SiteHeader`.

## Règles absolues (valables pour tous les tickets)
- TypeScript strict, `noUncheckedIndexedAccess` activé.
- **Exports nommés** uniquement, jamais `export default`.
- Aucune dépendance nouvelle : seulement React et ce qui existe déjà dans `src/`.
- **Ne modifie aucun fichier de test.** Les tests font foi.
- Ne crée et ne modifie aucun autre fichier que celui indiqué.
- Styles en classes Tailwind. Les couleurs passent **toujours** par les tokens
  (`text-[var(--vs-noir)]`, `bg-[var(--vs-accent)]`…), jamais de valeur en dur.
- Les attributs `data-*` et `data-testid` décrits sont un **contrat** : ils sont
  testés. Les classes Tailwind, elles, sont libres.

## Props
```ts
interface NavItem { label: string; href: string }
{ navItems: NavItem[]; cartCount?: number; className?: string }
```
Défaut : `cartCount = 0`.

## Contrat
- Racine `<header data-ui="site-header">`. Un `<header>` de premier niveau a le
  rôle `banner` : ne l'imbrique pas dans un `<main>` ou une `<section>`.
- Marque : `<a href="/" data-testid="entete-marque">` dont le texte contient
  `VICTO`. Rends le wordmark complet « VICTO STORE ».
- `<nav aria-label="Navigation principale">` contenant un `<a>` par entrée de
  `navItems`, avec le bon `href` et le `label` comme texte.
- Panier : `<a href="/panier" data-testid="entete-panier">` portant
  `data-cart-count` égal au nombre, et un `aria-label` exactement au format
  `Panier, N article` si `N <= 1`, et `Panier, N articles` si `N > 1`.
  Donc `0` donne `Panier, 0 article`.
- Pastille de compte : `<span data-testid="entete-panier-compte">` contenant le
  nombre, présente **uniquement** si `cartCount > 0`. Absente du DOM sinon.

## Style
Fond `var(--vs-blanc)`, bordure basse `var(--vs-ligne)`, wordmark en
`var(--vs-font-display)` lourd et espacé. Pastille en `var(--vs-accent)`.

## Critère de fin
`npm run typecheck` et `npm test` passent.
