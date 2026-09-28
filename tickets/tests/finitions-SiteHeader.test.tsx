import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { SiteHeader } from '../src/components/ui/SiteHeader';

const NAV = [{ label: 'Femme', href: '/femme' }];

describe('SiteHeader — icônes lucide', () => {
  it.each([
    ['Ouvrir le menu', 'lucide-menu'],
    ['Rechercher', 'lucide-search'],
  ])('le bouton « %s » porte l’icône %s', (nom, classe) => {
    render(<SiteHeader navItems={NAV} />);
    expect(screen.getByRole('button', { name: nom }).querySelector(`svg.${classe}`)).not.toBeNull();
  });

  // « Mon compte » est cherché par son étiquette : bouton avant le 102m, lien vers /compte après.
  it('« Mon compte » porte l’icône lucide-user', () => {
    render(<SiteHeader navItems={NAV} />);
    expect(screen.getByLabelText('Mon compte').querySelector('svg.lucide-user')).not.toBeNull();
  });

  it('le panier porte un sac', () => {
    render(<SiteHeader navItems={NAV} cartCount={2} />);
    expect(screen.getByTestId('entete-panier').querySelector('svg.lucide-shopping-bag')).not.toBeNull();
  });

  it('ne contient plus aucune icône dessinée à la main', () => {
    const { container } = render(<SiteHeader navItems={NAV} cartCount={2} />);
    const svgs = Array.from(container.querySelectorAll('svg'));
    expect(svgs.length).toBeGreaterThanOrEqual(4);
    for (const s of svgs) {
      expect(s.classList.contains('lucide')).toBe(true);
      expect(s.getAttribute('aria-hidden')).toBe('true');
    }
  });
});
