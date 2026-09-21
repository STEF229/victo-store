import { render } from '@testing-library/react';
import type { ReactElement } from 'react';
import { describe, expect, it } from 'vitest';
import { BandeMarques } from '../src/components/accueil/BandeMarques';
import { BarreAnnonce } from '../src/components/accueil/BarreAnnonce';
import { Infolettre } from '../src/components/accueil/Infolettre';
import { MosaiqueCategories } from '../src/components/accueil/MosaiqueCategories';
import { Reassurance } from '../src/components/accueil/Reassurance';
import { SectionBonnesAffaires } from '../src/components/accueil/SectionBonnesAffaires';
import { ProductCard } from '../src/components/ui/ProductCard';
import { SiteFooter } from '../src/components/ui/SiteFooter';
import { SiteHeader } from '../src/components/ui/SiteHeader';
import type { Produit } from '../src/lib/catalogue';

// Garde permanente : un composant ne porte jamais le titre de la page.
// Seul le carrousel a un <h1>, et la page en vérifie l'unicité.
const P: Produit = {
  id: 'p1', slug: 'p-1', nom: 'Produit 1',
  marque: { id: 'm1', nom: 'Nike', slug: 'nike' },
  imageUrl: '/img/pegasus.svg', prixCents: 8000, prixCompareCents: 10000,
  variantes: [{ id: 'v1', taille: '41', sku: 'S-41', stock: 2 }],
};

const CAS: Array<[string, ReactElement]> = [
  ['BarreAnnonce', <BarreAnnonce />],
  ['SiteHeader', <SiteHeader navItems={[{ label: 'Femme', href: '/femme' }]} cartCount={1} />],
  ['SiteFooter', <SiteFooter colonnes={[{ titre: 'Aide', liens: [{ label: 'Contact', href: '/contact' }] }]} annee={2026} />],
  ['ProductCard', <ProductCard produit={P} />],
  ['BandeMarques', <BandeMarques marques={[P.marque]} />],
  ['SectionBonnesAffaires', <SectionBonnesAffaires produits={[P]} />],
  ['MosaiqueCategories', <MosaiqueCategories />],
  ['Infolettre', <Infolettre />],
  ['Reassurance', <Reassurance />],
];

describe('aucun composant ne porte de titre de niveau 1', () => {
  it.each(CAS)('%s', (_nom, element) => {
    const { container } = render(element);
    expect(container.querySelectorAll('h1')).toHaveLength(0);
  });
});
