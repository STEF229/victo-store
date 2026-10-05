import { fireEvent, render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { CatalogueProvider } from '../src/components/catalogue/CatalogueProvider';
import { ChampRecherche } from '../src/components/recherche/ChampRecherche';

const MARQUE = { id: 'pcat_x', nom: 'Zorblax', slug: 'zorblax' };
const P = { id: 'prod_x', slug: 'chaussure-zorblax', nom: 'Chaussure Zorblax', marque: MARQUE, imageUrl: '/x.svg', prixCents: 12900, variantes: [] };

describe('recherche — catalogue du site', () => {
  it('suggère les produits et les marques du catalogue fourni', () => {
    render(<CatalogueProvider valeur={{ produits: [P], marques: [MARQUE], source: 'medusa' }}><ChampRecherche /></CatalogueProvider>);
    fireEvent.change(screen.getByLabelText('Rechercher un produit'), { target: { value: 'zorblax' } });
    const zone = screen.getByTestId('suggestions-recherche');
    expect(zone.textContent).toContain('Chaussure Zorblax');
    expect(screen.getByRole('link', { name: 'Zorblax' })).toHaveAttribute('href', '/marques/zorblax');
  });
});
