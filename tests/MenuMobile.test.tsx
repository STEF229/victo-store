import { fireEvent, render, screen, within } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { MenuMobile } from '../src/components/navigation/MenuMobile';
import { ARBRE } from '../src/lib/arbre-categories';
import { NAV } from '../src/lib/navigation';

const classes = (el: Element) => (el.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);
const ouvrir = () => fireEvent.click(screen.getByRole('button', { name: 'Ouvrir le menu' }));
const tiroir = () => screen.getByRole('dialog', { name: 'Menu' });

describe('MenuMobile — le bouton', () => {
  it('garde le nom, la classe et l’icône du bouton de l’en-tête', () => {
    render(<MenuMobile navItems={NAV} />);
    const bouton = screen.getByRole('button', { name: 'Ouvrir le menu' });
    expect(classes(bouton)).toContain('lg:hidden');
    expect(bouton.querySelector('svg.lucide-menu')).not.toBeNull();
    expect(bouton).toHaveAttribute('aria-expanded', 'false');
    expect(screen.queryByRole('dialog')).toBeNull();
  });
});

describe('MenuMobile — le tiroir', () => {
  it('liste les rubriques, puis les sous-catégories de celle choisie', () => {
    render(<MenuMobile navItems={NAV} />);
    ouvrir();
    const t = within(tiroir());
    expect(t.getByRole('link', { name: 'Marques' })).toHaveAttribute('href', '/marques');
    expect(classes(t.getByRole('link', { name: 'Soldes' }))).toContain('text-[#E4002B]');
    fireEvent.click(t.getByRole('button', { name: 'Homme' }));
    expect(t.getByRole('link', { name: 'Tout voir Homme' })).toHaveAttribute('href', '/homme');
    const sections = ARBRE.homme.enfants.map((sc) => sc.libelle);
    for (const s of sections) expect(t.getByRole('button', { name: s })).toHaveAttribute('aria-expanded', 'false');
    fireEvent.click(t.getByRole('button', { name: 'Chaussures' }));
    expect(t.getByRole('button', { name: 'Chaussures' })).toHaveAttribute('aria-expanded', 'true');
    expect(t.getByRole('link', { name: 'Course' })).toHaveAttribute('href', '/homme/chaussures/course');
    expect(t.getByRole('link', { name: 'Tout chaussures' })).toHaveAttribute('href', '/homme/chaussures');
  });

  it('revient aux rubriques', () => {
    render(<MenuMobile navItems={NAV} />);
    ouvrir();
    fireEvent.click(within(tiroir()).getByRole('button', { name: 'Femme' }));
    fireEvent.click(within(tiroir()).getByRole('button', { name: 'Femme' }));
    expect(within(tiroir()).getByRole('button', { name: 'Homme' })).toBeInTheDocument();
  });

  it('propose directement les sous-catégories de Chaussures, sans niveau à déplier', () => {
    render(<MenuMobile navItems={NAV} />);
    ouvrir();
    fireEvent.click(within(tiroir()).getByRole('button', { name: 'Chaussures' }));
    expect(within(tiroir()).getByRole('link', { name: 'Sneakers' })).toHaveAttribute('href', '/chaussures/sneakers');
  });

  // (cliquer sur un lien Next tenterait une navigation hors du routeur : non testé ici)
  it('se ferme par la croix, Échap ou le fond', () => {
    render(<MenuMobile navItems={NAV} />);
    ouvrir();
    fireEvent.click(screen.getByRole('button', { name: 'Fermer le menu' }));
    expect(screen.queryByRole('dialog')).toBeNull();
    ouvrir();
    fireEvent.keyDown(tiroir(), { key: 'Escape' });
    expect(screen.queryByRole('dialog')).toBeNull();
    ouvrir();
    fireEvent.click(screen.getByTestId('menu-mobile-fond'));
    expect(screen.queryByRole('dialog')).toBeNull();
  });
});
