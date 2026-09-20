import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { SiteFooter, type ColonnePied } from '../src/components/ui/SiteFooter';

const COLONNES: ColonnePied[] = [
  { titre: 'Boutique', liens: [{ label: 'Femme', href: '/femme' }, { label: 'Homme', href: '/homme' }] },
  { titre: 'Aide', liens: [{ label: 'Livraison', href: '/livraison' }] },
];

describe('SiteFooter', () => {
  it('rend un pied de page', () => {
    render(<SiteFooter colonnes={COLONNES} annee={2026} />);
    expect(screen.getByRole('contentinfo')).toBeInTheDocument();
    expect(screen.getByTestId('pied')).toBeInTheDocument();
  });

  it('rend un titre et des liens par colonne', () => {
    render(<SiteFooter colonnes={COLONNES} annee={2026} />);
    expect(screen.getByRole('heading', { name: 'Boutique' })).toBeInTheDocument();
    expect(screen.getByRole('heading', { name: 'Aide' })).toBeInTheDocument();
    expect(screen.getByRole('link', { name: 'Femme' })).toHaveAttribute('href', '/femme');
    expect(screen.getByRole('link', { name: 'Livraison' })).toHaveAttribute('href', '/livraison');
  });

  it('affiche les mentions avec l’année fournie', () => {
    render(<SiteFooter colonnes={COLONNES} annee={2026} />);
    expect(screen.getByTestId('pied-mentions').textContent).toBe('© 2026 VICTO STORE');
  });

  it('utilise l’année courante par défaut', () => {
    render(<SiteFooter colonnes={COLONNES} />);
    expect(screen.getByTestId('pied-mentions').textContent).toBe(
      `© ${new Date().getFullYear()} VICTO STORE`,
    );
  });

  it('affiche le slogan', () => {
    render(<SiteFooter colonnes={COLONNES} annee={2026} />);
    expect(screen.getByTestId('pied-slogan').textContent).toBe('Des grandes marques, au bon prix.');
  });
});
