import { fireEvent, render, screen, within } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import { SelecteurPointure } from '../src/components/produit/SelecteurPointure';
import type { Variante } from '../src/lib/catalogue';

// getAttribute('class') et non className : sur un SVG, className n'est pas une chaîne.
const classes = (el: Element) => (el.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);
function porte(el: Element, chaine: string) {
  for (const k of chaine.split(' ')) expect(classes(el), `pointure ${el.textContent} : classe ${k} manquante`).toContain(k);
}
const V = (taille: string, stock: number): Variante => ({ id: `v${taille}`, taille, sku: `sku-${taille}`, stock });
const VARIANTES = [V('40', 5), V('41', 0), V('42', 2)];
const BASE = 'h-14 rounded-[14px] border-[1.5px] text-base font-bold';
const bouton = (t: string) => screen.getByRole('button', { name: t });

describe('SelecteurPointure — affichage', () => {
  it('annonce la pointure à choisir, puis la pointure choisie', () => {
    const { unmount } = render(<SelecteurPointure variantes={VARIANTES} valeur={null} onChoisir={() => {}} />);
    expect(screen.getByTestId('pointure-choisie').textContent).toBe('— à choisir');
    unmount();
    render(<SelecteurPointure variantes={VARIANTES} valeur="42" onChoisir={() => {}} />);
    expect(screen.getByTestId('pointure-choisie').textContent).toBe('42');
  });

  it('regroupe les pointures sous leur libellé', () => {
    render(<SelecteurPointure variantes={VARIANTES} valeur={null} onChoisir={() => {}} />);
    const groupe = screen.getByRole('group');
    expect(groupe).toHaveAttribute('aria-labelledby', 'libelle-pointure');
    expect(within(groupe).getAllByRole('button').map((b: HTMLElement) => b.textContent)).toEqual(['40', '41', '42']);
  });
});

describe('SelecteurPointure — états', () => {
  it('noircit la pointure choisie', () => {
    render(<SelecteurPointure variantes={VARIANTES} valeur="42" onChoisir={() => {}} />);
    porte(bouton('42'), BASE);
    porte(bouton('42'), 'border-[var(--vs-noir)] bg-[var(--vs-noir)] text-[var(--vs-blanc)]');
    expect(bouton('42')).toHaveAttribute('aria-pressed', 'true');
    porte(bouton('40'), 'border-[var(--vs-ligne)] bg-[var(--vs-blanc)] text-[var(--vs-noir)]');
    expect(bouton('40')).toHaveAttribute('aria-pressed', 'false');
  });

  it('barre et désactive une pointure épuisée', () => {
    render(<SelecteurPointure variantes={VARIANTES} valeur={null} onChoisir={() => {}} />);
    expect(bouton('41')).toBeDisabled();
    porte(bouton('41'), 'cursor-not-allowed text-[#B5B5BA] line-through');
    expect(bouton('40')).not.toBeDisabled();
    expect(classes(bouton('40'))).not.toContain('line-through');
  });
});

describe('SelecteurPointure — choix', () => {
  it('remonte la pointure cliquée, jamais une pointure épuisée', () => {
    const onChoisir = vi.fn();
    render(<SelecteurPointure variantes={VARIANTES} valeur={null} onChoisir={onChoisir} />);
    fireEvent.click(bouton('41'));
    expect(onChoisir).not.toHaveBeenCalled();
    fireEvent.click(bouton('40'));
    expect(onChoisir).toHaveBeenCalledWith('40');
  });
});
