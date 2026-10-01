import { act, fireEvent, render, screen, within } from '@testing-library/react';
import { afterEach, describe, expect, it, vi } from 'vitest';
import { NavigationPrincipale } from '../src/components/navigation/NavigationPrincipale';
import { produitsDe } from '../src/lib/arbre-categories';
import { hrefMarque } from '../src/lib/catalogue';
import { listerMarques, listerProduits } from '../src/lib/donnees';
import { NAV } from '../src/lib/navigation';

const etat = vi.hoisted(() => ({ chemin: null as string | null }));
vi.mock('next/navigation', async (original) => ({
  ...(await original<typeof import('next/navigation')>()),
  usePathname: () => etat.chemin,
}));

const classes = (el: Element) => (el.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);
const nav = () => screen.getByRole('navigation', { name: 'Navigation principale' });
const rubrique = (nom: string) => within(nav()).getByRole('link', { name: nom });
const panneau = (nom: string) => screen.queryByRole('region', { name: `Sous-catégories de ${nom}` });
const href = (zone: HTMLElement, nom: string) => within(zone).getByRole('link', { name: nom }).getAttribute('href');

afterEach(() => { vi.useRealTimers(); etat.chemin = null; });

describe('NavigationPrincipale — comme avant', () => {
  it('garde le nom, les classes et le marquage de la page active', () => {
    etat.chemin = '/homme/chaussures';
    render(<NavigationPrincipale navItems={NAV} />);
    for (const k of ['hidden', 'justify-self-center', 'gap-8', 'lg:flex']) expect(classes(nav())).toContain(k);
    expect(rubrique('Homme')).toHaveAttribute('aria-current', 'page');
    expect(rubrique('Soldes')).toHaveAttribute('href', '/soldes');
    expect(classes(rubrique('Soldes'))).toContain('text-[#FF5A74]');
    expect(panneau('Homme')).toBeNull();
  });
});

describe('NavigationPrincipale — méga-menu', () => {
  it('ouvre les sous-catégories de Homme sur deux niveaux', () => {
    render(<NavigationPrincipale navItems={NAV} />);
    fireEvent.mouseEnter(rubrique('Homme'));
    const zone = panneau('Homme') as HTMLElement;
    expect(zone).not.toBeNull();
    expect(href(zone, 'Chaussures')).toBe('/homme/chaussures');
    expect(href(zone, 'Course')).toBe('/homme/chaussures/course');
    expect(href(zone, 'Tout vêtements')).toBe('/homme/vetements');
    const n = produitsDe(listerProduits(), 'homme', []).length;
    expect(href(zone, `Tout voir Homme (${n} ${n > 1 ? 'produits' : 'produit'})`)).toBe('/homme');
  });

  it('montre les chaussures en vignettes et les marques', () => {
    render(<NavigationPrincipale navItems={NAV} />);
    fireEvent.mouseEnter(rubrique('Chaussures'));
    expect(href(panneau('Chaussures') as HTMLElement, 'Sneakers')).toBe('/chaussures/sneakers');
    fireEvent.mouseEnter(rubrique('Marques'));
    expect(panneau('Chaussures')).toBeNull();
    const marques = panneau('Marques') as HTMLElement;
    for (const m of listerMarques()) expect(href(marques, m.nom)).toBe(hrefMarque(m));
  });

  it('n’ouvre rien pour les soldes, et s’ouvre aussi au clavier', () => {
    render(<NavigationPrincipale navItems={NAV} />);
    fireEvent.mouseEnter(rubrique('Soldes'));
    expect(screen.queryByRole('region')).toBeNull();
    fireEvent.focus(rubrique('Femme'));
    expect(panneau('Femme')).not.toBeNull();
  });

  it('se ferme avec Échap', () => {
    render(<NavigationPrincipale navItems={NAV} />);
    fireEvent.mouseEnter(rubrique('Homme'));
    fireEvent.keyDown(rubrique('Homme'), { key: 'Escape' });
    expect(panneau('Homme')).toBeNull();
  });

  it('se ferme 200 ms après la sortie, sauf si la souris revient', () => {
    vi.useFakeTimers();
    render(<NavigationPrincipale navItems={NAV} />);
    fireEvent.mouseEnter(rubrique('Homme'));
    fireEvent.mouseLeave(nav());
    act(() => { vi.advanceTimersByTime(100); });
    expect(panneau('Homme')).not.toBeNull();
    fireEvent.mouseEnter(nav());
    act(() => { vi.advanceTimersByTime(300); });
    expect(panneau('Homme')).not.toBeNull();
    fireEvent.mouseLeave(nav());
    act(() => { vi.advanceTimersByTime(250); });
    expect(panneau('Homme')).toBeNull();
  });
});
