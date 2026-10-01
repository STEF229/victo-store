import { readFileSync } from 'node:fs';
import { fireEvent, render, screen, within } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { ARBRE } from '../src/lib/arbre-categories';
import { SiteHeader } from '../src/components/ui/SiteHeader';
import { NAV } from '../src/lib/navigation';

describe('en-tête — navigation et menu mobile', () => {
  it('ouvre le méga-menu au survol d’une rubrique', () => {
    render(<SiteHeader navItems={NAV} />);
    const nav = screen.getByRole('navigation', { name: 'Navigation principale' });
    fireEvent.mouseEnter(within(nav).getByRole('link', { name: 'Homme' }));
    expect(screen.getByRole('region', { name: `Sous-catégories de ${ARBRE.homme.libelle}` })).toBeInTheDocument();
  });

  it('ouvre le menu mobile', () => {
    render(<SiteHeader navItems={NAV} />);
    fireEvent.click(screen.getByRole('button', { name: 'Ouvrir le menu' }));
    expect(screen.getByRole('dialog', { name: 'Menu' })).toBeInTheDocument();
  });

  it('délègue la navigation et le menu à leurs composants', () => {
    const source = readFileSync('src/components/ui/SiteHeader.tsx', 'utf8');
    expect(source).toContain("import { NavigationPrincipale } from '@/components/navigation/NavigationPrincipale';");
    expect(source).toContain("import { MenuMobile } from '@/components/navigation/MenuMobile';");
    expect(source).not.toContain('function classeLien');
  });
});
