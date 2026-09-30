TICKET 106a — gabarit des pages d'aide

Crée `src/components/aide/GabaritAide.tsx`, avec les exports nommés `RubriqueAide`
(type), `RUBRIQUES_AIDE` et `GabaritAide`. Composant **serveur** : pas de `'use client'`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index ;
  utilise `.map`.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Chaque `className` est écrit exactement comme ci-dessous.
- Icônes `lucide-react` avec `aria-hidden`.

## Bloc d'imports exact
```tsx
import { Mail, RotateCcw, Scale, ShieldCheck, Truck, type LucideIcon } from 'lucide-react';
import Link from 'next/link';
import type { ReactNode } from 'react';
import { MENU_LIEN, MENU_LIEN_ACTIF, TITRE_PAGE } from '@/components/compte/compte-affichage';
import { FilAriane } from '@/components/produit/FilAriane';
import { SiteFooter } from '@/components/ui/SiteFooter';
import { SiteHeader } from '@/components/ui/SiteHeader';
import { COLONNES_PIED, NAV } from '@/lib/navigation';
```

## Contenu
Taille attendue : ~60 lignes.
```tsx
export type RubriqueAide = 'livraison' | 'retours' | 'contact' | 'conditions' | 'confidentialite';

export const RUBRIQUES_AIDE: { cle: RubriqueAide; libelle: string; href: string; Icone: LucideIcon }[] = [
  { cle: 'livraison', libelle: 'Livraison', href: '/livraison', Icone: Truck },
  { cle: 'retours', libelle: 'Retours et échanges', href: '/retours', Icone: RotateCcw },
  { cle: 'contact', libelle: 'Contact', href: '/contact', Icone: Mail },
  { cle: 'conditions', libelle: 'Conditions de vente', href: '/conditions-de-vente', Icone: Scale },
  { cle: 'confidentialite', libelle: 'Confidentialité', href: '/confidentialite', Icone: ShieldCheck },
];
```
```tsx
export function GabaritAide({ actif, titre, intro, miseAJour, children }: {
  actif: RubriqueAide;
  titre: string;
  intro: string;
  miseAJour?: string | undefined;
  children: ReactNode;
})
```
rend :
```tsx
<>
  <SiteHeader navItems={NAV} />
  <main className="mx-auto w-full max-w-[1440px] px-5 pb-24 lg:px-20">
    <FilAriane items={[{ label: 'Accueil', href: '/' }, { label: 'Aide', href: '/livraison' }, { label: titre }]} />
    <div className="grid gap-10 lg:grid-cols-[280px_minmax(0,1fr)] lg:items-start lg:gap-14">
      <nav aria-label="Aide" className="flex gap-2 overflow-x-auto lg:sticky lg:top-6 lg:flex-col lg:gap-1 lg:overflow-visible">
        {RUBRIQUES_AIDE.map((r) => (
          <Link key={r.cle} href={r.href} aria-current={r.cle === actif ? 'page' : undefined}
            className={r.cle === actif ? MENU_LIEN_ACTIF : MENU_LIEN}>
            <r.Icone aria-hidden size={19} />
            {r.libelle}
          </Link>
        ))}
      </nav>
      <article className="flex max-w-[800px] flex-col gap-8">
        <header className="flex flex-col gap-2.5">
          <h1 className={TITRE_PAGE}>{titre}</h1>
          <p className="text-[17px] leading-relaxed text-[var(--vs-gris)]">{intro}</p>
        </header>
        {children}
        {miseAJour && <p className="text-[13px] text-[var(--vs-gris)]">{`Dernière mise à jour : ${miseAJour}`}</p>}
      </article>
    </div>
  </main>
  <SiteFooter colonnes={COLONNES_PIED} />
</>
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
