import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { SiteFooter } from '../src/components/ui/SiteFooter';
import { COLONNES_PIED } from '../src/lib/navigation';

const classes = (el: Element | null) => (el?.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);

describe('pied de page — téléphone', () => {
  it('aère le haut et aligne le pied sur la page', () => {
    render(<SiteFooter colonnes={COLONNES_PIED} />);
    const interieur = screen.getByTestId('pied').querySelector('div');
    for (const k of ['pt-12', 'pb-8', 'max-sm:px-5', 'lg:px-20']) expect(classes(interieur), k).toContain(k);
  });

  it('rogne le filigrane et le masque sur téléphone', () => {
    render(<SiteFooter colonnes={COLONNES_PIED} />);
    const filigrane = screen.getByTestId('pied-filigrane');
    for (const k of ['block', 'max-w-full', 'overflow-hidden', 'whitespace-nowrap', 'text-[200px]', 'max-sm:hidden']) {
      expect(classes(filigrane), k).toContain(k);
    }
  });

  it('ne répète pas la devise sur téléphone', () => {
    render(<SiteFooter colonnes={COLONNES_PIED} />);
    expect(classes(screen.getByTestId('pied-slogan'))).toContain('max-sm:hidden');
  });
});
