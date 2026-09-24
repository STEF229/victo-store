import { readFileSync } from 'node:fs';
import { fireEvent, render, screen, within } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import { FiltresBarre } from '../src/components/catalogue/FiltresBarre';
import {
  MOBILE_FILTRER, MOBILE_TRIER, OPTION_MARQUE, OPTION_TAILLE, PANNEAU, PANNEAU_MARQUES, PANNEAU_TAILLES,
  PASTILLE, PASTILLE_CROIX, PASTILLES, PILULE, PILULE_OFF, PILULE_ON, TOUT_EFFACER, TRI_LIBELLE, TRI_SELECT,
} from '../src/components/catalogue/filtres-affichage';
// Dépendance déclarée pour le harnais : sans les tiroirs, ce ticket est BLOQUÉ.
import { TiroirsFiltres as _dependance } from '../src/components/catalogue/TiroirsFiltres';
import type { Marque } from '../src/lib/catalogue';
import type { Criteres } from '../src/lib/filtres';

// getAttribute('class') et non className : sur un SVG, className n'est pas une chaîne.
const classes = (el: Element) => (el.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);
const nom = (el: Element) =>
  el.getAttribute('data-testid') ?? el.getAttribute('aria-label') ?? el.textContent ?? el.tagName;
function porte(el: Element, ...attendues: string[]) {
  const reelles = classes(el);
  for (const chaine of attendues) {
    for (const k of chaine.split(' ')) expect(reelles, `${nom(el)} : classe ${k} manquante`).toContain(k);
  }
}
const MARQUES: Marque[] = [
  { id: 'm1', nom: 'Nike', slug: 'nike' },
  { id: 'm2', nom: 'Lacoste', slug: 'lacoste' },
];

function poser(criteres: Criteres = {}) {
  const onChange = vi.fn();
  const onTriChange = vi.fn();
  render(
    <FiltresBarre marques={MARQUES} tailles={['40', '41']} criteres={criteres}
      onChange={onChange} tri="nouveautes" onTriChange={onTriChange} />,
  );
  return { onChange, onTriChange };
}

describe('FiltresBarre v3 — pilules', () => {
  it('rend les quatre pilules inactives sans filtre', () => {
    poser();
    for (const id of ['bouton-marques', 'bouton-tailles', 'filtre-promo', 'filtre-stock']) {
      porte(screen.getByTestId(id), PILULE, PILULE_OFF);
    }
  });

  it('noircit chaque pilule active', () => {
    poser({ marques: ['nike'], tailles: ['41'], promotionSeulement: true, enStockSeulement: true });
    for (const id of ['bouton-marques', 'bouton-tailles', 'filtre-promo', 'filtre-stock']) {
      porte(screen.getByTestId(id), PILULE, PILULE_ON);
    }
    expect(screen.getByTestId('filtre-promo')).toHaveAttribute('aria-pressed', 'true');
  });

  it('noircit Marque tant que son panneau est ouvert', () => {
    poser();
    fireEvent.click(screen.getByTestId('bouton-marques'));
    porte(screen.getByTestId('bouton-marques'), PILULE_ON);
    porte(screen.getByTestId('bouton-tailles'), PILULE_OFF);
  });
});

describe('FiltresBarre v3 — panneaux et tri', () => {
  it('habille le panneau des marques', () => {
    poser({ marques: ['nike'] });
    fireEvent.click(screen.getByTestId('bouton-marques'));
    porte(screen.getByTestId('panneau-marques'), PANNEAU, PANNEAU_MARQUES);
    porte(screen.getByTestId('filtre-marque-nike'), OPTION_MARQUE, PILULE_ON);
    porte(screen.getByTestId('filtre-marque-lacoste'), OPTION_MARQUE, PILULE_OFF);
  });

  it('habille le panneau des tailles et le tri', () => {
    poser({ tailles: ['41'] });
    porte(screen.getByText('Trier par', { selector: 'label' }), TRI_LIBELLE);
    porte(screen.getByTestId('tri'), TRI_SELECT);
    fireEvent.click(screen.getByTestId('bouton-tailles'));
    porte(screen.getByTestId('panneau-tailles'), PANNEAU, PANNEAU_TAILLES);
    porte(screen.getByTestId('filtre-taille-41'), OPTION_TAILLE, PILULE_ON);
    expect(screen.getByTestId('filtre-taille-41')).toHaveAttribute('aria-pressed', 'true');
    expect(screen.getByTestId('filtre-taille-40')).toHaveAttribute('aria-pressed', 'false');
  });
});

