import { fireEvent, render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { InfosProduit } from '../src/components/produit/InfosProduit';
import type { Produit } from '../src/lib/catalogue';
import { TEXTE_LIVRAISON } from '../src/lib/fiche-produit';

const SANS_COMPOSITION: Produit = {
  id: 'p1', slug: 'pegasus', nom: 'Pegasus', marque: { id: 'm1', nom: 'Nike', slug: 'nike' },
  imageUrl: '/img/x.svg', prixCents: 12600, description: 'Amorti réactif.',
  variantes: [{ id: 'v40', taille: '40', sku: 'peg-40', stock: 5 }],
};
const COMPLET: Produit = { ...SANS_COMPOSITION, composition: 'Tige en mesh.' };
const titre = (nom: string) => screen.getByRole('button', { name: nom });

describe('InfosProduit — réassurance', () => {
  it('reprend les trois engagements, avec leurs icônes', () => {
    const { container } = render(<InfosProduit produit={COMPLET} />);
    const items = Array.from(container.querySelectorAll('ul > li'));
    expect(items.map((li) => li.textContent)).toEqual([
      "Livraison offerte — reçue d'ici 2 à 4 jours ouvrables",
      'Retours gratuits pendant 30 jours',
      "Authenticité garantie, neuf en boîte d'origine",
    ]);
    const icones = ['lucide-truck', 'lucide-rotate-ccw', 'lucide-shield-check'];
    expect(items.map((li, i) => li.querySelector(`svg.${icones[i] ?? 'absente'}`) !== null)).toEqual([true, true, true]);
  });
});

describe('InfosProduit — sections', () => {
  it('ouvre la description et ferme les autres', () => {
    render(<InfosProduit produit={COMPLET} />);
    expect(titre('Description')).toHaveAttribute('aria-expanded', 'true');
    expect(screen.getByText('Amorti réactif.')).toBeInTheDocument();
    expect(titre('Détails et composition')).toHaveAttribute('aria-expanded', 'false');
    expect(screen.queryByText('Tige en mesh.')).toBeNull();
    expect(titre('Livraison et retours')).toHaveAttribute('aria-expanded', 'false');
  });

  it('ouvre et referme une section au clic', () => {
    render(<InfosProduit produit={COMPLET} />);
    fireEvent.click(titre('Livraison et retours'));
    expect(titre('Livraison et retours')).toHaveAttribute('aria-expanded', 'true');
    expect(screen.getByText(TEXTE_LIVRAISON)).toBeInTheDocument();
    fireEvent.click(titre('Description'));
    expect(screen.queryByText('Amorti réactif.')).toBeNull();
    expect(screen.getByText(TEXTE_LIVRAISON)).toBeInTheDocument();
  });

  it('omet une section sans texte', () => {
    render(<InfosProduit produit={SANS_COMPOSITION} />);
    expect(screen.queryByRole('button', { name: 'Détails et composition' })).toBeNull();
    expect(screen.getAllByRole('button').map((b: HTMLElement) => b.textContent)).toEqual([
      'Description', 'Livraison et retours',
    ]);
  });
});
