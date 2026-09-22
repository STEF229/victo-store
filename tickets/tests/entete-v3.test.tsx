import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { SiteHeader, type NavItem } from '../src/components/ui/SiteHeader';

const classes = (el: Element) => el.className.split(/\s+/).filter(Boolean);
const NAV: NavItem[] = [
  { label: 'Femme', href: '/femme' },
  { label: 'Homme', href: '/homme' },
  { label: 'Soldes', href: '/soldes', promo: true },
];

describe('en-tête — barre noire unique', () => {
  it('rend une bannière noire', () => {
    render(<SiteHeader navItems={NAV} />);
    const entete = screen.getByTestId('entete');
    expect(entete).toBe(screen.getByRole('banner'));
    for (const k of ['bg-[var(--vs-noir)]', 'text-[var(--vs-blanc)]']) expect(classes(entete)).toContain(k);
  });

  it('répartit logo, navigation et actions sur une seule ligne', () => {
    render(<SiteHeader navItems={NAV} />);
    // La rangée en grille est l'enfant direct de l'en-tête ; le lien de marque est
    // dans la zone de gauche, donc on part de l'en-tête, pas du parent du lien.
    const ligne = screen.getByTestId('entete').firstElementChild as Element;
    for (const k of ['grid', 'h-20', 'grid-cols-[auto_1fr_auto]', 'items-center']) {
      expect(classes(ligne)).toContain(k);
    }
    expect(ligne.contains(screen.getByTestId('entete-marque'))).toBe(true);
    expect(ligne.contains(screen.getByRole('navigation', { name: 'Navigation principale' }))).toBe(true);
  });

  it('centre la navigation et la masque sur téléphone', () => {
    render(<SiteHeader navItems={NAV} />);
    const nav = screen.getByRole('navigation', { name: 'Navigation principale' });
    for (const k of ['hidden', 'justify-self-center', 'gap-8', 'lg:flex']) expect(classes(nav)).toContain(k);
  });

  it('colore en rouge clair la seule entrée promo', () => {
    render(<SiteHeader navItems={NAV} />);
    expect(classes(screen.getByRole('link', { name: 'Soldes' }))).toContain('text-[#FF5A74]');
    expect(classes(screen.getByRole('link', { name: 'Femme' }))).not.toContain('text-[#FF5A74]');
  });
});

describe('en-tête — recherche et actions', () => {
  it('propose un champ de recherche étiqueté', () => {
    render(<SiteHeader navItems={NAV} />);
    const champ = screen.getByLabelText('Rechercher un produit');
    expect(champ).toHaveAttribute('id', 'recherche-entete');
    expect(champ).toHaveAttribute('type', 'search');
    expect(champ).toHaveAttribute('placeholder', 'Rechercher');
  });

  it('réserve le bouton de menu au téléphone', () => {
    render(<SiteHeader navItems={NAV} />);
    const menu = screen.getByRole('button', { name: 'Ouvrir le menu' });
    expect(menu).toHaveAttribute('type', 'button');
    expect(classes(menu)).toContain('lg:hidden');
    expect(menu.querySelector('svg.lucide-menu')).not.toBeNull();
  });

  it('rend le compte et le panier avec leurs icônes lucide', () => {
    render(<SiteHeader navItems={NAV} cartCount={2} />);
    expect(screen.getByRole('button', { name: 'Mon compte' }).querySelector('svg.lucide-user')).not.toBeNull();
    const panier = screen.getByTestId('entete-panier');
    expect(panier.querySelector('svg.lucide-shopping-bag')).not.toBeNull();
    expect(classes(screen.getByTestId('entete-panier-compte'))).toContain('bg-[var(--vs-accent)]');
  });

  it("n'utilise que des icônes lucide", () => {
    const { container } = render(<SiteHeader navItems={NAV} cartCount={1} />);
    const svgs = Array.from(container.querySelectorAll('svg'));
    expect(svgs.length).toBeGreaterThanOrEqual(4);
    for (const s of svgs) {
      expect(s.classList.contains('lucide')).toBe(true);
      expect(s.getAttribute('aria-hidden')).toBe('true');
    }
  });
});

describe('en-tête — filet d’annonces', () => {
  it('reprend les trois messages sous la barre', () => {
    render(<SiteHeader navItems={NAV} />);
    const filet = screen.getByTestId('filet-annonce');
    expect(Array.from(filet.querySelectorAll('span')).map((s) => s.textContent)).toEqual([
      'Livraison offerte au Canada',
      'Retours gratuits 30 jours',
      'Authenticité garantie',
    ]);
  });

  it('se place après la barre', () => {
    render(<SiteHeader navItems={NAV} />);
    const entete = screen.getByTestId('entete');
    const filet = screen.getByTestId('filet-annonce');
    expect(entete.contains(filet)).toBe(false);
    expect(entete.compareDocumentPosition(filet) & Node.DOCUMENT_POSITION_FOLLOWING).toBeTruthy();
  });

  it('porte les couleurs du filet et ne garde qu’un message sur téléphone', () => {
    render(<SiteHeader navItems={NAV} />);
    const filet = screen.getByTestId('filet-annonce');
    for (const k of ['bg-[var(--vs-surface)]', 'text-[var(--vs-gris)]', 'border-b', 'border-[var(--vs-ligne)]']) {
      expect(classes(filet)).toContain(k);
    }
    const messages = Array.from(filet.querySelectorAll('span'));
    expect(classes(messages[0] as Element)).not.toContain('hidden');
    for (const m of messages.slice(1)) {
      expect(classes(m)).toContain('hidden');
      expect(classes(m)).toContain('sm:inline');
    }
  });
});
