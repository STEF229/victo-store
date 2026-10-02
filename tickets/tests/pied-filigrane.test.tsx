import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { SiteFooter } from '../src/components/ui/SiteFooter';
import { COLONNES_PIED } from '../src/lib/navigation';

const classes = (el: Element) => (el.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);

describe('pied de page — filigrane', () => {
  it('rogne le filigrane à la largeur de l’écran, sans changer son style', () => {
    render(<SiteFooter colonnes={COLONNES_PIED} />);
    const filigrane = screen.getByText('VICTO');
    for (const k of ['block', 'max-w-full', 'overflow-hidden', 'whitespace-nowrap', 'text-[200px]', 'text-[#1E1E26]']) {
      expect(classes(filigrane), k).toContain(k);
    }
  });
});
