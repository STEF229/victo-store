import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { SiteFooter } from '../src/components/ui/SiteFooter';
import { COLONNES_PIED } from '../src/lib/navigation';

describe('pied de page — colonnes sur téléphone', () => {
  it('place Boutique et Aide côte à côte sous 768 px', () => {
    render(<SiteFooter colonnes={COLONNES_PIED} />);
    const grille = screen.getByText('Boutique').closest('.grid');
    expect(grille?.contains(screen.getByText('Aide'))).toBe(true);
    const classes = (grille?.getAttribute('class') ?? '').split(/\s+/);
    for (const k of ['grid-cols-1', 'md:grid-cols-2', 'max-md:grid-cols-2', 'max-md:gap-6']) expect(classes, k).toContain(k);
  });
});
