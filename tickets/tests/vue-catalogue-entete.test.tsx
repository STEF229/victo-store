import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { VueCatalogue } from '../src/components/catalogue/VueCatalogue';
import { sousCategories } from '../src/lib/arbre-categories';
import type { Produit } from '../src/lib/catalogue';

// Un produit, pour que la vue affiche sa barre de filtres (une liste vide a peut-être son propre écran).
const UN: Produit[] = [{
  id: 'p1', slug: 'p1', nom: 'Produit', marque: { id: 'm1', nom: 'Nike', slug: 'nike' }, imageUrl: '/x.svg', prixCents: 1000,
  variantes: [{ id: 'v1', taille: '42', sku: 'S-42', stock: 2 }],
}];

describe('VueCatalogue — bandeau sous le titre', () => {
  it('place le bandeau entre le titre et la barre de filtres', () => {
    render(<VueCatalogue titre="Homme" produits={UN} entete={<nav aria-label="Sous-catégories de Homme">bandeau</nav>} />);
    const bandeau = screen.getByRole('navigation', { name: 'Sous-catégories de Homme' });
    const titre = screen.getByTestId('liste-titre');
    const barre = screen.getByTestId('filtres-barre');
    expect(titre.compareDocumentPosition(bandeau) & Node.DOCUMENT_POSITION_FOLLOWING).toBeTruthy();
    expect(bandeau.compareDocumentPosition(barre) & Node.DOCUMENT_POSITION_FOLLOWING).toBeTruthy();
    expect(sousCategories([], 'homme', [])).toHaveLength(3);
  });

  it('reste identique sans bandeau', () => {
    render(<VueCatalogue titre="Homme" produits={UN} />);
    expect(screen.queryByRole('navigation', { name: 'Sous-catégories de Homme' })).toBeNull();
  });
});
