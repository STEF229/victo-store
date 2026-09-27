import { fireEvent, render, screen, within } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import { FiltresBarre } from '../src/components/catalogue/FiltresBarre';

function poser(nombreResultats?: number) {
  const base = { marques: [], tailles: [], criteres: {}, onChange: vi.fn(), tri: 'nouveautes' as const, onTriChange: vi.fn() };
  render(nombreResultats === undefined ? <FiltresBarre {...base} /> : <FiltresBarre {...base} nombreResultats={nombreResultats} />);
  fireEvent.click(screen.getByTestId('ouvrir-filtres'));
  return screen.getByTestId('tiroir-filtres');
}

describe('FiltresBarre — nombre de résultats', () => {
  it('le transmet au tiroir mobile', () => {
    const tiroir = poser(5);
    expect(within(tiroir).getByRole('button', { name: 'Voir 5 produits' })).toBeInTheDocument();
  });

  it('laisse le texte par défaut sans nombre', () => {
    const tiroir = poser();
    expect(within(tiroir).getByRole('button', { name: 'Appliquer les filtres' })).toBeInTheDocument();
  });
});
