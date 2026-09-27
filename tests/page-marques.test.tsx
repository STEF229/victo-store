import { render, screen, within } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import PageMarques from '../src/app/marques/page';
import { hrefMarque } from '../src/lib/catalogue';
import { MARQUES, PRODUITS } from '../src/lib/donnees';

const AVEC_PRODUITS = MARQUES.filter((m) => PRODUITS.some((p) => p.marque.slug === m.slug));

describe('page des marques', () => {
  it('assemble en-tête, titre, fil d’Ariane et pied', () => {
    render(<PageMarques />);
    expect(screen.getByRole('banner')).toBeInTheDocument();
    expect(screen.getByRole('heading', { level: 1, name: 'Marques' })).toBeInTheDocument();
    expect(within(screen.getByTestId('fil-ariane')).getByText('Marques')).toHaveAttribute('aria-current', 'page');
    expect(screen.getByRole('contentinfo')).toBeInTheDocument();
  });

  it('montre une tuile par marque qui a des produits, triées par nom', () => {
    render(<PageMarques />);
    const tuiles = within(screen.getByTestId('grille-marques')).getAllByRole('link');
    expect(tuiles).toHaveLength(AVEC_PRODUITS.length);
    const attendues = [...AVEC_PRODUITS].sort((a, b) => a.nom.localeCompare(b.nom, 'fr')).map((m) => hrefMarque(m));
    expect(tuiles.map((t: HTMLElement) => t.getAttribute('href'))).toEqual(attendues);
    expect(screen.getByTestId('marques-nombre').textContent).toBe(
      `${AVEC_PRODUITS.length} ${AVEC_PRODUITS.length > 1 ? 'marques' : 'marque'}`,
    );
  });
});
