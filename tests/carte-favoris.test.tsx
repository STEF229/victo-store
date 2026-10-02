import { fireEvent, render, screen } from '@testing-library/react';
import { beforeEach, describe, expect, it } from 'vitest';
import { CLE_FAVORIS, FavorisProvider } from '../src/components/favoris/FavorisProvider';
import { ProductCard } from '../src/components/ui/ProductCard';
import type { Produit } from '../src/lib/catalogue';

const P: Produit = {
  id: 'p1', slug: 'air-zoom-pegasus-41', nom: 'Air Zoom Pegasus 41', marque: { id: 'm1', nom: 'Nike', slug: 'nike' },
  imageUrl: '/img/x.svg', prixCents: 12900, variantes: [{ id: 'v1', taille: '42', sku: 'NK-42', stock: 5 }],
};
const coeur = () => screen.getByRole('button', { name: 'Ajouter aux favoris' });

beforeEach(() => window.localStorage.clear());

describe('ProductCard — favori gardé', () => {
  it('bascule le favori gardé, partagé avec le reste du site', () => {
    render(<FavorisProvider><ProductCard produit={P} /></FavorisProvider>);
    expect(coeur()).toHaveAttribute('aria-pressed', 'false');
    fireEvent.click(coeur());
    expect(coeur()).toHaveAttribute('aria-pressed', 'true');
    expect(window.localStorage.getItem(CLE_FAVORIS)).toBe(JSON.stringify([P.slug]));
  });

  it('montre un favori déjà gardé', () => {
    window.localStorage.setItem(CLE_FAVORIS, JSON.stringify([P.slug]));
    render(<FavorisProvider><ProductCard produit={P} /></FavorisProvider>);
    expect(coeur()).toHaveAttribute('aria-pressed', 'true');
  });

  it('garde son état local sans fournisseur', () => {
    render(<ProductCard produit={P} />);
    fireEvent.click(coeur());
    expect(coeur()).toHaveAttribute('aria-pressed', 'true');
    expect(window.localStorage.getItem(CLE_FAVORIS)).toBeNull();
  });
});
