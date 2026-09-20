TICKET 036 — pied de page

Crée `src/components/ui/SiteFooter.tsx`, export `SiteFooter`.

## Règles absolues
- TypeScript strict. Exports **nommés**. Ne modifie aucun test, ne crée aucun
  autre fichier.
- Couleurs via les tokens `var(--vs-*)` uniquement. Cobalt `--vs-accent` pour les
  actions, rouge `--vs-promo` réservé aux remises.
- **Aucun fichier baril nexiste** : nimporte jamais depuis un dossier.
- Les `data-testid` sont un contrat testé ; les classes Tailwind sont libres.

## Bloc d'imports exact
```tsx
import { Container } from '@/components/ui/layout';
```

## Props
```ts
interface ColonnePied { titre: string; liens: Array<{ label: string; href: string }> }
{ colonnes: ColonnePied[]; annee?: number; className?: string }
```
Exporte aussi le type `ColonnePied`.

## Contrat
- Racine `<footer data-testid="pied">`. Un `<footer>` de premier niveau porte le
  rôle `contentinfo` : ne l'imbrique pas dans une `<section>` ou un `<main>`.
- Une `<section>` par colonne, titre en `<h2>`, liens dans une `<ul>`.
- `<p data-testid="pied-mentions">` contenant exactement
  `© <annee> VICTO STORE`, où `<annee>` est la prop `annee` si elle est
  fournie, sinon `new Date().getFullYear()`.
- `<p data-testid="pied-slogan">Des grandes marques, au bon prix.</p>`.

La prop `annee` existe pour que le rendu soit déterministe : ne code jamais
l'année en dur.

## Critère de fin
`npm run typecheck` et `npm test` passent.
