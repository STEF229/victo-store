import { readFileSync } from 'node:fs';
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { Carrousel } from '../src/components/accueil/Carrousel';

const classes = (el: Element | null) => (el?.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);

describe('carrousel — téléphone', () => {
  it('donne des marges et un titre compact aux diapositives', () => {
    render(<Carrousel auto={false} />);
    const titre = screen.getByRole('heading', { level: 1 });
    for (const k of ['text-5xl', 'max-sm:text-[30px]', 'max-sm:leading-[1.05]']) expect(classes(titre), k).toContain(k);
    const grille = titre.closest('.grid');
    for (const k of ['max-sm:px-5', 'max-sm:pt-7', 'max-sm:pb-14']) expect(classes(grille), k).toContain(k);
  });

  it('masque la description, l’image et les flèches sur téléphone', () => {
    const { container } = render(<Carrousel auto={false} />);
    expect(classes(screen.getByText(/^Les marques que vous aimez/))).toContain('max-sm:hidden');
    expect(classes(container.querySelector('img')?.closest('div') ?? null)).toContain('max-sm:hidden');
    for (const nom of ['Diapositive précédente', 'Diapositive suivante']) {
      expect(classes(screen.getByRole('button', { name: nom })), nom).toContain('max-sm:hidden');
    }
  });

  it('réduit les boutons d’action', () => {
    render(<Carrousel auto={false} />);
    const action = screen.getByRole('link', { name: 'Découvrir la boutique' });
    for (const k of ['h-14', 'max-sm:h-11', 'max-sm:px-5']) expect(classes(action), k).toContain(k);
  });

  it('change de diapositive en glissant le doigt', () => {
    const source = readFileSync('src/components/accueil/Carrousel.tsx', 'utf8');
    expect(source).toContain('onTouchStart');
    expect(source).toContain('onTouchEnd');
    expect(source).toContain('if (ecart < -40) allerSuivant();');
    expect(source).toContain('else if (ecart > 40) allerPrecedent();');
  });
});
