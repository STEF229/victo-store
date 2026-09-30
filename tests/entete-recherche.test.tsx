import { readFileSync } from 'node:fs';
import { fireEvent, render, screen, within } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { SiteHeader } from '../src/components/ui/SiteHeader';
import { listerMarques, listerProduits } from '../src/lib/donnees';
import { NAV } from '../src/lib/navigation';
import { rechercherProduits } from '../src/lib/recherche';

describe('en-tête — recherche', () => {
  it('cherche vraiment : un formulaire vers /recherche, un seul champ', () => {
    render(<SiteHeader navItems={NAV} />);
    const formulaire = screen.getByRole('search');
    expect(formulaire).toHaveAttribute('action', '/recherche');
    expect(within(formulaire).getByLabelText('Rechercher un produit')).toHaveAttribute('name', 'q');
    expect(screen.getAllByLabelText('Rechercher un produit')).toHaveLength(1);
  });

  it('propose des suggestions pendant la saisie', () => {
    const marque = listerMarques().find((m) => rechercherProduits(listerProduits(), m.nom).length > 0);
    render(<SiteHeader navItems={NAV} />);
    fireEvent.change(screen.getByLabelText('Rechercher un produit'), { target: { value: (marque?.nom ?? '').toLowerCase() } });
    expect(screen.getByTestId('suggestions-recherche')).toBeInTheDocument();
  });

  it('délègue le champ au composant de recherche', () => {
    const source = readFileSync('src/components/ui/SiteHeader.tsx', 'utf8');
    expect(source).toContain("import { ChampRecherche } from '@/components/recherche/ChampRecherche';");
    expect(source).not.toContain('id="recherche-entete"');
  });
});
