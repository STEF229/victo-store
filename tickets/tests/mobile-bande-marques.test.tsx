import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { BandeMarques } from '../src/components/accueil/BandeMarques';

const classes = (el: Element | null) => (el?.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);

describe('bande des marques — téléphone', () => {
  it('écrit les marques en gras, plus petites sur téléphone', () => {
    render(<BandeMarques marques={[{ id: 'm1', nom: 'Nike', slug: 'nike' }]} />);
    expect(classes(screen.getByTestId('bande-marques'))).toContain('max-sm:h-16');
    const lien = screen.getAllByRole('link').find(() => true) ?? null;
    for (const k of ['font-black', 'max-sm:text-lg']) expect(classes(lien), k).toContain(k);
  });
});
