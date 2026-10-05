import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { Carrousel } from '../src/components/accueil/Carrousel';

const classes = (el: Element | null) => (el?.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);

describe('carrousel — photo en fond sur téléphone', () => {
  it('étend la photo à tout le bandeau, sous un dégradé', () => {
    const { container } = render(<Carrousel auto={false} />);
    const image = container.querySelector('img');
    for (const k of ['max-sm:absolute', 'max-sm:inset-0']) expect(classes(image?.closest('div') ?? null), k).toContain(k);
    for (const k of ['h-[520px]', 'max-sm:h-full', 'max-sm:rounded-none']) expect(classes(image), k).toContain(k);
    const degrades = screen.getAllByTestId('carrousel-degrade');
    expect(degrades.length).toBeGreaterThan(0);
    for (const k of ['hidden', 'max-sm:block', 'absolute', 'inset-0']) expect(classes(degrades.find(() => true) ?? null), k).toContain(k);
  });

  it('pose le texte en blanc, au-dessus de la photo', () => {
    render(<Carrousel auto={false} />);
    const texte = screen.getByRole('heading', { level: 1 }).closest('div');
    for (const k of ['max-sm:relative', 'max-sm:z-10', 'max-sm:text-[var(--vs-blanc)]']) expect(classes(texte), k).toContain(k);
    const bandeau = texte?.closest('.grid') ?? null;
    for (const k of ['max-sm:min-h-[300px]', 'max-sm:items-end', 'max-sm:overflow-hidden']) expect(classes(bandeau), k).toContain(k);
  });
});
