import { fireEvent, render, screen } from '@testing-library/react';
import { beforeEach, describe, expect, it } from 'vitest';
import PageFavoris from '../src/app/compte/favoris/page';
import { CLE_SESSION, SessionProvider } from '../src/components/compte/SessionProvider';
import { CLE_FAVORIS, FavorisProvider } from '../src/components/favoris/FavorisProvider';
import { CLIENT_DEMO } from '../src/lib/compte';
import { trouverProduit } from '../src/lib/donnees';

const nom = (slug: string) => trouverProduit(slug)?.nom ?? slug;
const poser = (favoris: string[], connecte = true) => {
  if (connecte) window.localStorage.setItem(CLE_SESSION, JSON.stringify(CLIENT_DEMO));
  window.localStorage.setItem(CLE_FAVORIS, JSON.stringify(favoris));
  render(<SessionProvider><FavorisProvider><PageFavoris /></FavorisProvider></SessionProvider>);
};

beforeEach(() => window.localStorage.clear());

describe('mes favoris', () => {
  it('liste les produits favoris et ignore un produit disparu', () => {
    poser(['air-zoom-pegasus-41', 'produit-disparu', 'polo-shirt']);
    expect(screen.getByRole('heading', { level: 1, name: 'Mes favoris' })).toBeInTheDocument();
    expect(screen.getAllByTestId('favori')).toHaveLength(2);
    expect(screen.getByTestId('favoris-nombre').textContent).toBe('2 produits');
    expect(screen.getByRole('link', { name: 'Favoris' })).toHaveAttribute('aria-current', 'page');
  });

  it('retire un favori, et le garde retiré', () => {
    poser(['air-zoom-pegasus-41', 'polo-shirt']);
    fireEvent.click(screen.getByRole('button', { name: `Retirer ${nom('polo-shirt')} des favoris` }));
    expect(screen.getAllByTestId('favori')).toHaveLength(1);
    expect(screen.getByTestId('favoris-nombre').textContent).toBe('1 produit');
    expect(window.localStorage.getItem(CLE_FAVORIS)).toBe('["air-zoom-pegasus-41"]');
  });

  it('invite à découvrir la boutique quand il n’y a aucun favori', () => {
    poser([]);
    expect(screen.getByTestId('favoris-vide')).toBeInTheDocument();
    expect(screen.getByTestId('favoris-nombre').textContent).toBe('0 produit');
    expect(screen.getByRole('link', { name: 'Découvrir la boutique' })).toHaveAttribute('href', '/boutique');
  });

  it('invite à se connecter sans session', () => {
    poser(['polo-shirt'], false);
    expect(screen.getByTestId('compte-invitation')).toBeInTheDocument();
  });
});
