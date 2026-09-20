import { fireEvent, render, screen } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import { Field } from '../src/components/ui/Field';

describe('Field — structure', () => {
  it('associe le libellé au champ', () => {
    render(<Field id="courriel" label="Courriel" />);
    const input = screen.getByLabelText('Courriel');
    expect(input).toHaveAttribute('id', 'courriel');
  });

  it('vaut le type "text" par défaut et accepte un autre type', () => {
    const { rerender } = render(<Field id="a" label="A" />);
    expect(screen.getByLabelText('A')).toHaveAttribute('type', 'text');
    rerender(<Field id="a" label="A" type="password" />);
    expect(screen.getByLabelText('A')).toHaveAttribute('type', 'password');
  });

  it('transmet la saisie', () => {
    const onChange = vi.fn();
    render(<Field id="a" label="A" onChange={onChange} />);
    fireEvent.change(screen.getByLabelText('A'), { target: { value: 'z' } });
    expect(onChange).toHaveBeenCalled();
  });

  it('marque le champ obligatoire', () => {
    render(<Field id="a" label="A" required />);
    expect(screen.getByLabelText(/A/)).toBeRequired();
  });
});

describe('Field — aide et erreur', () => {
  it('affiche une aide reliée par aria-describedby', () => {
    render(<Field id="mdp" label="Mot de passe" hint="8 caractères minimum" />);
    const input = screen.getByLabelText('Mot de passe');
    const aide = screen.getByText('8 caractères minimum');
    expect(aide).toHaveAttribute('id', 'mdp-hint');
    expect(input.getAttribute('aria-describedby')).toContain('mdp-hint');
  });

  it('affiche une erreur annoncée et reliée', () => {
    render(<Field id="mdp" label="Mot de passe" error="Trop court" />);
    const input = screen.getByLabelText('Mot de passe');
    const err = screen.getByRole('alert');
    expect(err).toHaveTextContent('Trop court');
    expect(err).toHaveAttribute('id', 'mdp-error');
    expect(input).toHaveAttribute('aria-invalid', 'true');
    expect(input.getAttribute('aria-describedby')).toContain('mdp-error');
  });

  it('relie aide et erreur en même temps', () => {
    render(<Field id="x" label="X" hint="aide" error="erreur" />);
    const d = screen.getByLabelText('X').getAttribute('aria-describedby') ?? '';
    expect(d).toContain('x-hint');
    expect(d).toContain('x-error');
  });

  it("n'ajoute rien quand il n'y a ni aide ni erreur", () => {
    render(<Field id="x" label="X" />);
    const input = screen.getByLabelText('X');
    expect(input).not.toHaveAttribute('aria-describedby');
    expect(input).not.toHaveAttribute('aria-invalid', 'true');
    expect(screen.queryByRole('alert')).toBeNull();
  });
});
