import { fireEvent, render, screen } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import { VALIDER } from '../src/components/catalogue/filtres-affichage';
import { TiroirsFiltres } from '../src/components/catalogue/TiroirsFiltres';

const classes = (el: Element) => (el.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);
function poser(nombreResultats?: number) {
  const onFermer = vi.fn();
  const base = {
    vue: 'filtres' as const, marques: [], tailles: [], criteres: {}, tri: 'nouveautes' as const,
    onMarque: vi.fn(), onTaille: vi.fn(), onPromo: vi.fn(), onStock: vi.fn(), onTri: vi.fn(), onFermer,
  };
  render(nombreResultats === undefined ? <TiroirsFiltres {...base} /> : <TiroirsFiltres {...base} nombreResultats={nombreResultats} />);
  return onFermer;
}

describe('TiroirsFiltres — Voir N produits', () => {
  it('annonce le nombre de résultats, accordé', () => {
    poser(8);
    const bouton = screen.getByRole('button', { name: 'Voir 8 produits' });
    for (const k of VALIDER.split(' ')) expect(classes(bouton), `classe ${k}`).toContain(k);
  });

  it('accorde au singulier jusqu’à un, zéro compris', () => {
    poser(1);
    expect(screen.getByRole('button', { name: 'Voir 1 produit' })).toBeInTheDocument();
  });

  it('dit « Voir 0 produit » quand rien ne correspond', () => {
    poser(0);
    expect(screen.getByRole('button', { name: 'Voir 0 produit' })).toBeInTheDocument();
  });

  it('garde « Appliquer les filtres » sans nombre, et ferme toujours', () => {
    const onFermer = poser();
    fireEvent.click(screen.getByRole('button', { name: 'Appliquer les filtres' }));
    expect(onFermer).toHaveBeenCalledTimes(1);
  });
});
