import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { Reassurance } from '../src/components/accueil/Reassurance';

describe('Reassurance — icônes lucide', () => {
  it('utilise camion, retour et cadenas, dans cet ordre', () => {
    render(<Reassurance />);
    const items = Array.from(screen.getByTestId('reassurance').querySelectorAll('li'));
    expect(items).toHaveLength(3);
    expect(items[0]?.querySelector('svg.lucide-truck')).not.toBeNull();
    expect(items[1]?.querySelector('svg.lucide-rotate-ccw')).not.toBeNull();
    expect(items[2]?.querySelector('svg.lucide-lock')).not.toBeNull();
  });

  it('ne contient plus aucune icône dessinée à la main', () => {
    const { container } = render(<Reassurance />);
    for (const s of Array.from(container.querySelectorAll('svg'))) {
      expect(s.classList.contains('lucide')).toBe(true);
    }
  });
});
