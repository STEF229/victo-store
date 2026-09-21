import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { Price } from '../src/components/ui/Price';

describe('Price — option afficherRemise', () => {
  it('affiche la remise par défaut', () => {
    render(<Price amount={12600} compareAt={18000} />);
    expect(screen.getByTestId('prix-remise')).toBeInTheDocument();
  });

  it('masque la remise quand afficherRemise vaut false', () => {
    render(<Price amount={12600} compareAt={18000} afficherRemise={false} />);
    expect(screen.queryByTestId('prix-remise')).toBeNull();
  });

  it('garde le prix barré et la promotion quand la remise est masquée', () => {
    render(<Price amount={12600} compareAt={18000} afficherRemise={false} />);
    expect(screen.getByTestId('prix-compare')).toBeInTheDocument();
    expect(screen.getByTestId('prix')).toHaveAttribute('data-promo', 'true');
  });
});
