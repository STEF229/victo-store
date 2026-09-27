TICKET 102e — menu de l'espace client

Crée `src/components/compte/MenuCompte.tsx`, avec l'export de type `EntreeCompte`
et le composant `MenuCompte`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index ;
  utilise `.map`.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Chaque `className` est écrit exactement comme ci-dessous. Aucun `<h1>`.
- Icônes `lucide-react` avec `aria-hidden`.

## Bloc d'imports exact
```tsx
'use client';

import { Heart, House, LogOut, MapPin, Package, User } from 'lucide-react';
import Link from 'next/link';
import { MENU_LIEN, MENU_LIEN_ACTIF } from '@/components/compte/compte-affichage';
import { useSession } from '@/components/compte/SessionProvider';
```

## Contenu
Taille attendue : ~50 lignes.
```tsx
export type EntreeCompte = 'tableau' | 'commandes' | 'favoris' | 'adresses' | 'informations';

const ENTREES = [
  { cle: 'tableau', libelle: 'Tableau de bord', href: '/compte', Icone: House },
  { cle: 'commandes', libelle: 'Mes commandes', href: '/compte/commandes', Icone: Package },
  { cle: 'favoris', libelle: 'Favoris', href: '/compte/favoris', Icone: Heart },
  { cle: 'adresses', libelle: 'Adresses', href: '/compte/adresses', Icone: MapPin },
  { cle: 'informations', libelle: 'Informations personnelles', href: '/compte/informations', Icone: User },
] as const;
```
`export function MenuCompte({ actif }: { actif: EntreeCompte })` :
- `const session = useSession();`
- rend `<nav aria-label="Espace client" data-testid="menu-compte" className="flex flex-col gap-1">`
  contenant, pour chaque entrée `e` (`ENTREES.map((e) => …)`, `key={e.cle}`) :
  ```tsx
  <Link href={e.href} aria-current={e.cle === actif ? 'page' : undefined}
    className={e.cle === actif ? MENU_LIEN_ACTIF : MENU_LIEN}>
    <e.Icone aria-hidden size={19} />
    {e.libelle}
  </Link>
  ```
- puis `<div className="my-3 h-px bg-[var(--vs-ligne)]" />`
- puis
  ```tsx
  <button type="button" onClick={() => session.deconnecter()}
    className="flex h-[50px] items-center gap-3 rounded-full px-[18px] text-[15px] font-semibold text-[var(--vs-gris)]">
    <LogOut aria-hidden size={19} />
    Se déconnecter
  </button>
  ```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
