import { render, screen, within } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { FilAriane } from '../src/components/produit/FilAriane';
import type { ElementFil } from '../src/lib/fiche-produit';

// getAttribute('class') et non className : sur un SVG, className n'est pas une chaîne.
const classes = (el: Element) => (el.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);
function porte(el: Element, chaine: string) {
  for (const k of chaine.split(' ')) expect(classes(el), `${el.tagName} : classe ${k} manquante`).toContain(k);
}
const ITEMS: ElementFil[] = [
  { label: 'Accueil', href: '/' },
  { label: 'Vêtements' },
  { label: 'Nike', href: '/marques/nike' },
  { label: 'Air Zoom Pegasus 41' },
];

describe('FilAriane', () => {
  it('rend une navigation étiquetée, en liste ordonnée', () => {
    render(<FilAriane items={ITEMS} />);
    const nav = screen.getByRole('navigation', { name: "Fil d'Ariane" });
    porte(nav, 'flex flex-wrap items-center gap-2.5 py-4 text-sm text-[var(--vs-gris)]');
    expect(within(nav).getAllByRole('listitem')).toHaveLength(4);
  });

  it('relie les éléments qui ont un lien, sauf le dernier', () => {
    render(<FilAriane items={ITEMS} />);
    const liens = within(screen.getByTestId('fil-ariane')).getAllByRole('link');
    expect(liens.map((l: HTMLElement) => [l.textContent, l.getAttribute('href')])).toEqual([
      ['Accueil', '/'],
      ['Nike', '/marques/nike'],
    ]);
  });

  it('marque la page courante, seule', () => {
    render(<FilAriane items={ITEMS} />);
    const courant = screen.getByText('Air Zoom Pegasus 41');
    expect(courant).toHaveAttribute('aria-current', 'page');
    porte(courant, 'font-semibold text-[var(--vs-noir)]');
    for (const autre of ['Accueil', 'Vêtements', 'Nike']) {
      expect(screen.getByText(autre)).not.toHaveAttribute('aria-current');
    }
  });

  it('sépare les éléments par des barres cachées aux lecteurs d’écran', () => {
    const { container } = render(<FilAriane items={ITEMS} />);
    const barres = Array.from(container.querySelectorAll('span[aria-hidden="true"]'));
    expect(barres.map((b) => b.textContent)).toEqual(['/', '/', '/']);
  });
});
