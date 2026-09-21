import { act, fireEvent, render, screen, within } from '@testing-library/react';
import { afterEach, describe, expect, it, vi } from 'vitest';
import { Carrousel } from '../src/components/accueil/Carrousel';

const classes = (el: Element) => el.className.split(/\s+/).filter(Boolean);
const active = () =>
  [0, 1, 2].filter((n) => screen.getByTestId(`diapo-${n}`).getAttribute('aria-hidden') === 'false');

afterEach(() => {
  vi.useRealTimers();
});

describe('Carrousel — structure', () => {
  it('rend une région étiquetée', () => {
    render(<Carrousel auto={false} />);
    const c = screen.getByTestId('carrousel');
    expect(c.tagName).toBe('SECTION');
    expect(c).toHaveAttribute('aria-label', 'À la une');
    expect(c).toHaveAttribute('aria-roledescription', 'carrousel');
    for (const k of ['relative', 'overflow-hidden']) expect(classes(c)).toContain(k);
  });

  it('rend trois diapositives dans une piste animée', () => {
    render(<Carrousel auto={false} />);
    const piste = screen.getByTestId('carrousel-piste');
    for (const k of ['flex', 'transition-transform', 'duration-700', 'ease-in-out']) {
      expect(classes(piste)).toContain(k);
    }
    for (const n of [0, 1, 2]) {
      const d = screen.getByTestId(`diapo-${n}`);
      expect(piste.contains(d)).toBe(true);
      expect(classes(d)).toContain('w-full');
      expect(classes(d)).toContain('shrink-0');
    }
  });

  it('ne rend qu’un seul titre de niveau 1, sur la première diapositive', () => {
    render(<Carrousel auto={false} />);
    const h1 = screen.getAllByRole('heading', { level: 1, hidden: true });
    expect(h1).toHaveLength(1);
    expect(h1[0]?.textContent).toBe('Des grandes marques, au bon prix.');
    expect(screen.getByTestId('diapo-0').contains(h1[0] as Element)).toBe(true);
  });

  it('impose la taille des titres', () => {
    render(<Carrousel auto={false} />);
    const titres = [
      ...screen.getAllByRole('heading', { level: 1, hidden: true }),
      ...screen.getAllByRole('heading', { level: 2, hidden: true }),
    ];
    expect(titres).toHaveLength(3);
    for (const t of titres) {
      for (const k of ['text-5xl', 'font-black', 'tracking-tight', 'lg:text-7xl']) expect(classes(t)).toContain(k);
    }
  });

  it('affiche les trois visuels décoratifs', () => {
    const { container } = render(<Carrousel auto={false} />);
    const imgs = Array.from(container.querySelectorAll('img'));
    expect(imgs.map((i) => i.getAttribute('src'))).toEqual([
      '/img/accueil/photo-1.svg',
      '/img/accueil/photo-2.svg',
      '/img/accueil/photo-3.svg',
    ]);
    for (const i of imgs) {
      expect(i.getAttribute('alt')).toBe('');
      for (const k of ['h-[520px]', 'w-full', 'rounded-[28px]', 'object-cover']) expect(classes(i)).toContain(k);
    }
  });
});

describe('Carrousel — actions des diapositives', () => {
  it.each([
    [0, 'Découvrir la boutique', '/boutique'],
    [0, 'Voir les soldes', '/soldes'],
    [1, 'Profiter des soldes', '/soldes'],
    [2, 'Voir les nouveautés', '/nouveautes'],
  ])('la diapositive %i propose « %s »', (n, nom, href) => {
    render(<Carrousel auto={false} />);
    const lien = within(screen.getByTestId(`diapo-${n}`)).getByRole('link', { name: nom, hidden: true });
    expect(lien).toHaveAttribute('href', href);
  });
});

describe('Carrousel — navigation', () => {
  it('démarre sur la première diapositive', () => {
    render(<Carrousel auto={false} />);
    expect(active()).toEqual([0]);
  });

  it('avance et recule en boucle', () => {
    render(<Carrousel auto={false} />);
    fireEvent.click(screen.getByRole('button', { name: 'Diapositive suivante' }));
    expect(active()).toEqual([1]);
    expect(screen.getByTestId('carrousel-piste').style.transform).toContain('-100%');
    fireEvent.click(screen.getByRole('button', { name: 'Diapositive précédente' }));
    fireEvent.click(screen.getByRole('button', { name: 'Diapositive précédente' }));
    expect(active()).toEqual([2]);
    fireEvent.click(screen.getByRole('button', { name: 'Diapositive suivante' }));
    expect(active()).toEqual([0]);
  });

  it('va directement à une diapositive par ses points', () => {
    render(<Carrousel auto={false} />);
    const point3 = screen.getByRole('button', { name: 'Aller à la diapositive 3' });
    expect(point3).not.toHaveAttribute('aria-current');
    fireEvent.click(point3);
    expect(active()).toEqual([2]);
    expect(point3).toHaveAttribute('aria-current', 'true');
    expect(screen.getByRole('button', { name: 'Aller à la diapositive 1' })).not.toHaveAttribute('aria-current');
  });
});

describe('Carrousel — défilement automatique', () => {
  it('passe seul à la diapositive suivante', () => {
    vi.useFakeTimers();
    render(<Carrousel />);
    expect(active()).toEqual([0]);
    act(() => {
      vi.advanceTimersByTime(5000);
    });
    expect(active()).toEqual([1]);
    act(() => {
      vi.advanceTimersByTime(10000);
    });
    expect(active()).toEqual([0]);
  });

  it('respecte l’intervalle fourni', () => {
    vi.useFakeTimers();
    render(<Carrousel intervalleMs={1000} />);
    act(() => {
      vi.advanceTimersByTime(1000);
    });
    expect(active()).toEqual([1]);
  });

  it('ne bouge pas quand auto vaut false', () => {
    vi.useFakeTimers();
    render(<Carrousel auto={false} />);
    act(() => {
      vi.advanceTimersByTime(20000);
    });
    expect(active()).toEqual([0]);
  });
});
