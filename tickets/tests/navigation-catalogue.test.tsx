import { fireEvent, render, screen, within } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { CatalogueProvider } from '../src/components/catalogue/CatalogueProvider';
import { NavigationPrincipale } from '../src/components/navigation/NavigationPrincipale';
import { NAV } from '../src/lib/navigation';

const MARQUE = { id: 'pcat_x', nom: 'Marque Medusa', slug: 'marque-medusa' };
const P = (slug: string) => ({ id: slug, slug, nom: slug, marque: MARQUE, imageUrl: '/x.svg', prixCents: 1000, variantes: [], genre: 'homme' as const, categorie: 'chaussures' as const });
const ouvrir = (nom: string) => fireEvent.mouseEnter(within(screen.getByRole('navigation', { name: 'Navigation principale' })).getByRole('link', { name: nom }));

describe('méga-menu — catalogue du site', () => {
  it('montre les marques et les nombres du catalogue fourni', () => {
    render(<CatalogueProvider valeur={{ produits: [P('a'), P('b'), P('c')], marques: [MARQUE], source: 'medusa' }}><NavigationPrincipale navItems={NAV} /></CatalogueProvider>);
    ouvrir('Marques');
    expect(within(screen.getByRole('region', { name: 'Sous-catégories de Marques' })).getByRole('link', { name: 'Marque Medusa' })).toHaveAttribute('href', '/marques/marque-medusa');
    ouvrir('Homme');
    expect(within(screen.getByRole('region', { name: 'Sous-catégories de Homme' })).getByRole('link', { name: /^Tout voir Homme \(3 produits\)/ })).toBeInTheDocument();
  });
});
