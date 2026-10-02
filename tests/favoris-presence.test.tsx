import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { FavorisProvider, useFavoris } from '../src/components/favoris/FavorisProvider';

function Temoin() {
  const f = useFavoris();
  return <span data-testid="present">{String(f.present)}</span>;
}

describe('favoris — présence du fournisseur', () => {
  it('n’est pas présent hors du fournisseur', () => {
    render(<Temoin />);
    expect(screen.getByTestId('present').textContent).toBe('false');
  });

  it('est présent dans le fournisseur', () => {
    render(<FavorisProvider><Temoin /></FavorisProvider>);
    expect(screen.getByTestId('present').textContent).toBe('true');
  });
});
