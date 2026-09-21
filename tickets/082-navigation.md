TICKET 082 — navigation partagée

Crée `src/lib/navigation.ts`. Les pages de liste partagent le même menu et le même
pied de page ; ils vivent à un seul endroit.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif. Exports **nommés**, sauf
  les fichiers `page.tsx` qui n'ont **qu'un export par défaut**.
- **Ne modifie aucun fichier de test.** Ne modifie aucun autre fichier que celui du ticket.
- **Aucun fichier baril n'existe.** N'importe que des modules réels ; leurs
  déclarations de types exactes te sont fournies en lecture seule.
- Icônes : uniquement `lucide-react`, avec `aria-hidden`.
- Classes imposées en toutes lettres ; les tests les vérifient.
- Accès aux tableaux : `t[0]` est `T | undefined` ; pas de `!` ni de `as`.
- **Les tests existants qui touchent ce fichier doivent rester verts.**
## Import exact
```ts
import type { NavItem } from '@/components/ui/SiteHeader';
```

## Contenu exact
```ts
export const NAV: NavItem[] = [
  { label: 'Femme', href: '/femme' },
  { label: 'Homme', href: '/homme' },
  { label: 'Chaussures', href: '/chaussures' },
  { label: 'Marques', href: '/marques' },
  { label: 'Soldes', href: '/soldes', promo: true },
];

export const COLONNES_PIED = [
  { titre: 'Boutique', liens: [
    { label: 'Femme', href: '/femme' },
    { label: 'Homme', href: '/homme' },
    { label: 'Soldes', href: '/soldes' },
  ] },
  { titre: 'Aide', liens: [
    { label: 'Livraison', href: '/livraison' },
    { label: 'Retours', href: '/retours' },
    { label: 'Contact', href: '/contact' },
  ] },
];
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
