import { render, screen, within } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import { SiteHeader } from '../src/components/ui/SiteHeader';
import { NAV } from '../src/lib/navigation';

const etat = vi.hoisted(() => ({ chemin: null as string | null }));
vi.mock('next/navigation', async (original) => ({
  ...(await original<typeof import('next/navigation')>()),
  usePathname: () => etat.chemin,
}));

const classes = (el: Element) => (el.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);
const lien = (libelle: string) => within(screen.getByRole('navigation', { name: 'Navigation principale' })).getByRole('link', { name: libelle });
const href = (libelle: string) => NAV.find((i) => i.label === libelle)?.href ?? '';
const actifs = () => within(screen.getByRole('navigation', { name: 'Navigation principale' }))
  .queryAllByRole('link').filter((a: HTMLElement) => a.getAttribute('aria-current') === 'page').map((a: HTMLElement) => a.textContent);
const poser = (chemin: string | null) => { etat.chemin = chemin; render(<SiteHeader navItems={NAV} />); };
const TRAIT = ['font-extrabold', 'underline', 'decoration-2', 'underline-offset-[10px]'];

describe('en-tête — rubrique de la page en cours', () => {
  it('marque la rubrique ouverte, et elle seule', () => {
    poser(href('Femme'));
    expect(actifs()).toEqual(['Femme']);
    for (const k of TRAIT) expect(classes(lien('Femme')), `Femme : ${k}`).toContain(k);
    expect(classes(lien('Homme'))).not.toContain('underline');
  });

  it('reste marquée sur une page de la rubrique', () => {
    poser(`${href('Marques')}/nike`);
    expect(actifs()).toEqual(['Marques']);
  });

  it('garde le rouge des soldes, avec le trait quand on y est', () => {
    poser(href('Soldes'));
    for (const k of ['text-[#FF5A74]', ...TRAIT]) expect(classes(lien('Soldes')), `Soldes : ${k}`).toContain(k);
  });

  it('garde les soldes en rouge, sans trait, ailleurs', () => {
    poser(href('Femme'));
    expect(classes(lien('Soldes'))).toContain('text-[#FF5A74]');
    expect(classes(lien('Soldes'))).not.toContain('underline');
  });

  it('ne marque rien hors des rubriques, ni sans chemin', () => {
    poser('/produits/air-zoom-pegasus-41');
    expect(actifs()).toEqual([]);
  });

  it('ne marque rien quand le chemin est inconnu', () => {
    poser(null);
    expect(actifs()).toEqual([]);
  });
});
