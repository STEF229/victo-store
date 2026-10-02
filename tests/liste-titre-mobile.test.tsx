import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { VueCatalogue } from '../src/components/catalogue/VueCatalogue';
import type { Produit } from '../src/lib/catalogue';

const UN: Produit[] = [{
  id: 'p1', slug: 'p1', nom: 'Produit', marque: { id: 'm1', nom: 'Nike', slug: 'nike' }, imageUrl: '/x.svg', prixCents: 1000,
  variantes: [{ id: 'v1', taille: '42', sku: 'S-42', stock: 2 }],
}];
const classes = (el: Element) => (el.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);

describe('VueCatalogue — titre et compteur sur téléphone', () => {
  it('empile le compteur sous le titre sous 640 px, sans changer l’ordinateur', () => {
    render(<VueCatalogue titre="Sneakers Femme" produits={UN} />);
    const ligne = screen.getByTestId('liste-titre').closest('.justify-between');
    expect(ligne).not.toBeNull();
    expect(ligne?.contains(screen.getByTestId('compteur'))).toBe(true);
    for (const k of ['flex', 'items-end', 'justify-between', 'gap-8', 'max-sm:flex-col', 'max-sm:items-start', 'max-sm:gap-3']) {
      expect(classes(ligne as Element), k).toContain(k);
    }
  });
});
