TICKET 100f — page panier

Crée `src/app/panier/page.tsx`. Ticket d'assemblage : le fichier est donné en entier,
recopie-le.

## Règles absolues
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- **Un seul export : l'export par défaut `PagePanier`.** Aucun export nommé.
- Composant serveur : **pas** de `'use client'`.

## Fichier
Taille attendue : ~25 lignes.
```tsx
import { VuePanier } from '@/components/panier/VuePanier';
import { FilAriane } from '@/components/produit/FilAriane';
import { SiteFooter } from '@/components/ui/SiteFooter';
import { SiteHeader } from '@/components/ui/SiteHeader';
import { COLONNES_PIED, NAV } from '@/lib/navigation';

export default function PagePanier() {
  return (
    <>
      <SiteHeader navItems={NAV} />
      <main className="mx-auto w-full max-w-[1440px] px-5 pb-24 lg:px-20">
        <FilAriane items={[{ label: 'Accueil', href: '/' }, { label: 'Panier' }]} />
        <h1 className="mb-7 text-4xl font-black leading-none tracking-tight text-[var(--vs-noir)] lg:text-[56px]">
          Votre panier
        </h1>
        <VuePanier />
      </main>
      <SiteFooter colonnes={COLONNES_PIED} />
    </>
  );
}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
