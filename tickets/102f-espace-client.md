TICKET 102f — espace client protégé

Crée `src/components/compte/EspaceClient.tsx`, export nommé `EspaceClient`. Il
affiche le menu et le contenu à un client connecté, et invite les autres à se
connecter.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Chaque `className` est écrit exactement comme ci-dessous. Aucun `<h1>`.

## Bloc d'imports exact
```tsx
'use client';

import Link from 'next/link';
import type { ReactNode } from 'react';
import { BOUTON_PRINCIPAL, BOUTON_SECONDAIRE, SOUS_TITRE } from '@/components/compte/compte-affichage';
import { MenuCompte, type EntreeCompte } from '@/components/compte/MenuCompte';
import { useSession } from '@/components/compte/SessionProvider';
```

## Rendu
Taille attendue : ~40 lignes.

`export function EspaceClient({ actif, children }: { actif: EntreeCompte; children: ReactNode })` :
1. `const session = useSession();`
2. si `!session.pret` : `<div data-testid="compte-chargement" aria-busy="true" className="min-h-[320px]" />`
3. si `session.client === null` :
```tsx
<div data-testid="compte-invitation" className="mx-auto flex max-w-[520px] flex-col items-center gap-5 py-20 text-center">
  <h2 className="text-3xl font-black tracking-tight text-[var(--vs-noir)]">Connectez-vous pour accéder à votre compte</h2>
  <p className={SOUS_TITRE}>Suivez vos commandes, gérez vos adresses et retrouvez vos favoris.</p>
  <div className="flex w-full flex-col gap-3 sm:flex-row">
    <Link href="/connexion" className={BOUTON_PRINCIPAL}>Se connecter</Link>
    <Link href="/inscription" className={BOUTON_SECONDAIRE}>Créer un compte</Link>
  </div>
</div>
```
4. sinon :
```tsx
<div data-testid="espace-client" className="grid gap-10 lg:grid-cols-[280px_minmax(0,1fr)] lg:items-start lg:gap-14">
  <MenuCompte actif={actif} />
  <div className="flex min-w-0 flex-col gap-7">{children}</div>
</div>
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
