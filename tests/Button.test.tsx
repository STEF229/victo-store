import { fireEvent, render, screen } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import { Button } from '../src/components/ui/Button';

describe('Button — bases', () => {
  it('rend un bouton de type "button" par défaut', () => {
    render(<Button>Ajouter</Button>);
    const b = screen.getByRole('button', { name: 'Ajouter' });
    expect(b).toHaveAttribute('type', 'button');
    expect(b).toHaveAttribute('data-ui', 'button');
  });

  it('accepte un type explicite', () => {
    render(<Button type="submit">Envoyer</Button>);
    expect(screen.getByRole('button')).toHaveAttribute('type', 'submit');
  });

  it('transmet le clic', () => {
    const onClick = vi.fn();
    render(<Button onClick={onClick}>Clic</Button>);
    fireEvent.click(screen.getByRole('button'));
    expect(onClick).toHaveBeenCalledTimes(1);
  });
});

describe('Button — variantes et tailles', () => {
  it('vaut primary/md par défaut', () => {
    render(<Button>x</Button>);
    const b = screen.getByRole('button');
    expect(b).toHaveAttribute('data-variant', 'primary');
    expect(b).toHaveAttribute('data-size', 'md');
  });

  it.each(['primary', 'ghost', 'accent'] as const)('expose la variante %s', (v) => {
    render(<Button variant={v}>x</Button>);
    expect(screen.getByRole('button')).toHaveAttribute('data-variant', v);
  });

  it.each(['sm', 'md', 'lg'] as const)('expose la taille %s', (s) => {
    render(<Button size={s}>x</Button>);
    expect(screen.getByRole('button')).toHaveAttribute('data-size', s);
  });

  it('marque le mode pleine largeur', () => {
    const { rerender } = render(<Button>x</Button>);
    expect(screen.getByRole('button')).not.toHaveAttribute('data-block');
    rerender(<Button block>x</Button>);
    expect(screen.getByRole('button')).toHaveAttribute('data-block', 'true');
  });
});

describe('Button — états', () => {
  it('se désactive quand disabled', () => {
    render(<Button disabled>x</Button>);
    expect(screen.getByRole('button')).toBeDisabled();
  });

  it('se désactive et signale aria-busy quand loading', () => {
    render(<Button loading>x</Button>);
    const b = screen.getByRole('button');
    expect(b).toBeDisabled();
    expect(b).toHaveAttribute('aria-busy', 'true');
  });

  it("n'annonce pas aria-busy au repos", () => {
    render(<Button>x</Button>);
    expect(screen.getByRole('button')).not.toHaveAttribute('aria-busy', 'true');
  });

  it('ne déclenche pas le clic quand loading', () => {
    const onClick = vi.fn();
    render(<Button loading onClick={onClick}>x</Button>);
    fireEvent.click(screen.getByRole('button'));
    expect(onClick).not.toHaveBeenCalled();
  });

  it('conserve la classe fournie', () => {
    render(<Button className="perso">x</Button>);
    expect(screen.getByRole('button').className).toContain('perso');
  });
});
