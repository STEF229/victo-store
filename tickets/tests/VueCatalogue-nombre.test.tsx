import { fireEvent, render, screen, within } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { VueCatalogue } from '../src/components/catalogue/VueCatalogue';
import type { Marque, Produit } from '../src/lib/catalogue';

const NIKE: Marque = { id: 'm1', nom: 'Nike', slug: 'nike' };
const LACOSTE: Marque = { id: 'm2', nom: 'Lacoste', slug: 'lacoste' };
const P = (id: string, marque: Marque): Produit => ({
  id, slug: `p-${id}`, nom: `Produit ${id}`, marque, imageUrl: '/img/x.svg', prixCents: 5000,
  variantes: [{ id: `${id}v`, taille: '41', sku: `${id}-41`, stock: 2 }],
});
const HUIT = [P('a', NIKE), P('b', NIKE), P('c', LACOSTE), P('d', NIKE), P('e', LACOSTE), P('f', NIKE), P('g', LACOSTE), P('h', NIKE)];

describe('VueCatalogue — Voir N produits', () => {
  it('annonce dans le tiroir le même nombre que le compteur', () => {
    render(<VueCatalogue titre="Soldes" produits={HUIT} />);
    fireEvent.click(screen.getByTestId('ouvrir-filtres'));
    const tiroir = screen.getByTestId('tiroir-filtres');
    expect(within(tiroir).getByRole('button', { name: 'Voir 8 produits' })).toBeInTheDocument();
    fireEvent.click(within(tiroir).getByTestId('filtre-marque-lacoste'));
    expect(screen.getByTestId('compteur').textContent).toBe('3 produits');
    expect(within(screen.getByTestId('tiroir-filtres')).getByRole('button', { name: 'Voir 3 produits' })).toBeInTheDocument();
  });
});
