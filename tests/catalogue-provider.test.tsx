import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { CatalogueProvider, useCatalogue } from '../src/components/catalogue/CatalogueProvider';
import { listerProduits } from '../src/lib/donnees';

function Temoin() {
  const c = useCatalogue();
  return <p data-testid="temoin">{`${c.source} ${c.produits.length} ${c.marques.map((m) => m.nom).join(',')}`}</p>;
}
const MARQUE = { id: 'pcat_x', nom: 'Marque Medusa', slug: 'marque-medusa' };
const PRODUIT = { id: 'prod_x', slug: 'produit-medusa', nom: 'Produit Medusa', marque: MARQUE, imageUrl: '/x.svg', prixCents: 1000, variantes: [] };

describe('catalogue du site — fournisseur', () => {
  it('donne la démonstration sans fournisseur', () => {
    render(<Temoin />);
    expect(screen.getByTestId('temoin').textContent?.startsWith(`demo ${listerProduits().length} `)).toBe(true);
  });

  it('donne le catalogue transmis par le serveur', () => {
    render(<CatalogueProvider valeur={{ produits: [PRODUIT], marques: [MARQUE], source: 'medusa' }}><Temoin /></CatalogueProvider>);
    expect(screen.getByTestId('temoin').textContent).toBe('medusa 1 Marque Medusa');
  });
});
