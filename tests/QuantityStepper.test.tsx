import { fireEvent, render, screen } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import { QuantityStepper } from '../src/components/ui/QuantityStepper';

const moins = () => screen.getByRole('button', { name: 'Diminuer la quantité' });
const plus = () => screen.getByRole('button', { name: 'Augmenter la quantité' });

describe('QuantityStepper — affichage', () => {
  it('affiche la quantité courante', () => {
    render(<QuantityStepper value={3} onChange={() => {}} />);
    expect(screen.getByTestId('quantite-valeur')).toHaveTextContent('3');
  });

  it('rend deux boutons de type "button"', () => {
    render(<QuantityStepper value={3} onChange={() => {}} />);
    expect(moins()).toHaveAttribute('type', 'button');
    expect(plus()).toHaveAttribute('type', 'button');
  });
});

describe('QuantityStepper — incréments', () => {
  it('augmente de un', () => {
    const onChange = vi.fn();
    render(<QuantityStepper value={3} onChange={onChange} />);
    fireEvent.click(plus());
    expect(onChange).toHaveBeenCalledWith(4);
  });

  it('diminue de un', () => {
    const onChange = vi.fn();
    render(<QuantityStepper value={3} onChange={onChange} />);
    fireEvent.click(moins());
    expect(onChange).toHaveBeenCalledWith(2);
  });
});

describe('QuantityStepper — bornes', () => {
  it('désactive le moins au minimum', () => {
    render(<QuantityStepper value={1} onChange={() => {}} />);
    expect(moins()).toBeDisabled();
    expect(plus()).toBeEnabled();
  });

  it('désactive le plus au maximum', () => {
    render(<QuantityStepper value={99} onChange={() => {}} />);
    expect(plus()).toBeDisabled();
    expect(moins()).toBeEnabled();
  });

  it('respecte des bornes personnalisées', () => {
    render(<QuantityStepper value={5} min={5} max={7} onChange={() => {}} />);
    expect(moins()).toBeDisabled();
    expect(plus()).toBeEnabled();
  });

  it('ne remonte jamais une valeur hors bornes', () => {
    const onChange = vi.fn();
    render(<QuantityStepper value={7} min={5} max={7} onChange={onChange} />);
    fireEvent.click(plus());
    expect(onChange).not.toHaveBeenCalled();
  });
});
