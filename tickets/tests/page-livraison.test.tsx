import { render, screen, within } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import PageLivraison from '../src/app/livraison/page';

describe('page Livraison', () => {
  it('assemble titre, menu marqué et sections dans l’ordre', () => {
    render(<PageLivraison />);
    expect(screen.getByRole('heading', { level: 1, name: 'Livraison' })).toBeInTheDocument();
    expect(within(screen.getByRole('navigation', { name: 'Aide' })).getByRole('link', { name: 'Livraison' })).toHaveAttribute('aria-current', 'page');
    expect(screen.getAllByRole('heading', { level: 2 }).map((h: HTMLElement) => h.textContent)).toEqual([
      'Délais', 'Suivre votre colis', 'Livraison hors du Canada', 'Colis en retard, perdu ou abîmé',
    ]);
  });

  it('donne les délais par destination', () => {
    render(<PageLivraison />);
    const lignes = screen.getAllByRole('row').slice(1).map((r: HTMLElement) => within(r).getAllByRole('cell')[0]?.textContent);
    expect(lignes).toEqual(['Québec', 'Ontario et Maritimes', 'Prairies et Colombie-Britannique', 'Territoires']);
  });

  it('renvoie vers le compte et les conditions, et marque ce qui reste à confirmer', () => {
    render(<PageLivraison />);
    const article = screen.getByRole('article');
    expect(within(article).getByRole('link', { name: 'Mes commandes' })).toHaveAttribute('href', '/compte/commandes');
    expect(within(article).getByRole('link', { name: 'conditions de vente' })).toHaveAttribute('href', '/conditions-de-vente');
    expect(article.querySelectorAll('mark')).toHaveLength(2);
  });
});
