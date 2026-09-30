import { render, screen, within } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import PageRetours from '../src/app/retours/page';

describe('page Retours et échanges', () => {
  it('assemble titre, menu marqué et sections dans l’ordre', () => {
    render(<PageRetours />);
    expect(screen.getByRole('heading', { level: 1, name: 'Retours et échanges' })).toBeInTheDocument();
    expect(within(screen.getByRole('navigation', { name: 'Aide' })).getByRole('link', { name: 'Retours et échanges' })).toHaveAttribute('aria-current', 'page');
    expect(screen.getAllByRole('heading', { level: 2 }).map((h: HTMLElement) => h.textContent)).toEqual([
      'Comment faire', 'Conditions', 'Remboursement', 'Article défectueux',
    ]);
  });

  it('explique le retour en trois étapes, depuis le compte', () => {
    render(<PageRetours />);
    const article = screen.getByRole('article');
    for (const t of ['Déclarez le retour', "Emballez l'article", 'Déposez le colis']) expect(within(article).getByText(t)).toBeInTheDocument();
    expect(within(article).getByRole('link', { name: 'Mes commandes' })).toHaveAttribute('href', '/compte/commandes');
  });

  it('marque les choix qui restent à faire', () => {
    render(<PageRetours />);
    expect(screen.getByRole('article').querySelectorAll('mark')).toHaveLength(2);
  });
});
