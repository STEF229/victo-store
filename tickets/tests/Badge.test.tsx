import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { Badge } from '../src/components/ui/Badge';

describe('Badge', () => {
  it('rend un span contenant son texte', () => {
    render(<Badge>−30 %</Badge>);
    const el = screen.getByText('−30 %');
    expect(el.tagName).toBe('SPAN');
    expect(el).toHaveAttribute('data-ui', 'badge');
    expect(el).toHaveAttribute('data-testid', 'badge');
  });

  it('vaut la variante "neutre" par défaut', () => {
    render(<Badge>x</Badge>);
    expect(screen.getByText('x')).toHaveAttribute('data-variant', 'neutre');
  });

  it.each(['promo', 'neutre', 'marque', 'nouveau'] as const)('expose la variante %s', (v) => {
    render(<Badge variant={v}>x</Badge>);
    expect(screen.getByText('x')).toHaveAttribute('data-variant', v);
  });

  it('conserve la classe fournie', () => {
    render(<Badge className="perso">x</Badge>);
    expect(screen.getByText('x').className).toContain('perso');
  });
});
