import { readFileSync } from 'node:fs';
import { fireEvent, render, screen, within } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import { Pagination } from '../src/components/catalogue/Pagination';

// getAttribute('class') et non className : sur un SVG, className n'est pas une chaîne.
const classes = (el: Element) => (el.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);
const nom = (el: Element) => el.getAttribute('aria-label') ?? el.getAttribute('data-testid') ?? el.tagName;
function porte(el: Element, chaine: string) {
  const reelles = classes(el);
  for (const k of chaine.split(' ')) expect(reelles, `${nom(el)} : classe ${k} manquante`).toContain(k);
}

const ROND = 'flex h-[46px] w-[46px] items-center justify-center rounded-full border-[1.5px]';
const ROND_ACTIF = 'border-[var(--vs-noir)] text-[var(--vs-noir)]';
const ROND_INACTIF = 'cursor-not-allowed border-[var(--vs-ligne)] text-[#B5B5BA]';
const NUMERO = 'flex h-[46px] min-w-[46px] items-center justify-center rounded-full border-[1.5px] px-3 text-[15px] font-semibold';
const NUMERO_ON = 'border-[var(--vs-noir)] bg-[var(--vs-noir)] text-[var(--vs-blanc)]';
const NUMERO_OFF = 'border-[var(--vs-ligne)] bg-[var(--vs-blanc)] text-[var(--vs-noir)]';

const bouton = (n: string) => screen.getByRole('button', { name: n });

describe('Pagination v2 — disposition', () => {
  it('centre la pagination sous la grille, avec sa marge', () => {
    render(<Pagination page={1} pages={3} onChange={() => {}} className="classe-appelant" />);
    const nav = screen.getByTestId('pagination');
    porte(nav, 'mt-12 flex flex-col items-center gap-3.5 classe-appelant');
    porte(screen.getByTestId('pagination-etat'), 'text-sm text-[var(--vs-gris)]');
    expect(within(nav).getAllByRole('button').map((b: HTMLElement) => nom(b))).toEqual([
      'Page précédente', 'Page 1', 'Page 2', 'Page 3', 'Page suivante',
    ]);
  });
});

describe('Pagination v2 — flèches', () => {
  it('grise la flèche désactivée et marque la flèche active', () => {
    render(<Pagination page={1} pages={3} onChange={() => {}} />);
    const prec = bouton('Page précédente');
    const suiv = bouton('Page suivante');
    porte(prec, ROND);
    porte(prec, ROND_INACTIF);
    porte(suiv, ROND);
    porte(suiv, ROND_ACTIF);
    expect(classes(suiv)).not.toContain('text-[#B5B5BA]');
  });

  it('ne contient que des chevrons lucide, cachés aux lecteurs d’écran', () => {
    render(<Pagination page={2} pages={3} onChange={() => {}} />);
    for (const [n, icone] of [['Page précédente', 'lucide-chevron-left'], ['Page suivante', 'lucide-chevron-right']] as const) {
      const b = bouton(n);
      expect(b.textContent).toBe('');
      const svg = b.querySelector(`svg.${icone}`);
      expect(svg, `${n} : icône ${icone}`).not.toBeNull();
      expect(svg?.getAttribute('aria-hidden')).toBe('true');
    }
  });

  it('inverse les états sur la dernière page', () => {
    render(<Pagination page={3} pages={3} onChange={() => {}} />);
    porte(bouton('Page précédente'), ROND_ACTIF);
    porte(bouton('Page suivante'), ROND_INACTIF);
    expect(bouton('Page suivante')).toBeDisabled();
  });
});

describe('Pagination v2 — numéros', () => {
  it('noircit la page courante et la signale', () => {
    render(<Pagination page={2} pages={3} onChange={() => {}} />);
    const courante = bouton('Page 2');
    porte(courante, NUMERO);
    porte(courante, NUMERO_ON);
    expect(courante).toHaveAttribute('aria-current', 'page');
    expect(courante.textContent).toBe('2');
    for (const n of ['Page 1', 'Page 3']) {
      porte(bouton(n), NUMERO);
      porte(bouton(n), NUMERO_OFF);
      expect(bouton(n)).not.toHaveAttribute('aria-current');
    }
  });

  it('va à la page cliquée, sauf la page courante', () => {
    const onChange = vi.fn();
    render(<Pagination page={2} pages={3} onChange={onChange} />);
    fireEvent.click(bouton('Page 2'));
    expect(onChange).not.toHaveBeenCalled();
    fireEvent.click(bouton('Page 3'));
    expect(onChange).toHaveBeenCalledWith(3);
  });

  it('montre sept numéros au plus, et aucun au-delà', () => {
    const { unmount } = render(<Pagination page={1} pages={7} onChange={() => {}} />);
    expect(bouton('Page 7')).toBeInTheDocument();
    unmount();
    render(<Pagination page={1} pages={8} onChange={() => {}} />);
    expect(screen.queryByRole('button', { name: 'Page 1' })).toBeNull();
    expect(screen.getAllByRole('button')).toHaveLength(2);
    expect(screen.getByTestId('pagination-etat').textContent).toBe('Page 1 sur 8');
  });
});

describe('Pagination v2 — source', () => {
  it('ne garde rien de l’ancien style', () => {
    const source = readFileSync('src/components/catalogue/Pagination.tsx', 'utf8');
    for (const k of ['rounded-md', 'hover:', 'focus:', 'var(--vs-surface)', 'var(--vs-accent)']) {
      expect(source, `reste de l'ancien style : ${k}`).not.toContain(k);
    }
  });
});
