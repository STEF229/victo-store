import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { SiteHeader, type NavItem } from '../src/components/ui/SiteHeader';

const classes = (el: Element) => el.className.split(/\s+/).filter(Boolean);
const NAV: NavItem[] = [
  { label: 'Femme', href: '/femme' },
  { label: 'Homme', href: '/homme' },
  { label: 'Soldes', href: '/soldes', promo: true },
];

describe('SiteHeader — disposition', () => {
  it('répartit l’en-tête en trois zones', () => {
    render(<SiteHeader navItems={NAV} />);
    const zones = screen.getByTestId('entete-marque').closest('.grid-cols-3');
    expect(zones).not.toBeNull();
    for (const c of ['grid', 'grid-cols-3', 'items-center']) expect(classes(zones as Element)).toContain(c);
  });

  it('masque la navigation sur téléphone', () => {
    render(<SiteHeader navItems={NAV} />);
    const nav = screen.getByRole('navigation', { name: 'Navigation principale' });
    for (const c of ['hidden', 'lg:flex']) expect(classes(nav)).toContain(c);
  });
});

describe('SiteHeader — actions', () => {
  it.each(['Ouvrir le menu', 'Rechercher', 'Mon compte'])('propose le bouton %s', (nom) => {
    render(<SiteHeader navItems={NAV} />);
    expect(screen.getByRole('button', { name: nom })).toHaveAttribute('type', 'button');
  });

  it('réserve le bouton de menu au téléphone', () => {
    render(<SiteHeader navItems={NAV} />);
    expect(classes(screen.getByRole('button', { name: 'Ouvrir le menu' }))).toContain('lg:hidden');
  });

  it('colore la pastille du panier en cobalt', () => {
    render(<SiteHeader navItems={NAV} cartCount={2} />);
    expect(classes(screen.getByTestId('entete-panier-compte'))).toContain('bg-[var(--vs-accent)]');
  });
});

describe('SiteHeader — entrée promo', () => {
  it('colore en rouge seulement l’entrée marquée promo', () => {
    render(<SiteHeader navItems={NAV} />);
    expect(classes(screen.getByRole('link', { name: 'Soldes' }))).toContain('text-[var(--vs-promo)]');
    expect(classes(screen.getByRole('link', { name: 'Femme' }))).not.toContain('text-[var(--vs-promo)]');
  });
});
