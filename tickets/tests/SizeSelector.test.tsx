import { fireEvent, render, screen } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import { SizeSelector } from '../src/components/ui/SizeSelector';

const TAILLES = [
  { value: '40', available: true },
  { value: '41', available: true },
  { value: '42', available: false },
];

describe('SizeSelector — structure', () => {
  it('rend un groupe étiqueté', () => {
    render(<SizeSelector sizes={TAILLES} onChange={() => {}} />);
    expect(screen.getByRole('group', { name: 'Taille' })).toBeInTheDocument();
  });

  it('accepte un libellé personnalisé', () => {
    render(<SizeSelector sizes={TAILLES} onChange={() => {}} label="Pointure" />);
    expect(screen.getByRole('group', { name: 'Pointure' })).toBeInTheDocument();
  });

  it('rend un bouton par taille', () => {
    render(<SizeSelector sizes={TAILLES} onChange={() => {}} />);
    expect(screen.getAllByRole('button')).toHaveLength(3);
  });
});

describe('SizeSelector — sélection', () => {
  it('signale la taille sélectionnée', () => {
    render(<SizeSelector sizes={TAILLES} value="41" onChange={() => {}} />);
    expect(screen.getByRole('button', { name: '41' })).toHaveAttribute('aria-pressed', 'true');
    expect(screen.getByRole('button', { name: '40' })).toHaveAttribute('aria-pressed', 'false');
  });

  it('ne sélectionne rien quand value est absent', () => {
    render(<SizeSelector sizes={TAILLES} onChange={() => {}} />);
    for (const b of screen.getAllByRole('button')) {
      expect(b).toHaveAttribute('aria-pressed', 'false');
    }
  });

  it('remonte la taille choisie', () => {
    const onChange = vi.fn();
    render(<SizeSelector sizes={TAILLES} onChange={onChange} />);
    fireEvent.click(screen.getByRole('button', { name: '40' }));
    expect(onChange).toHaveBeenCalledWith('40');
  });
});

describe('SizeSelector — ruptures de stock', () => {
  it('désactive les tailles indisponibles', () => {
    render(<SizeSelector sizes={TAILLES} onChange={() => {}} />);
    expect(screen.getByRole('button', { name: '42' })).toBeDisabled();
    expect(screen.getByRole('button', { name: '40' })).toBeEnabled();
  });

  it('ne remonte rien au clic sur une taille indisponible', () => {
    const onChange = vi.fn();
    render(<SizeSelector sizes={TAILLES} onChange={onChange} />);
    fireEvent.click(screen.getByRole('button', { name: '42' }));
    expect(onChange).not.toHaveBeenCalled();
  });

  it('rend des boutons de type "button"', () => {
    render(<SizeSelector sizes={TAILLES} onChange={() => {}} />);
    for (const b of screen.getAllByRole('button')) {
      expect(b).toHaveAttribute('type', 'button');
    }
  });
});
