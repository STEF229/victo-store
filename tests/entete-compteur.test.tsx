import { readFileSync } from 'node:fs';
import { render, screen } from '@testing-library/react';
import { beforeEach, describe, expect, it } from 'vitest';
import { PanierProvider } from '../src/components/panier/PanierProvider';
import { SiteHeader, type NavItem } from '../src/components/ui/SiteHeader';
import { CLE_PANIER } from '../src/lib/panier';

const NAV: NavItem[] = [{ label: 'Femme', href: '/femme' }];
const remplir = (quantites: number[]) =>
  window.localStorage.setItem(
    CLE_PANIER,
    JSON.stringify(quantites.map((q, i) => ({ slug: `p${i}`, sku: `p${i}-41`, quantite: q }))),
  );

beforeEach(() => window.localStorage.clear());

describe('en-tête — compteur du panier', () => {
  it('affiche le nombre d’articles du panier', () => {
    remplir([2, 1]);
    render(<PanierProvider><SiteHeader navItems={NAV} /></PanierProvider>);
    expect(screen.getByTestId('entete-panier-compte').textContent).toBe('3');
  });

  it('n’affiche aucune pastille pour un panier vide', () => {
    render(<PanierProvider><SiteHeader navItems={NAV} /></PanierProvider>);
    expect(screen.queryByTestId('entete-panier-compte')).toBeNull();
    expect(screen.getByTestId('entete-panier')).toBeInTheDocument();
  });

  it('laisse une valeur explicite l’emporter', () => {
    remplir([2, 1]);
    render(<PanierProvider><SiteHeader navItems={NAV} cartCount={5} /></PanierProvider>);
    expect(screen.getByTestId('entete-panier-compte').textContent).toBe('5');
  });
});

describe('en-tête — source', () => {
  const source = readFileSync('src/components/ui/SiteHeader.tsx', 'utf8');

  it('est un composant client branché sur usePanier', () => {
    expect(source.trimStart().startsWith("'use client'")).toBe(true);
    expect(source).toContain("import { usePanier } from '@/components/panier/PanierProvider';");
    expect(source).toContain('const compte = cartCount ?? nombre;');
  });

  it('ne donne plus de valeur par défaut à cartCount', () => {
    expect(source).not.toMatch(/cartCount\s*=\s*[^=]/);
  });
});
