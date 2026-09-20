import { fireEvent, render, screen } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import { TriSelect } from '../src/components/catalogue/TriSelect';

describe('TriSelect', () => {
  it('rend un select étiqueté', () => {
    render(<TriSelect value="nouveautes" onChange={() => {}} />);
    expect(screen.getByLabelText('Trier par')).toBe(screen.getByTestId('tri'));
  });

  it('propose les quatre tris dans l’ordre', () => {
    render(<TriSelect value="nouveautes" onChange={() => {}} />);
    const options = screen.getAllByRole('option') as HTMLOptionElement[];
    expect(options.map((o) => o.value)).toEqual([
      'nouveautes',
      'prix-croissant',
      'prix-decroissant',
      'remise',
    ]);
    expect(options.map((o) => o.textContent)).toEqual([
      'Nouveautés',
      'Prix croissant',
      'Prix décroissant',
      'Meilleures remises',
    ]);
  });

  it('reflète la valeur courante', () => {
    render(<TriSelect value="remise" onChange={() => {}} />);
    expect((screen.getByTestId('tri') as HTMLSelectElement).value).toBe('remise');
  });

  it('remonte le changement', () => {
    const onChange = vi.fn();
    render(<TriSelect value="nouveautes" onChange={onChange} />);
    fireEvent.change(screen.getByTestId('tri'), { target: { value: 'prix-croissant' } });
    expect(onChange).toHaveBeenCalledWith('prix-croissant');
  });
});
