import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { Carrousel } from '../src/components/accueil/Carrousel';

describe('Carrousel — flèches lucide', () => {
  it('utilise les chevrons lucide', () => {
    render(<Carrousel auto={false} />);
    expect(screen.getByRole('button', { name: 'Diapositive précédente' }).querySelector('svg.lucide-chevron-left')).not.toBeNull();
    expect(screen.getByRole('button', { name: 'Diapositive suivante' }).querySelector('svg.lucide-chevron-right')).not.toBeNull();
  });

  it('ne contient plus aucune icône dessinée à la main', () => {
    const { container } = render(<Carrousel auto={false} />);
    for (const s of Array.from(container.querySelectorAll('svg'))) {
      expect(s.classList.contains('lucide')).toBe(true);
    }
  });
});