describe('FiltresBarre v3 — pastilles', () => {
  it('rend des pastilles visibles avec une croix grise', () => {
    poser({ marques: ['nike'], tailles: ['41'], promotionSeulement: true, enStockSeulement: true });
    const zone = screen.getByTestId('pastilles');
    porte(zone, PASTILLES);
    const noms = within(zone).getAllByRole('button').map((b: HTMLElement) => b.getAttribute('aria-label') ?? b.textContent);
    expect(noms).toEqual([
      'Retirer le filtre Nike', 'Retirer le filtre Taille 41', 'Retirer le filtre Promotions',
      'Retirer le filtre En stock', 'Tout effacer',
    ]);
    for (const nom of ['Nike', 'Taille 41', 'Promotions', 'En stock']) {
      const p = within(zone).getByRole('button', { name: `Retirer le filtre ${nom}` });
      porte(p, PASTILLE);
      const croix = p.querySelector('svg.lucide-x');
      expect(croix).not.toBeNull();
      porte(croix as Element, PASTILLE_CROIX);
    }
    porte(screen.getByTestId('filtres-reinitialiser'), TOUT_EFFACER);
  });

  it('remet un interrupteur à false depuis sa pastille', () => {
    const { onChange } = poser({ promotionSeulement: true, marques: ['nike'] });
    fireEvent.click(screen.getByRole('button', { name: 'Retirer le filtre Promotions' }));
    expect(onChange).toHaveBeenCalledWith({ promotionSeulement: false, marques: ['nike'] });
  });
});

describe('FiltresBarre v3 — téléphone', () => {
  it('délègue les tiroirs à TiroirsFiltres et relaie ses actions', () => {
    const { onChange, onTriChange } = poser({ marques: ['lacoste'] });
    porte(screen.getByTestId('ouvrir-filtres'), MOBILE_FILTRER);
    porte(screen.getByTestId('ouvrir-tri'), MOBILE_TRIER);
    fireEvent.click(screen.getByTestId('ouvrir-filtres'));
    const tiroir = screen.getByTestId('tiroir-filtres');
    fireEvent.click(within(tiroir).getByTestId('filtre-marque-nike'));
    expect(onChange).toHaveBeenCalledWith({ marques: ['lacoste', 'nike'] });
    fireEvent.click(within(tiroir).getByTestId('filtre-stock'));
    expect(onChange).toHaveBeenLastCalledWith({ marques: ['lacoste'], enStockSeulement: true });
    fireEvent.click(screen.getByTestId('tiroir-fond'));
    expect(screen.queryByTestId('tiroir-filtres')).toBeNull();
    fireEvent.click(screen.getByTestId('ouvrir-tri'));
    fireEvent.click(within(screen.getByTestId('tiroir-tri')).getByRole('button', { name: 'Prix croissant' }));
    expect(onTriChange).toHaveBeenCalledWith('prix-croissant');
    expect(screen.queryByTestId('tiroir-tri')).toBeNull();
  });
});

describe('FiltresBarre v3 — source', () => {
  const source = readFileSync('src/components/catalogue/FiltresBarre.tsx', 'utf8');

  it('ne code aucune couleur à la main', () => {
    expect(source).not.toContain('var(--vs-');
    for (const k of ['rounded-md', 'shadow-sm', 'shadow-lg', 'ring-1']) expect(source).not.toContain(k);
  });

  it('ne réimplémente pas les tiroirs', () => {
    expect(source).toContain('<TiroirsFiltres');
    expect(source).not.toContain('tiroir-filtres');
    expect(source).not.toContain('tiroir-tri');
  });
});
