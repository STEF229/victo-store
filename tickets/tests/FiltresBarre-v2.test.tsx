import { readFileSync } from 'node:fs';
import { fireEvent, render, screen, within } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import { FiltresBarre } from '../src/components/catalogue/FiltresBarre';
import type { Marque } from '../src/lib/catalogue';
import type { Criteres } from '../src/lib/filtres';

// Contrat visuel du ticket 095 : mêmes chaînes que dans la spec.
const PILULE = 'flex h-[46px] items-center gap-2 rounded-full border-[1.5px] px-[18px] text-[15px] font-semibold';
const PILULE_OFF = 'border-[var(--vs-ligne)] bg-[var(--vs-blanc)] text-[var(--vs-noir)]';
const PILULE_ON = 'border-[var(--vs-noir)] bg-[var(--vs-noir)] text-[var(--vs-blanc)]';
const PANNEAU = 'absolute left-0 top-[54px] z-20 rounded-[20px] border border-[var(--vs-ligne)] bg-[var(--vs-blanc)] p-3.5 shadow-[0_18px_40px_rgba(16,16,20,0.12)]';
const PANNEAU_MARQUES = 'flex w-[300px] flex-wrap gap-2';
const PANNEAU_TAILLES = 'grid w-[320px] grid-cols-5 gap-2';
const OPTION_MARQUE = 'h-[38px] rounded-full border-[1.5px] px-3.5 text-sm font-semibold';
const OPTION_TAILLE = 'h-11 rounded-xl border-[1.5px] text-sm font-bold';
const TRI_LIBELLE = 'text-[15px] text-[var(--vs-gris)]';
const TRI_SELECT = 'h-[46px] rounded-full border-[1.5px] border-[var(--vs-ligne)] bg-[var(--vs-blanc)] px-4 text-[15px] font-semibold text-[var(--vs-noir)]';
const PASTILLES = 'mt-4 flex flex-wrap items-center gap-2';
const PASTILLE = 'flex h-[34px] items-center gap-1.5 rounded-full bg-[#F0F0EE] pl-3.5 pr-2 text-sm font-semibold text-[var(--vs-noir)]';
const TOUT_EFFACER = 'h-[34px] px-3 text-sm font-semibold text-[var(--vs-gris)] underline';
const MOBILE_FILTRER = 'flex h-[46px] flex-1 items-center justify-center gap-2 rounded-full border-[1.5px] border-[var(--vs-noir)] bg-[var(--vs-blanc)] text-[15px] font-bold text-[var(--vs-noir)]';
const MOBILE_TRIER = 'h-[46px] flex-1 rounded-full border-[1.5px] border-[var(--vs-ligne)] bg-[var(--vs-blanc)] text-[15px] font-semibold text-[var(--vs-noir)]';
const TIROIR_FOND = 'fixed inset-0 z-40 bg-[rgba(16,16,20,0.45)] lg:hidden';
const TIROIR = 'fixed inset-x-0 bottom-0 z-50 max-h-[85vh] overflow-y-auto rounded-t-[28px] bg-[var(--vs-blanc)] px-5 pb-7 pt-6 lg:hidden';
const FERMER = 'flex h-11 w-11 items-center justify-center rounded-full bg-[#F0F0EE] text-[var(--vs-noir)]';
const VALIDER = 'h-[54px] w-full rounded-full bg-[var(--vs-accent)] text-base font-extrabold text-[var(--vs-blanc)]';
const OPTION_TRI = 'h-[52px] w-full rounded-[14px] border-[1.5px] px-[18px] text-left text-base font-semibold';

const classes = (el: Element) => el.className.split(/\s+/).filter(Boolean);
function porte(el: Element, ...attendues: string[]) {
  const reelles = classes(el);
  for (const chaine of attendues) {
    for (const k of chaine.split(' ')) expect(reelles, `classe ${k}`).toContain(k);
  }
}
function neportePas(el: Element, chaine: string) {
  const reelles = classes(el);
  for (const k of chaine.split(' ')) expect(reelles, `classe ${k}`).not.toContain(k);
}

