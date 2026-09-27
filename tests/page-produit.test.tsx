import { fireEvent, render, screen, within } from '@testing-library/react';
import { beforeEach, describe, expect, it } from 'vitest';
import PageProduit from '../src/app/produits/[slug]/page';
import { PanierProvider } from '../src/components/panier/PanierProvider';
import { PRODUITS } from '../src/lib/donnees';

// Un produit réel qui a au moins une pointure disponible.
const PRODUIT = PRODUITS.find((p) => p.variantes.some((v) => v.stock > 0))!;
const DISPONIBLE = PRODUIT.variantes.find((v) => v.stock > 0)!;
const page = (slug: string) => PageProduit({ params: Promise.resolve({ slug }) });

beforeEach(() => window.localStorage.clear());

describe('page produit — structure', () => {
  it('assemble en-tête, fil d’Ariane, galerie, achat, infos et pied', async () => {
    render(await page(PRODUIT.slug));
    expect(screen.getByRole('banner')).toBeInTheDocument();
    expect(screen.getByRole('heading', { level: 1, name: PRODUIT.nom })).toBeInTheDocument();
    for (const id of ['fil-ariane', 'galerie', 'bloc-achat', 'infos-produit', 'fiche-marque']) {
      expect(screen.getByTestId(id), id).toBeInTheDocument();
    }
    expect(screen.getByTestId('fiche-marque').textContent).toBe(PRODUIT.marque.nom);
    expect(screen.getByRole('contentinfo')).toBeInTheDocument();
  });

  it('propose d’autres produits, sans le produit affiché', async () => {
    render(await page(PRODUIT.slug));
    const zone = screen.getByTestId('vous-aimerez-aussi');
    const cartes = within(zone).getAllByTestId('carte-produit');
    expect(cartes).toHaveLength(Math.min(4, PRODUITS.length - 1));
    expect(within(zone).queryAllByTestId('carte-nom').map((e: HTMLElement) => e.textContent)).not.toContain(PRODUIT.nom);
  });

  it('renvoie une page introuvable pour un produit inconnu', async () => {
    await expect(page('produit-qui-n-existe-pas')).rejects.toThrow();
  });
});

describe('page produit — ajout au panier', () => {
  it('ajoute depuis la fiche et met à jour le compteur de l’en-tête', async () => {
    render(<PanierProvider>{await page(PRODUIT.slug)}</PanierProvider>);
    const bloc = screen.getByTestId('bloc-achat');
    fireEvent.click(within(bloc).getByRole('button', { name: DISPONIBLE.taille }));
    fireEvent.click(within(bloc).getByRole('button', { name: 'Ajouter au panier' }));
    expect(screen.getByTestId('entete-panier-compte').textContent).toBe('1');
  });
});
