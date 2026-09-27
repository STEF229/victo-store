import { render, screen, within } from '@testing-library/react';
import { beforeEach, describe, expect, it } from 'vitest';
import PagePanier from '../src/app/panier/page';
import { PanierProvider } from '../src/components/panier/PanierProvider';
import { PRODUITS } from '../src/lib/donnees';
import { CLE_PANIER } from '../src/lib/panier';

const PRODUIT = PRODUITS.find((p) => p.variantes.some((v) => v.stock > 0))!;
const VARIANTE = PRODUIT.variantes.find((v) => v.stock > 0)!;

beforeEach(() => window.localStorage.clear());

describe('page panier', () => {
  it('assemble en-tête, fil d’Ariane, titre, contenu et pied', () => {
    render(<PanierProvider><PagePanier /></PanierProvider>);
    expect(screen.getByRole('banner')).toBeInTheDocument();
    expect(screen.getByRole('heading', { level: 1, name: 'Votre panier' })).toBeInTheDocument();
    const fil = screen.getByTestId('fil-ariane');
    expect(within(fil).getByRole('link', { name: 'Accueil' })).toHaveAttribute('href', '/');
    expect(within(fil).getByText('Panier')).toHaveAttribute('aria-current', 'page');
    expect(screen.getByTestId('panier-vide')).toBeInTheDocument();
    expect(screen.getByRole('contentinfo')).toBeInTheDocument();
  });

  it('montre le panier enregistré et le même nombre dans l’en-tête', () => {
    window.localStorage.setItem(CLE_PANIER, JSON.stringify([{ slug: PRODUIT.slug, sku: VARIANTE.sku, quantite: 1 }]));
    render(<PanierProvider><PagePanier /></PanierProvider>);
    expect(screen.getAllByTestId('ligne-panier')).toHaveLength(1);
    expect(screen.getByTestId('entete-panier-compte').textContent).toBe('1');
  });
});
