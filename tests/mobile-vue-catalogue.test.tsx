import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { VueCatalogue } from '../src/components/catalogue/VueCatalogue';
import type { Produit } from '../src/lib/catalogue';

const UN: Produit[] = [{
  id: 'p1', slug: 'p1', nom: 'Produit', marque: { id: 'm1', nom: 'Nike', slug: 'nike' }, imageUrl: '/x.svg', prixCents: 1000,
  variantes: [{ id: 'v1', taille: '42', sku: 'S-42', stock: 2 }],
}];
const classes = (el: Element | null) => (el?.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);

describe('VueCatalogue — fil d’Ariane et marges', () => {
  it('affiche le fil d’Ariane avant le titre', () => {
    render(<VueCatalogue titre="Vêtements Femme" produits={UN} filAriane={<nav data-testid="fil-test">fil</nav>} />);
    const fil = screen.getByTestId('fil-test');
    expect(fil.compareDocumentPosition(screen.getByTestId('liste-titre')) & Node.DOCUMENT_POSITION_FOLLOWING).toBeTruthy();
  });

  it('réduit les marges sur téléphone', () => {
    render(<VueCatalogue titre="Femme" produits={UN} entete={<nav data-testid="bandeau-test">b</nav>} />);
    expect(classes(screen.getByRole('main'))).toContain('max-sm:pt-6');
    expect(classes(screen.getByTestId('bandeau-test').closest('.mt-8'))).toContain('max-sm:mt-5');
    expect(classes(screen.getByTestId('filtres-barre').closest('.mt-8'))).toContain('max-sm:mt-5');
  });

  it('reste identique sans fil d’Ariane', () => {
    render(<VueCatalogue titre="Femme" produits={UN} />);
    expect(screen.getByTestId('liste-titre').textContent).toBe('Femme');
  });
});
