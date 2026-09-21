import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { SiteFooter } from '../src/components/ui/SiteFooter';

const classes = (el: Element) => el.className.split(/\s+/).filter(Boolean);
const COLONNES = [{ titre: 'Aide', liens: [{ label: 'Contact', href: '/contact' }] }];

describe('SiteFooter — style de la maquette', () => {
  it('passe sur fond noir', () => {
    render(<SiteFooter colonnes={COLONNES} annee={2026} />);
    const pied = screen.getByTestId('pied');
    for (const k of ['bg-[var(--vs-noir)]', 'text-[var(--vs-blanc)]']) expect(classes(pied)).toContain(k);
  });

  it('affiche le filigrane décoratif', () => {
    render(<SiteFooter colonnes={COLONNES} annee={2026} />);
    const f = screen.getByTestId('pied-filigrane');
    expect(f.textContent).toBe('VICTO');
    expect(f).toHaveAttribute('aria-hidden', 'true');
    for (const k of ['select-none', 'text-[200px]', 'font-black', 'leading-none', 'text-[#1E1E26]']) {
      expect(classes(f)).toContain(k);
    }
  });

  it('garde la marque et les mentions', () => {
    render(<SiteFooter colonnes={COLONNES} annee={2026} />);
    expect(screen.getByTestId('pied').textContent).toContain('VICTO STORE');
    expect(screen.getByTestId('pied-mentions').textContent).toBe('© 2026 VICTO STORE');
  });
});
