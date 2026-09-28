import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { ProductCard } from '../src/components/ui/ProductCard';
import type { Produit } from '../src/lib/catalogue';

const P: Produit = {
  id: 'p1', slug: 'air-zoom-pegasus-41', nom: 'Air Zoom Pegasus 41', marque: { id: 'm1', nom: 'Nike', slug: 'nike' },
  imageUrl: '/img/x.svg', prixCents: 12900, variantes: [{ id: 'v1', taille: '42', sku: 'NK-42', stock: 5 }],
};
const classes = (el: Element) => (el.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);

describe('ProductCard — position du cœur', () => {
  it('garde le cœur dans le coin de sa propre carte', () => {
    render(<ProductCard produit={P} />);
    const coeur = screen.getByRole('button', { name: 'Ajouter aux favoris' });
    expect(classes(coeur)).toContain('absolute');
    const ancre = coeur.closest('.relative');
    expect(ancre, 'un ancêtre positionné dans la carte').not.toBeNull();
    expect(ancre?.contains(screen.getByTestId('carte-nom'))).toBe(true);
  });
});
