import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { SiteHeader } from '../src/components/ui/SiteHeader';

const NAV = [
  { label: 'Femme', href: '/femme' },
  { label: 'Homme', href: '/homme' },
  { label: 'Soldes', href: '/soldes' },
];

describe('SiteHeader — structure', () => {
  it('rend un en-tête de bannière', () => {
    render(<SiteHeader navItems={NAV} />);
    expect(screen.getByRole('banner')).toBeInTheDocument();
  });

  it('rend la marque en lien vers l’accueil', () => {
    render(<SiteHeader navItems={NAV} />);
    const marque = screen.getByTestId('entete-marque');
    expect(marque).toHaveAttribute('href', '/');
    expect(marque.textContent).toContain('VICTO');
  });

  it('rend la navigation principale étiquetée', () => {
    render(<SiteHeader navItems={NAV} />);
    expect(screen.getByRole('navigation', { name: 'Navigation principale' })).toBeInTheDocument();
  });

  it('rend un lien par entrée de navigation', () => {
    render(<SiteHeader navItems={NAV} />);
    for (const item of NAV) {
      expect(screen.getByRole('link', { name: item.label })).toHaveAttribute('href', item.href);
    }
  });
});

describe('SiteHeader — panier', () => {
  it('rend un lien vers le panier', () => {
    render(<SiteHeader navItems={NAV} />);
    expect(screen.getByTestId('entete-panier')).toHaveAttribute('href', '/panier');
  });

  it('annonce un panier vide par défaut', () => {
    render(<SiteHeader navItems={NAV} />);
    const panier = screen.getByTestId('entete-panier');
    expect(panier).toHaveAttribute('data-cart-count', '0');
    expect(panier.getAttribute('aria-label')).toBe('Panier, 0 article');
  });

  it('annonce le nombre d’articles au singulier', () => {
    render(<SiteHeader navItems={NAV} cartCount={1} />);
    expect(screen.getByTestId('entete-panier').getAttribute('aria-label')).toBe('Panier, 1 article');
  });

  it('annonce le nombre d’articles au pluriel', () => {
    render(<SiteHeader navItems={NAV} cartCount={3} />);
    const panier = screen.getByTestId('entete-panier');
    expect(panier).toHaveAttribute('data-cart-count', '3');
    expect(panier.getAttribute('aria-label')).toBe('Panier, 3 articles');
  });

  it('affiche la pastille de compte seulement si le panier est garni', () => {
    const { rerender } = render(<SiteHeader navItems={NAV} />);
    expect(screen.queryByTestId('entete-panier-compte')).toBeNull();
    rerender(<SiteHeader navItems={NAV} cartCount={2} />);
    expect(screen.getByTestId('entete-panier-compte')).toHaveTextContent('2');
  });
});
