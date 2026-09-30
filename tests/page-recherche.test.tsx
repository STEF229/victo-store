import { render, screen, within } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import PageRecherche from '../src/app/recherche/page';
import { listerMarques, listerProduits } from '../src/lib/donnees';
import { rechercherProduits } from '../src/lib/recherche';

const poser = async (q?: string | string[]) =>
  render(await PageRecherche({ searchParams: Promise.resolve(q === undefined ? {} : { q }) }));
const marque = () => listerMarques().find((m) => rechercherProduits(listerProduits(), m.nom).length > 0);

describe('page de recherche — résultats', () => {
  it('affiche les produits trouvés dans la vue des listes', async () => {
    const m = marque();
    expect(m, 'au moins une marque du catalogue a des produits').toBeDefined();
    const nom = m?.nom ?? '';
    const n = rechercherProduits(listerProduits(), nom).length;
    await poser(nom);
    expect(screen.getByTestId('liste-titre').textContent).toBe(`Résultats pour « ${nom} »`);
    expect(screen.getByTestId('compteur').textContent).toBe(`${n} ${n > 1 ? 'produits' : 'produit'}`);
    expect(screen.getByTestId('filtres-barre')).toBeInTheDocument();
    expect(screen.queryByTestId('recherche-vide')).toBeNull();
  });

  it('accepte un terme répété dans l’adresse', async () => {
    const nom = marque()?.nom ?? '';
    await poser([nom]);
    expect(screen.getByTestId('liste-titre').textContent).toBe(`Résultats pour « ${nom} »`);
  });
});

describe('page de recherche — rien trouvé', () => {
  it('le dit, propose les marques et des produits', async () => {
    await poser('zzqqxx introuvable');
    expect(screen.getByRole('heading', { level: 1 }).textContent).toBe('Aucun résultat pour « zzqqxx introuvable »');
    const vide = screen.getByTestId('recherche-vide');
    const liens = within(vide).getAllByRole('link');
    expect(liens.map((l: HTMLElement) => l.textContent)).toEqual(listerMarques().map((mq) => mq.nom));
    expect(liens.map((l: HTMLElement) => l.getAttribute('href'))).toEqual(listerMarques().map((mq) => `/recherche?q=${encodeURIComponent(mq.nom)}`));
    expect(screen.getByRole('heading', { level: 2, name: 'Ça pourrait vous plaire' })).toBeInTheDocument();
  });

  it('invite à chercher quand rien n’est saisi', async () => {
    await poser();
    expect(screen.getByRole('heading', { level: 1 }).textContent).toBe('Que cherchez-vous ?');
  });
});