const MARQUES: Marque[] = [
  { id: 'm1', nom: 'Nike', slug: 'nike' },
  { id: 'm2', nom: 'Lacoste', slug: 'lacoste' },
];
const TAILLES = ['40', '41', 'M'];

function poser(criteres: Criteres = {}) {
  render(
    <FiltresBarre
      marques={MARQUES}
      tailles={TAILLES}
      criteres={criteres}
      onChange={vi.fn()}
      tri="nouveautes"
      onTriChange={vi.fn()}
    />,
  );
}

describe('FiltresBarre v2 — pilules de la barre', () => {
  it('rend les quatre pilules inactives sans filtre', () => {
    poser();
    for (const id of ['bouton-marques', 'bouton-tailles', 'filtre-promo', 'filtre-stock']) {
      const el = screen.getByTestId(id);
      porte(el, PILULE, PILULE_OFF);
      neportePas(el, 'bg-[var(--vs-noir)]');
    }
  });

  it('noircit Promotions et En stock quand ils sont actifs', () => {
    poser({ promotionSeulement: true, enStockSeulement: true });
    for (const id of ['filtre-promo', 'filtre-stock']) {
      const el = screen.getByTestId(id);
      porte(el, PILULE, PILULE_ON);
      expect(el).toHaveAttribute('aria-pressed', 'true');
    }
  });

  it('noircit Marque et Taille dès qu\'une valeur est choisie', () => {
    poser({ marques: ['nike'], tailles: ['41'] });
    porte(screen.getByTestId('bouton-marques'), PILULE, PILULE_ON);
    porte(screen.getByTestId('bouton-tailles'), PILULE, PILULE_ON);
  });

  it('noircit Marque tant que son panneau est ouvert', () => {
    poser();
    fireEvent.click(screen.getByTestId('bouton-marques'));
    porte(screen.getByTestId('bouton-marques'), PILULE_ON);
    porte(screen.getByTestId('bouton-tailles'), PILULE_OFF);
  });
});

describe('FiltresBarre v2 — panneaux', () => {
  it('habille le panneau des marques et ses options', () => {
    poser({ marques: ['nike'] });
    fireEvent.click(screen.getByTestId('bouton-marques'));
    porte(screen.getByTestId('panneau-marques'), PANNEAU, PANNEAU_MARQUES);
    porte(screen.getByTestId('filtre-marque-nike'), OPTION_MARQUE, PILULE_ON);
    porte(screen.getByTestId('filtre-marque-lacoste'), OPTION_MARQUE, PILULE_OFF);
  });

  it('habille le panneau des tailles et marque la taille choisie', () => {
    poser({ tailles: ['41'] });
    fireEvent.click(screen.getByTestId('bouton-tailles'));
    porte(screen.getByTestId('panneau-tailles'), PANNEAU, PANNEAU_TAILLES);
    const choisie = screen.getByTestId('filtre-taille-41');
    porte(choisie, OPTION_TAILLE, PILULE_ON);
    expect(choisie).toHaveAttribute('aria-pressed', 'true');
    const libre = screen.getByTestId('filtre-taille-40');
    porte(libre, OPTION_TAILLE, PILULE_OFF);
    expect(libre).toHaveAttribute('aria-pressed', 'false');
  });
});

describe('FiltresBarre v2 — tri', () => {
  it('rend le libellé en gris et le sélecteur en pilule', () => {
    poser();
    porte(screen.getByText('Trier par', { selector: 'label' }), TRI_LIBELLE);
    porte(screen.getByTestId('tri'), TRI_SELECT);
  });
});

