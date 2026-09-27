import { fireEvent, render, screen, within } from '@testing-library/react';
import { beforeEach, describe, expect, it } from 'vitest';
import { PanierProvider } from '../src/components/panier/PanierProvider';
import { VuePanier } from '../src/components/panier/VuePanier';
import { PRODUITS } from '../src/lib/donnees';
import { formatPrice } from '../src/lib/formatPrice';
import { CLE_PANIER } from '../src/lib/panier';

// Deux pointures réelles avec assez de stock pour monter à 2.
const CHOIX = PRODUITS.flatMap((p) => p.variantes.filter((v) => v.stock >= 2).map((v) => ({ p, v }))).filter(
  (c, i, tous) => tous.findIndex((x) => x.p.id === c.p.id) === i,
).slice(0, 2);
const [A, B] = [CHOIX[0]!, CHOIX[1]!];
const remplir = (lignes: Array<{ slug: string; sku: string; quantite: number }>) =>
  window.localStorage.setItem(CLE_PANIER, JSON.stringify(lignes));
const poser = () => render(<PanierProvider><VuePanier /></PanierProvider>);

beforeEach(() => window.localStorage.clear());

describe('VuePanier — panier vide', () => {
  it('invite à voir les soldes', () => {
    poser();
    const vide = screen.getByTestId('panier-vide');
    expect(within(vide).getByRole('heading', { level: 2, name: 'Votre panier est vide' })).toBeInTheDocument();
    expect(within(vide).getByRole('link', { name: 'Voir les soldes' })).toHaveAttribute('href', '/soldes');
    expect(screen.queryByTestId('recap-panier')).toBeNull();
  });

  it('traite une ligne dont le produit a disparu comme un panier vide', () => {
    remplir([{ slug: 'produit-disparu', sku: 'x-41', quantite: 1 }]);
    poser();
    expect(screen.getByTestId('panier-vide')).toBeInTheDocument();
  });
});

describe('VuePanier — panier rempli', () => {
  it('affiche les lignes, le nombre d’articles et le récapitulatif', () => {
    remplir([{ slug: A.p.slug, sku: A.v.sku, quantite: 1 }, { slug: B.p.slug, sku: B.v.sku, quantite: 1 }]);
    poser();
    expect(screen.getAllByTestId('ligne-panier')).toHaveLength(2);
    expect(screen.getByTestId('panier-articles').textContent).toBe('2 articles');
    expect(screen.getByTestId('recap-total').textContent).toBe(formatPrice(A.p.prixCents + B.p.prixCents));
    expect(screen.getByRole('link', { name: 'Continuer mes achats' })).toHaveAttribute('href', '/');
  });

  it('change une quantité puis retire une ligne', () => {
    remplir([{ slug: A.p.slug, sku: A.v.sku, quantite: 1 }, { slug: B.p.slug, sku: B.v.sku, quantite: 1 }]);
    poser();
    const premiere = () => screen.getAllByTestId('ligne-panier')[0]!;
    fireEvent.click(within(premiere()).getByRole('button', { name: 'Augmenter la quantité' }));
    expect(within(premiere()).getByTestId('ligne-quantite').textContent).toBe('2');
    expect(screen.getByTestId('panier-articles').textContent).toBe('3 articles');
    expect(screen.getByTestId('recap-total').textContent).toBe(formatPrice(A.p.prixCents * 2 + B.p.prixCents));
    fireEvent.click(within(premiere()).getByRole('button', { name: 'Retirer' }));
    expect(screen.getAllByTestId('ligne-panier')).toHaveLength(1);
    expect(screen.getByTestId('panier-articles').textContent).toBe('1 article');
  });

  it('se vide quand on retire la dernière ligne', () => {
    remplir([{ slug: A.p.slug, sku: A.v.sku, quantite: 1 }]);
    poser();
    fireEvent.click(screen.getByRole('button', { name: 'Retirer' }));
    expect(screen.getByTestId('panier-vide')).toBeInTheDocument();
  });
});
