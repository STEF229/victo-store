import { fireEvent, render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { ProductCard } from '../src/components/ui/ProductCard';
import type { Produit } from '../src/lib/catalogue';

const P: Produit = {
  id: 'p1',
  slug: 'p-1',
  nom: 'Produit 1',
  marque: { id: 'm1', nom: 'Nike', slug: 'nike' },
  imageUrl: '/img/pegasus.svg',
  prixCents: 8000,
  prixCompareCents: 10000,
  variantes: [{ id: 'v1', taille: '41', sku: 'S-41', stock: 2 }],
};

describe('ProductCard — cœur lucide', () => {
  it('utilise l’icône lucide du cœur', () => {
    render(<ProductCard produit={P} />);
    const bouton = screen.getByRole('button', { name: 'Ajouter aux favoris' });
    expect(bouton.querySelector('svg.lucide-heart')).not.toBeNull();
  });

  it('remplit le cœur quand le produit est en favori', () => {
    render(<ProductCard produit={P} />);
    const bouton = screen.getByRole('button', { name: 'Ajouter aux favoris' });
    const coeur = () => bouton.querySelector('svg.lucide-heart') as Element;
    expect(coeur().getAttribute('fill')).toBe('none');
    fireEvent.click(bouton);
    expect(coeur().getAttribute('fill')).toBe('currentColor');
  });

  it('ne contient plus aucune icône dessinée à la main', () => {
    const { container } = render(<ProductCard produit={P} />);
    for (const s of Array.from(container.querySelectorAll('svg'))) {
      expect(s.classList.contains('lucide')).toBe(true);
    }
  });
});
