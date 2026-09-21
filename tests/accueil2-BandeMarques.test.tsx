import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { BandeMarques } from '../src/components/accueil/BandeMarques';
import type { Marque } from '../src/lib/catalogue';

const classes = (el: Element) => el.className.split(/\s+/).filter(Boolean);
const MARQUES: Marque[] = [
  { id: 'm1', nom: 'Nike', slug: 'nike' },
  { id: 'm2', nom: 'New Balance', slug: 'new-balance' },
  { id: 'm3', nom: "Levi's", slug: 'levis' },
];

describe('BandeMarques', () => {
  it('rend une région étiquetée', () => {
    render(<BandeMarques marques={MARQUES} />);
    const s = screen.getByTestId('bande-marques');
    expect(s).toHaveAttribute('aria-label', 'Nos marques');
    for (const k of ['overflow-hidden', 'border-b', 'border-[var(--vs-ligne)]']) expect(classes(s)).toContain(k);
  });

  it('anime la piste en boucle, sauf mouvement réduit', () => {
    render(<BandeMarques marques={MARQUES} />);
    const p = screen.getByTestId('bande-piste');
    for (const k of ['flex', 'w-max', 'items-center', 'animate-[vs-defile_38s_linear_infinite]', 'motion-reduce:animate-none']) {
      expect(classes(p)).toContain(k);
    }
  });

  it('déclare l’animation', () => {
    const { container } = render(<BandeMarques marques={MARQUES} />);
    const style = container.querySelector('style');
    expect(style?.textContent).toContain('@keyframes vs-defile');
    expect(style?.textContent).toContain('translateX(-50%)');
  });

  it('expose chaque marque une seule fois aux lecteurs d’écran', () => {
    render(<BandeMarques marques={MARQUES} />);
    const liens = screen.getAllByRole('link');
    expect(liens).toHaveLength(3);
    expect(screen.getByRole('link', { name: 'Nike' })).toHaveAttribute('href', '/marques/nike');
    expect(screen.getByRole('link', { name: 'New Balance' })).toHaveAttribute('href', '/marques/new-balance');
  });

  it('duplique la liste pour la boucle, copie masquée et hors tabulation', () => {
    const { container } = render(<BandeMarques marques={MARQUES} />);
    const listes = Array.from(screen.getByTestId('bande-piste').querySelectorAll('ul'));
    expect(listes).toHaveLength(2);
    expect(listes[0]?.getAttribute('aria-hidden')).toBeNull();
    expect(listes[1]?.getAttribute('aria-hidden')).toBe('true');
    const copies = Array.from((listes[1] as Element).querySelectorAll('a'));
    expect(copies).toHaveLength(3);
    for (const a of copies) expect(a.getAttribute('tabindex')).toBe('-1');
    expect(container.querySelectorAll('a')).toHaveLength(6);
  });
});
