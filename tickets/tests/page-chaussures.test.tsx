import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
// Dépendance déclarée pour le harnais : sans VueCatalogue, ce ticket est BLOQUÉ au lieu d'échouer trois fois.
import { VueCatalogue as _dependance } from '../src/components/catalogue/VueCatalogue';
import Page from '../src/app/chaussures/page';

import { PRODUITS } from '../src/lib/donnees';

const attendus = PRODUITS.filter((p) => p.categorie === 'chaussures');

describe('page Chaussures', () => {
  it('titre la page', () => {
    render(<Page />);
    expect(screen.getByRole('heading', { level: 1 }).textContent).toBe('Chaussures');
  });

  it('présente exactement les produits attendus', () => {
    render(<Page />);
    const n = attendus.length;
    expect(screen.getByTestId('compteur').textContent).toBe(`${n} ${n > 1 ? 'produits' : 'produit'}`);
    expect(screen.getAllByTestId('carte-produit')).toHaveLength(Math.min(6, n));
  });

  it('n’affiche que des produits de la sélection', () => {
    render(<Page />);
    const ids = new Set(attendus.map((p) => p.id));
    for (const carte of screen.getAllByTestId('carte-produit')) {
      expect(ids.has(carte.getAttribute('data-produit-id') ?? '')).toBe(true);
    }
  });
});
