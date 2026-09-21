import { fireEvent, render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { BoutiquePage } from '../src/app/boutique/page';
import { MARQUES, PRODUITS } from '../src/lib/donnees';
import { estEnPromotion } from '../src/lib/catalogue';

const PAR_PAGE = 6;

describe('page boutique — structure', () => {
  it('rend l’en-tête, le titre et le pied', () => {
    render(<BoutiquePage />);
    expect(screen.getByRole('banner')).toBeInTheDocument();
    expect(screen.getByRole('heading', { level: 1, name: 'Boutique' })).toBeInTheDocument();
    expect(screen.getByRole('contentinfo')).toBeInTheDocument();
  });

  it('rend les filtres, le tri, la grille et la pagination', () => {
    render(<BoutiquePage />);
    expect(screen.getByTestId('filtres')).toBeInTheDocument();
    expect(screen.getByTestId('tri')).toBeInTheDocument();
    expect(screen.getByTestId('grille')).toBeInTheDocument();
    expect(screen.getByTestId('pagination')).toBeInTheDocument();
  });
});

describe('page boutique — pagination', () => {
  it('affiche six produits sur la première page', () => {
    render(<BoutiquePage />);
    expect(screen.getAllByTestId('carte-produit')).toHaveLength(PAR_PAGE);
  });

  it('compte tous les produits, pas seulement la page', () => {
    render(<BoutiquePage />);
    expect(screen.getByTestId('compteur').textContent).toBe(`${PRODUITS.length} produits`);
  });

  it('navigue à la page suivante', () => {
    render(<BoutiquePage />);
    expect(screen.getByTestId('pagination-etat').textContent).toBe('Page 1 sur 2');
    fireEvent.click(screen.getByRole('button', { name: 'Page suivante' }));
    expect(screen.getByTestId('pagination-etat').textContent).toBe('Page 2 sur 2');
    expect(screen.getAllByTestId('carte-produit')).toHaveLength(PRODUITS.length - PAR_PAGE);
  });
});

describe('page boutique — filtres', () => {
  it('filtre par marque et met à jour le compteur', () => {
    render(<BoutiquePage />);
    const premiere = MARQUES[0]!;
    const attendu = PRODUITS.filter((p) => p.marque.slug === premiere.slug).length;
    fireEvent.click(screen.getByTestId(`filtre-marque-${premiere.slug}`));
    const mot = attendu > 1 ? 'produits' : 'produit';
    expect(screen.getByTestId('compteur').textContent).toBe(`${attendu} ${mot}`);
  });

  it('filtre les promotions', () => {
    render(<BoutiquePage />);
    const attendu = PRODUITS.filter(estEnPromotion).length;
    fireEvent.click(screen.getByTestId('filtre-promo'));
    expect(screen.getByTestId('compteur').textContent).toBe(`${attendu} produits`);
  });

  it('revient à la page 1 après un changement de filtre', () => {
    render(<BoutiquePage />);
    fireEvent.click(screen.getByRole('button', { name: 'Page suivante' }));
    fireEvent.click(screen.getByTestId('filtre-promo'));
    const etat = screen.queryByTestId('pagination-etat');
    if (etat) expect(etat.textContent).toContain('Page 1');
    expect(screen.getAllByTestId('carte-produit').length).toBeGreaterThan(0);
  });

  it('réinitialise les filtres', () => {
    render(<BoutiquePage />);
    fireEvent.click(screen.getByTestId('filtre-promo'));
    fireEvent.click(screen.getByTestId('filtres-reinitialiser'));
    expect(screen.getByTestId('compteur').textContent).toBe(`${PRODUITS.length} produits`);
  });
});

describe('page boutique — tri', () => {
  it('réordonne par prix croissant', () => {
    render(<BoutiquePage />);
    fireEvent.change(screen.getByTestId('tri'), { target: { value: 'prix-croissant' } });
    const noms = screen.getAllByTestId('carte-nom').map((e) => e.textContent);
    const attendus = [...PRODUITS]
      .sort((a, b) => a.prixCents - b.prixCents)
      .slice(0, PAR_PAGE)
      .map((p) => p.nom);
    expect(noms).toEqual(attendus);
  });
});
