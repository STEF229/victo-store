import { render, screen, within } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import PageConditions from '../src/app/conditions-de-vente/page';

describe('page Conditions de vente', () => {
  it('assemble titre, menu marqué et les huit sections dans l’ordre', () => {
    render(<PageConditions />);
    expect(screen.getByRole('heading', { level: 1, name: 'Conditions de vente' })).toBeInTheDocument();
    expect(within(screen.getByRole('navigation', { name: 'Aide' })).getByRole('link', { name: 'Conditions de vente' })).toHaveAttribute('aria-current', 'page');
    expect(screen.getAllByRole('heading', { level: 2 }).map((h: HTMLElement) => h.textContent)).toEqual([
      '1. Qui sommes-nous', '2. Produits et prix', '3. Commande et paiement', '4. Livraison',
      '5. Annulation et remboursement', '6. Retours', '7. Garantie légale', '8. Droit applicable',
    ]);
  });

  it('avertit qu’il faut faire valider le texte, et marque l’identité à compléter', () => {
    render(<PageConditions />);
    expect(screen.getByText('À faire valider par un juriste')).toBeInTheDocument();
    expect(screen.getByRole('article').querySelectorAll('mark')).toHaveLength(5);
  });

  it('renvoie vers les pages Livraison et Retours', () => {
    render(<PageConditions />);
    const article = screen.getByRole('article');
    expect(within(article).getByRole('link', { name: 'Livraison' })).toHaveAttribute('href', '/livraison');
    expect(within(article).getByRole('link', { name: 'Retours et échanges' })).toHaveAttribute('href', '/retours');
  });
});
