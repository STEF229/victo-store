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
