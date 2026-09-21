import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { MosaiqueCategories } from '../src/components/accueil/MosaiqueCategories';

describe('MosaiqueCategories — flèches lucide', () => {
  it('place une flèche lucide dans chacune des quatre tuiles', () => {
    render(<MosaiqueCategories />);
    const liens = screen.getAllByRole('link');
    expect(liens).toHaveLength(4);
    for (const a of liens) expect(a.querySelector('svg.lucide-arrow-up-right')).not.toBeNull();
  });

  it('ne contient plus aucune icône dessinée à la main', () => {
    const { container } = render(<MosaiqueCategories />);
    for (const s of Array.from(container.querySelectorAll('svg'))) {
      expect(s.classList.contains('lucide')).toBe(true);
    }
  });
});
