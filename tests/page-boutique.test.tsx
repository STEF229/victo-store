import { readFileSync } from 'node:fs';
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import PageBoutique from '../src/app/boutique/page';
import { listerProduits } from '../src/lib/donnees';

describe('page boutique', () => {
  it('affiche toute la sélection avec la vue des listes', () => {
    render(<PageBoutique />);
    const n = listerProduits().length;
    expect(screen.getByRole('banner')).toBeInTheDocument();
    expect(screen.getByTestId('liste-titre').textContent).toBe('Boutique');
    expect(screen.getByTestId('compteur').textContent).toBe(`${n} ${n > 1 ? 'produits' : 'produit'}`);
    expect(screen.getByTestId('filtres-barre')).toBeInTheDocument();
    expect(screen.queryByTestId('filtres')).toBeNull();
    expect(screen.getByRole('contentinfo')).toBeInTheDocument();
  });

  it('n’utilise plus l’ancien panneau de filtres', () => {
    const source = readFileSync('src/app/boutique/page.tsx', 'utf8');
    expect(source).toContain('VueCatalogue');
    expect(source).not.toContain('FiltresPanneau');
    expect(source).not.toMatch(/export (function|const) /);
  });
});
