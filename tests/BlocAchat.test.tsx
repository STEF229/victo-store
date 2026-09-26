import { fireEvent, render, screen } from '@testing-library/react';
import { beforeEach, describe, expect, it } from 'vitest';
import { PanierProvider } from '../src/components/panier/PanierProvider';
import { BlocAchat } from '../src/components/produit/BlocAchat';
import { economieCents, type Produit } from '../src/lib/catalogue';
import { formatPrice } from '../src/lib/formatPrice';
import { CLE_PANIER } from '../src/lib/panier';

// getAttribute('class') et non className : sur un SVG, className n'est pas une chaîne.
const classes = (el: Element) => (el.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);
function porte(el: Element, chaine: string) {
  const nom = el.getAttribute('aria-label') ?? el.getAttribute('data-testid') ?? el.textContent;
  for (const k of chaine.split(' ')) expect(classes(el), `${nom} : classe ${k} manquante`).toContain(k);
}
const SANS_PROMO: Produit = {
  id: 'p1', slug: 'pegasus', nom: 'Pegasus', marque: { id: 'm1', nom: 'Nike', slug: 'nike' },
  imageUrl: '/img/x.svg', prixCents: 12600, categorie: 'chaussures',
  description: 'Amorti réactif.',
  variantes: [
    { id: 'v40', taille: '40', sku: 'peg-40', stock: 5 },
    { id: 'v41', taille: '41', sku: 'peg-41', stock: 0 },
    { id: 'v42', taille: '42', sku: 'peg-42', stock: 2 },
  ],
};
const PROMO: Produit = { ...SANS_PROMO, prixCompareCents: 18000 };
const bouton = (nom: string) => screen.getByRole('button', { name: nom });
const quantite = () => screen.getByTestId('quantite').textContent;

beforeEach(() => window.localStorage.clear());

describe('BlocAchat — prix', () => {
  it('affiche le prix remisé, le prix barré et l’économie', () => {
    render(<BlocAchat produit={PROMO} />);
    expect(screen.getByTestId('fiche-prix').textContent).toBe(formatPrice(12600));
    porte(screen.getByTestId('fiche-prix'), 'text-[32px] font-black text-[var(--vs-promo)]');
    expect(screen.getByTestId('fiche-prix-barre').textContent).toBe(formatPrice(18000));
    expect(screen.getByTestId('fiche-economie').textContent).toBe(`Économisez ${formatPrice(economieCents(PROMO))}`);
    porte(screen.getByTestId('fiche-economie'), 'rounded-full bg-[#FFD3DB] text-[var(--vs-promo)]');
    expect(screen.getByTestId('fiche-description').textContent).toBe('Amorti réactif.');
  });

  it('affiche un prix simple hors promotion', () => {
    render(<BlocAchat produit={SANS_PROMO} />);
    porte(screen.getByTestId('fiche-prix'), 'text-[var(--vs-noir)]');
    expect(screen.queryByTestId('fiche-prix-barre')).toBeNull();
    expect(screen.queryByTestId('fiche-economie')).toBeNull();
  });
});

describe('BlocAchat — pointure et quantité', () => {
  it('annonce un stock bas pour la pointure choisie', () => {
    render(<BlocAchat produit={PROMO} />);
    expect(screen.queryByTestId('stock-bas')).toBeNull();
    fireEvent.click(bouton('42'));
    expect(screen.getByTestId('stock-bas').textContent).toBe('Plus que 2 paires en 42');
    fireEvent.click(bouton('40'));
    expect(screen.queryByTestId('stock-bas')).toBeNull();
  });

  it('plafonne la quantité au stock et la réduit en changeant de pointure', () => {
    render(<BlocAchat produit={PROMO} />);
    expect(quantite()).toBe('1');
    expect(bouton('Diminuer la quantité')).toBeDisabled();
    porte(bouton('Diminuer la quantité'), 'text-[#B5B5BA]');
    fireEvent.click(bouton('40'));
    for (let i = 0; i < 6; i += 1) fireEvent.click(bouton('Augmenter la quantité'));
    expect(quantite()).toBe('5');
    fireEvent.click(bouton('42'));
    expect(quantite()).toBe('2');
    fireEvent.click(bouton('Diminuer la quantité'));
    expect(quantite()).toBe('1');
  });
});

describe('BlocAchat — ajout au panier', () => {
  it('refuse sans pointure, avec un message', () => {
    render(<BlocAchat produit={PROMO} />);
    fireEvent.click(bouton('Ajouter au panier'));
    expect(screen.getByRole('alert').textContent).toBe("Choisissez une pointure avant d'ajouter au panier.");
    expect(screen.queryByRole('status')).toBeNull();
  });

  it('ajoute la pointure et la quantité choisies, puis confirme', () => {
    render(<PanierProvider><BlocAchat produit={PROMO} /></PanierProvider>);
    fireEvent.click(bouton('Ajouter au panier'));
    fireEvent.click(bouton('42'));
    expect(screen.queryByRole('alert')).toBeNull();
    fireEvent.click(bouton('Augmenter la quantité'));
    fireEvent.click(bouton('Ajouter au panier'));
    expect(JSON.parse(window.localStorage.getItem(CLE_PANIER) ?? '[]')).toEqual([
      { slug: 'pegasus', sku: 'peg-42', quantite: 2 },
    ]);
    const statut = screen.getByRole('status');
    expect(statut.textContent).toBe('Ajouté au panier — pointure 42, quantité 2');
    porte(statut, 'text-[var(--vs-accent)]');
    expect(statut.querySelector('svg.lucide-check')).not.toBeNull();
  });
});

describe('BlocAchat — boutons', () => {
  it('habille le bouton d’ajout et bascule le favori', () => {
    render(<BlocAchat produit={PROMO} />);
    porte(bouton('Ajouter au panier'), 'h-[58px] rounded-full bg-[var(--vs-accent)] text-[var(--vs-blanc)] sm:flex-1');
    const favori = bouton('Ajouter aux favoris');
    expect(favori).toHaveAttribute('aria-pressed', 'false');
    fireEvent.click(favori);
    expect(favori).toHaveAttribute('aria-pressed', 'true');
    const coeur = favori.querySelector('svg.lucide-heart');
    expect(coeur).not.toBeNull();
    porte(coeur as Element, 'fill-[var(--vs-promo)] text-[var(--vs-promo)]');
  });
});
