TICKET 061 — page d'accueil, assemblage final

Remplace entièrement `src/app/page.tsx`. Export nommé `AccueilPage`, plus
`export default AccueilPage;` en fin de fichier (Next.js l'exige pour une route ;
seule exception à la règle des exports nommés).

## Règles absolues
- TypeScript strict. **Ne modifie aucun test.** Ne crée aucun autre fichier.
- **Aucun fichier baril n'existe.** Pas de `'use client'` : la page n'a aucun état,
  ce sont ses composants qui en ont.
- Classes imposées en toutes lettres, jamais construites dynamiquement.

## Bloc d'imports exact

Recopie ce bloc tel quel, sans rien ajouter ni retirer.

```tsx
import { BandeMarques } from '@/components/accueil/BandeMarques';
import { BarreAnnonce } from '@/components/accueil/BarreAnnonce';
import { Carrousel } from '@/components/accueil/Carrousel';
import { Infolettre } from '@/components/accueil/Infolettre';
import { MosaiqueCategories } from '@/components/accueil/MosaiqueCategories';
import { Reassurance } from '@/components/accueil/Reassurance';
import { SectionBonnesAffaires } from '@/components/accueil/SectionBonnesAffaires';
import { SiteFooter } from '@/components/ui/SiteFooter';
import { SiteHeader, type NavItem } from '@/components/ui/SiteHeader';
import { estEnPromotion } from '@/lib/catalogue';
import { listerMarques, listerProduits } from '@/lib/donnees';
```

## Signatures des composants

Tu n'as pas besoin de lire leur code :

```ts
BarreAnnonce()
SiteHeader({ navItems: NavItem[]; cartCount?: number })   // NavItem = { label; href; promo? }
Carrousel({ intervalleMs?: number; auto?: boolean })
BandeMarques({ marques: Marque[] })
SectionBonnesAffaires({ produits: Produit[] })
MosaiqueCategories()
Infolettre()
Reassurance()
SiteFooter({ colonnes: Array<{ titre: string; liens: Array<{ label: string; href: string }> }>; annee?: number })
```

## Données — en tête de fichier, sous les imports

```ts
const NAV: NavItem[] = [
  { label: 'Femme', href: '/femme' },
  { label: 'Homme', href: '/homme' },
  { label: 'Chaussures', href: '/chaussures' },
  { label: 'Marques', href: '/marques' },
  { label: 'Soldes', href: '/soldes', promo: true },
];

const COLONNES_PIED = [
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

Dans le composant, **exactement** :

```ts
const bonnesAffaires = listerProduits().filter(estEnPromotion).slice(0, 4);
```

## Structure, dans cet ordre exact

```tsx
<>
  <BarreAnnonce />
  <SiteHeader navItems={NAV} cartCount={0} />
  <main>
    <Carrousel />
    <BandeMarques marques={listerMarques()} />
    <div className="mx-auto max-w-[1440px] px-5 py-24 lg:px-20">
      <SectionBonnesAffaires produits={bonnesAffaires} />
    </div>
    <div className="mx-auto max-w-[1440px] px-5 pb-24 lg:px-20">
      <MosaiqueCategories />
    </div>
    <div className="mx-auto max-w-[1440px] px-5 pb-24 lg:px-20">
      <Infolettre />
    </div>
    <div className="mx-auto max-w-[1440px] px-5 py-14 lg:px-20">
      <Reassurance />
    </div>
  </main>
  <SiteFooter colonnes={COLONNES_PIED} annee={2026} />
</>
```

Recopie cette structure telle quelle : les classes des `<div>` d'enveloppe sont
imposées et testées. Un seul `<h1>` existe sur la page, celui de la première
diapositive du carrousel ; n'en ajoute aucun.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
