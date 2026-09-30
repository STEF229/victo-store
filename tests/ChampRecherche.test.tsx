import { fireEvent, render, screen, within } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { ChampRecherche } from '../src/components/recherche/ChampRecherche';
import { listerMarques, listerProduits } from '../src/lib/donnees';
import { rechercherProduits } from '../src/lib/recherche';

const champ = () => screen.getByLabelText('Rechercher un produit');
const taper = (t: string) => fireEvent.change(champ(), { target: { value: t } });
const suggestions = () => screen.queryByTestId('suggestions-recherche');
// une marque du vrai catalogue qui a des produits, et son nom tapé en minuscules
const marque = listerMarques().find((m) => rechercherProduits(listerProduits(), m.nom).length > 0);
const terme = (marque?.nom ?? '').toLowerCase();

describe('ChampRecherche', () => {
  it('garde l’étiquette, l’identifiant, le type et le texte indicatif de l’en-tête', () => {
    render(<ChampRecherche />);
    expect(champ()).toHaveAttribute('id', 'recherche-entete');
    expect(champ()).toHaveAttribute('type', 'search');
    expect(champ()).toHaveAttribute('placeholder', 'Rechercher');
    expect(champ()).toHaveAttribute('name', 'q');
    const formulaire = screen.getByRole('search');
    expect(formulaire).toHaveAttribute('action', '/recherche');
    expect(formulaire).toHaveAttribute('method', 'get');
    expect(screen.queryByRole('button')).toBeNull();
  });

  it('ne propose rien avant deux caractères', () => {
    render(<ChampRecherche />);
    taper(terme.slice(0, 1));
    expect(suggestions()).toBeNull();
  });

  it('propose la marque, quatre produits au plus et le lien vers tous les résultats', () => {
    expect(marque, 'au moins une marque du catalogue a des produits').toBeDefined();
    render(<ChampRecherche />);
    taper(terme);
    const liste = suggestions();
    expect(liste).not.toBeNull();
    const zone = within(liste as HTMLElement);
    expect(zone.getByRole('link', { name: marque?.nom ?? '' })).toBeInTheDocument();
    const n = rechercherProduits(listerProduits(), terme).length;
    expect(zone.getAllByRole('listitem')).toHaveLength(Math.min(n, 4));
    const nomLien = n > 1 ? `Voir les ${n} résultats pour « ${terme} »` : `Voir le résultat pour « ${terme} »`;
    const tout = zone.getByRole('link', { name: nomLien });
    expect(tout).toHaveAttribute('href', `/recherche?q=${encodeURIComponent(terme)}`);
  });

  it('se ferme avec Échap', () => {
    render(<ChampRecherche />);
    taper(terme);
    fireEvent.keyDown(champ(), { key: 'Escape' });
    expect(suggestions()).toBeNull();
  });

  it('ne propose rien quand rien ne correspond', () => {
    render(<ChampRecherche />);
    taper('zzqqxx');
    expect(suggestions()).toBeNull();
  });
});
