import { fireEvent, render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { GalerieProduit } from '../src/components/produit/GalerieProduit';

// getAttribute('class') et non className : sur un SVG, className n'est pas une chaîne.
const classes = (el: Element) => (el.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);
function porte(el: Element, chaine: string) {
  const nom = el.getAttribute('aria-label') ?? el.getAttribute('data-testid') ?? el.tagName;
  for (const k of chaine.split(' ')) expect(classes(el), `${nom} : classe ${k} manquante`).toContain(k);
}
const IMAGES = ['/img/a.svg', '/img/b.svg', '/img/c.svg', '/img/d.svg'];
const VIGNETTE = 'h-[110px] overflow-hidden rounded-[18px] border-2 bg-[var(--vs-surface)]';
const principale = () => screen.getByAltText(/, vue \d$/);

describe('GalerieProduit — image principale', () => {
  it('affiche la première vue, décrite', () => {
    render(<GalerieProduit images={IMAGES} nom="Pegasus" remise={30} />);
    expect(principale()).toHaveAttribute('src', '/img/a.svg');
    expect(principale()).toHaveAttribute('alt', 'Pegasus, vue 1');
    porte(screen.getByTestId('galerie'), 'flex flex-col gap-4');
  });

  it('pose la pastille de remise seulement s’il y en a une', () => {
    const { unmount } = render(<GalerieProduit images={IMAGES} nom="Pegasus" remise={30} />);
    const pastille = screen.getByTestId('galerie-remise');
    expect(pastille.textContent).toContain('30');
    expect(pastille.textContent).toContain('%');
    porte(pastille, 'absolute rounded-full bg-[var(--vs-promo)] text-[var(--vs-blanc)]');
    unmount();
    render(<GalerieProduit images={IMAGES} nom="Pegasus" remise={null} />);
    expect(screen.queryByTestId('galerie-remise')).toBeNull();
  });
});

describe('GalerieProduit — vignettes', () => {
  it('rend une vignette par vue et marque la vue affichée', () => {
    render(<GalerieProduit images={IMAGES} nom="Pegasus" remise={null} />);
    const v1 = screen.getByRole('button', { name: 'Afficher la vue 1' });
    const v2 = screen.getByRole('button', { name: 'Afficher la vue 2' });
    expect(screen.getAllByRole('button', { name: /^Afficher la vue/ })).toHaveLength(4);
    porte(v1, VIGNETTE);
    porte(v1, 'border-[var(--vs-noir)]');
    expect(v1).toHaveAttribute('aria-pressed', 'true');
    porte(v2, 'border-transparent');
    expect(v2).toHaveAttribute('aria-pressed', 'false');
  });

  it('change de vue au clic', () => {
    render(<GalerieProduit images={IMAGES} nom="Pegasus" remise={null} />);
    fireEvent.click(screen.getByRole('button', { name: 'Afficher la vue 3' }));
    expect(principale()).toHaveAttribute('src', '/img/c.svg');
    expect(principale()).toHaveAttribute('alt', 'Pegasus, vue 3');
    expect(screen.getByRole('button', { name: 'Afficher la vue 3' })).toHaveAttribute('aria-pressed', 'true');
    expect(screen.getByRole('button', { name: 'Afficher la vue 1' })).toHaveAttribute('aria-pressed', 'false');
  });

  it('n’affiche pas de vignettes pour une seule image', () => {
    render(<GalerieProduit images={['/img/a.svg']} nom="Pegasus" remise={null} />);
    expect(screen.queryAllByRole('button')).toHaveLength(0);
    expect(principale()).toHaveAttribute('src', '/img/a.svg');
  });
});
