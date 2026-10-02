import { fireEvent, render, screen, within } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { NavigationPrincipale } from '../src/components/navigation/NavigationPrincipale';
import { listerMarques } from '../src/lib/donnees';
import { NAV } from '../src/lib/navigation';

const SURVOL = ['transition-colors', 'hover:text-[var(--vs-accent)]'];
const classes = (el: Element) => (el.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);
const rubrique = (nom: string) => within(screen.getByRole('navigation', { name: 'Navigation principale' })).getByRole('link', { name: nom });
const panneau = (nom: string) => screen.getByRole('region', { name: `Sous-catégories de ${nom}` });
const survole = (zone: HTMLElement, nom: string | RegExp) => {
  const lien = within(zone).getByRole('link', { name: nom });
  for (const k of SURVOL) expect(classes(lien), `${String(nom)} : ${k}`).toContain(k);
};

describe('méga-menu — couleur au survol', () => {
  it('colore les sous-catégories, leurs enfants et les « Tout… »', () => {
    render(<NavigationPrincipale navItems={NAV} />);
    fireEvent.mouseEnter(rubrique('Homme'));
    const zone = panneau('Homme');
    survole(zone, 'Chaussures');
    survole(zone, 'Course');
    survole(zone, 'Tout vêtements');
    survole(zone, /^Tout voir Homme/);
  });

  it('colore les vignettes de Chaussures et des marques', () => {
    render(<NavigationPrincipale navItems={NAV} />);
    fireEvent.mouseEnter(rubrique('Chaussures'));
    survole(panneau('Chaussures'), 'Sneakers');
    fireEvent.mouseEnter(rubrique('Marques'));
    const premiere = listerMarques().find(() => true);
    if (premiere) survole(panneau('Marques'), premiere.nom);
  });
});
