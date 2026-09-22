import { BandeMarques } from '@/components/accueil/BandeMarques';
import { Carrousel } from '@/components/accueil/Carrousel';
import { Infolettre } from '@/components/accueil/Infolettre';
import { MosaiqueCategories } from '@/components/accueil/MosaiqueCategories';
import { Reassurance } from '@/components/accueil/Reassurance';
import { SectionBonnesAffaires } from '@/components/accueil/SectionBonnesAffaires';
import { SiteFooter } from '@/components/ui/SiteFooter';
import { SiteHeader, type NavItem } from '@/components/ui/SiteHeader';
import { estEnPromotion } from '@/lib/catalogue';
import { listerMarques, listerProduits } from '@/lib/donnees';

const NAV: NavItem[] = [
  { label: 'Femme', href: '/femme' },
  { label: 'Homme', href: '/homme' },
  { label: 'Chaussures', href: '/chaussures' },
  { label: 'Marques', href: '/marques' },
  { label: 'Soldes', href: '/soldes', promo: true },
];

const COLONNES_PIED = [
  {
    titre: 'Boutique',
    liens: [
      { label: 'Femme', href: '/femme' },
      { label: 'Homme', href: '/homme' },
      { label: 'Soldes', href: '/soldes' },
    ],
  },
  {
    titre: 'Aide',
    liens: [
      { label: 'Livraison', href: '/livraison' },
      { label: 'Retours', href: '/retours' },
      { label: 'Contact', href: '/contact' },
    ],
  },
];

export function AccueilPage() {
  const bonnesAffaires = listerProduits().filter(estEnPromotion).slice(0, 4);

  return (
    <>
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
  );
}

export default AccueilPage;
