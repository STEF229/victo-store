import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { TuileMarque } from '../src/components/marques/TuileMarque';
import { hrefMarque, type Marque } from '../src/lib/catalogue';

const classes = (el: Element) => (el.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);
const NIKE: Marque = { id: 'm1', nom: 'Nike', slug: 'nike' };
const tuile = () => screen.getByTestId('tuile-marque-nike');

describe('TuileMarque', () => {
  it('mène à la page de la marque, avec son nom et son nombre de produits', () => {
    render(<TuileMarque resume={{ marque: NIKE, nombre: 14, enSoldes: 5 }} rang={0} />);
    expect(tuile()).toHaveAttribute('href', hrefMarque(NIKE));
    expect(tuile().textContent).toContain('Nike');
    expect(screen.getByTestId('tuile-produits').textContent).toBe('14 produits');
    expect(screen.getByTestId('tuile-soldes').textContent).toBe('5 en soldes');
    expect(tuile().querySelector('svg.lucide-arrow-up-right')).not.toBeNull();
  });

  it('n’affiche pas de pastille sans soldes', () => {
    render(<TuileMarque resume={{ marque: NIKE, nombre: 1, enSoldes: 0 }} rang={0} />);
    expect(screen.queryByTestId('tuile-soldes')).toBeNull();
    expect(screen.getByTestId('tuile-produits').textContent).toBe('1 produit');
  });

  it('alterne trois teintes selon le rang', () => {
    const teintes = [0, 1, 2, 3].map((rang) => {
      const { unmount } = render(<TuileMarque resume={{ marque: NIKE, nombre: 1, enSoldes: 0 }} rang={rang} />);
      const fond = classes(tuile()).filter((k) => k.startsWith('bg-'));
      unmount();
      return fond.join(' ');
    });
    expect(teintes).toEqual(['bg-[#EEF1F8]', 'bg-[#E9E4DA]', 'bg-[var(--vs-surface)]', 'bg-[#EEF1F8]']);
  });
});