describe('FiltresBarre v2 — pastilles', () => {
  it('rend des pastilles visibles, avec une croix grise', () => {
    poser({ marques: ['nike'], tailles: ['41'], promotionSeulement: true, enStockSeulement: true });
    const zone = screen.getByTestId('pastilles');
    porte(zone, PASTILLES);
    for (const nom of ['Nike', 'Taille 41', 'Promotions', 'En stock']) {
      const p = within(zone).getByRole('button', { name: `Retirer le filtre ${nom}` });
      porte(p, PASTILLE);
      const croix = p.querySelector('svg.lucide-x');
      expect(croix).not.toBeNull();
      expect(croix?.getAttribute('aria-hidden')).toBe('true');
      expect(classes(croix as Element)).toContain('text-[var(--vs-gris)]');
    }
    porte(screen.getByTestId('filtres-reinitialiser'), TOUT_EFFACER);
  });
});

describe('FiltresBarre v2 — téléphone', () => {
  it('rend les deux boutons en pilules', () => {
    poser();
    porte(screen.getByTestId('ouvrir-filtres'), MOBILE_FILTRER);
    porte(screen.getByTestId('ouvrir-tri'), MOBILE_TRIER);
  });

  it('ouvre le tiroir de filtres par le bas, sur un fond qui ferme', () => {
    poser({ marques: ['nike'], promotionSeulement: true });
    expect(screen.queryByTestId('tiroir-fond')).toBeNull();
    fireEvent.click(screen.getByTestId('ouvrir-filtres'));
    const tiroir = screen.getByTestId('tiroir-filtres');
    porte(tiroir, TIROIR);
    porte(screen.getByTestId('tiroir-fond'), TIROIR_FOND);
    porte(within(tiroir).getByRole('button', { name: 'Fermer' }), FERMER);
    porte(within(tiroir).getByRole('button', { name: 'Appliquer les filtres' }), VALIDER);
    porte(within(tiroir).getByTestId('filtre-marque-nike'), OPTION_MARQUE, PILULE_ON);
    porte(within(tiroir).getByTestId('filtre-promo'), PILULE, 'flex-1 justify-center', PILULE_ON);
    porte(within(tiroir).getByTestId('filtre-stock'), PILULE, 'flex-1 justify-center', PILULE_OFF);
    fireEvent.click(screen.getByTestId('tiroir-fond'));
    expect(screen.queryByTestId('tiroir-filtres')).toBeNull();
    expect(screen.queryByTestId('tiroir-fond')).toBeNull();
  });

  it('marque le tri courant dans le tiroir de tri', () => {
    poser();
    fireEvent.click(screen.getByTestId('ouvrir-tri'));
    const tiroir = screen.getByTestId('tiroir-tri');
    porte(tiroir, TIROIR);
    const courant = within(tiroir).getByRole('button', { name: 'Nouveautés' });
    porte(courant, OPTION_TRI, PILULE_ON);
    expect(courant).toHaveAttribute('aria-pressed', 'true');
    porte(within(tiroir).getByRole('button', { name: 'Prix croissant' }), OPTION_TRI, PILULE_OFF);
  });
});

describe('FiltresBarre v2 — jetons', () => {
  const source = readFileSync('src/components/catalogue/FiltresBarre.tsx', 'utf8');
  const definis = new Set(
    Array.from(readFileSync('src/styles/tokens.css', 'utf8').matchAll(/(--vs-[a-z0-9-]+)\s*:/g), (m) => m[1] ?? ''),
  );

  it("n'utilise que des jetons définis dans tokens.css", () => {
    const inconnus = Array.from(source.matchAll(/var\((--vs-[a-z0-9-]+)\)/g), (m) => m[1] ?? '')
      .filter((j) => !definis.has(j));
    expect([...new Set(inconnus)]).toEqual([]);
  });

  it('ne garde ni ombre ni coin carré de la version précédente', () => {
    for (const k of ['rounded-md', 'shadow-sm', 'shadow-lg', 'ring-1']) expect(source).not.toContain(k);
  });
});
