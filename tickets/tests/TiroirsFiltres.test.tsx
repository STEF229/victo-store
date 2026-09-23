import { readFileSync } from 'node:fs';
import { fireEvent, render, screen, within } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import {
  FERMER, OPTION_MARQUE, OPTION_TAILLE, OPTION_TRI, PILULE, PILULE_OFF, PILULE_ON,
  TIROIR, TIROIR_ENTETE, TIROIR_FOND, TIROIR_SECTION, TIROIR_TITRE, VALIDER,
} from '../src/components/catalogue/filtres-affichage';
import { TiroirsFiltres, type VueTiroir } from '../src/components/catalogue/TiroirsFiltres';
import type { Marque } from '../src/lib/catalogue';
import type { Criteres } from '../src/lib/filtres';

const classes = (el: Element) => el.className.split(/\s+/).filter(Boolean);
function porte(el: Element, ...attendues: string[]) {
  const reelles = classes(el);
  for (const chaine of attendues) for (const k of chaine.split(' ')) expect(reelles, `classe ${k}`).toContain(k);
}
const MARQUES: Marque[] = [
  { id: 'm1', nom: 'Nike', slug: 'nike' },
  { id: 'm2', nom: 'Lacoste', slug: 'lacoste' },
];

function poser(vue: VueTiroir, criteres: Criteres = {}) {
  const f = {
    onMarque: vi.fn(), onTaille: vi.fn(), onPromo: vi.fn(), onStock: vi.fn(), onTri: vi.fn(), onFermer: vi.fn(),
  };
  const rendu = render(
    <TiroirsFiltres vue={vue} marques={MARQUES} tailles={['40', '41']} criteres={criteres} tri="nouveautes" {...f} />,
  );
  return { ...f, container: rendu.container };
}

describe('TiroirsFiltres — fermé', () => {
  it('ne rend rien quand vue vaut null', () => {
    const { container } = poser(null);
    expect(container.innerHTML).toBe('');
  });
});

describe('TiroirsFiltres — filtres', () => {
  it('rend le fond puis le tiroir, avec leurs classes', () => {
    poser('filtres');
    const fond = screen.getByTestId('tiroir-fond');
    const tiroir = screen.getByTestId('tiroir-filtres');
    porte(fond, TIROIR_FOND);
    expect(fond).toHaveAttribute('aria-hidden', 'true');
    porte(tiroir, TIROIR);
    expect(tiroir).toHaveAttribute('role', 'dialog');
    expect(tiroir).toHaveAttribute('aria-label', 'Filtrer');
    expect(fond.compareDocumentPosition(tiroir) & Node.DOCUMENT_POSITION_FOLLOWING).toBeTruthy();
    expect(screen.queryByTestId('tiroir-tri')).toBeNull();
  });

  it('titre le tiroir et ses sections', () => {
    poser('filtres');
    const tiroir = screen.getByTestId('tiroir-filtres');
    porte(within(tiroir).getByText('Filtrer', { selector: 'p' }), TIROIR_TITRE);
    porte(within(tiroir).getByText('Marques'), TIROIR_SECTION);
    porte(within(tiroir).getByText('Tailles'), TIROIR_SECTION);
    const fermer = within(tiroir).getByRole('button', { name: 'Fermer' });
    porte(fermer, FERMER);
    expect(fermer.querySelector('svg.lucide-x')).not.toBeNull();
    expect(tiroir.querySelector(`.${TIROIR_ENTETE.split(' ').join('.')}`)).not.toBeNull();
    expect(tiroir.querySelector('h1, h2, h3')).toBeNull();
  });

  it('marque les choix actifs et les autres', () => {
    poser('filtres', { marques: ['nike'], tailles: ['41'], promotionSeulement: true });
    const nike = screen.getByTestId('filtre-marque-nike');
    porte(nike, OPTION_MARQUE, PILULE_ON);
    expect(nike).toHaveAttribute('aria-pressed', 'true');
    porte(screen.getByTestId('filtre-marque-lacoste'), OPTION_MARQUE, PILULE_OFF);
    expect(screen.getByTestId('filtre-marque-lacoste')).toHaveAttribute('aria-pressed', 'false');
    porte(screen.getByTestId('filtre-taille-41'), OPTION_TAILLE, PILULE_ON);
    porte(screen.getByTestId('filtre-taille-40'), OPTION_TAILLE, PILULE_OFF);
    porte(screen.getByTestId('filtre-promo'), PILULE, 'flex-1 justify-center', PILULE_ON);
    porte(screen.getByTestId('filtre-stock'), PILULE, 'flex-1 justify-center', PILULE_OFF);
    expect(screen.getByTestId('filtre-stock')).toHaveAttribute('aria-pressed', 'false');
  });

  it('remonte chaque action', () => {
    const f = poser('filtres');
    fireEvent.click(screen.getByTestId('filtre-marque-lacoste'));
    expect(f.onMarque).toHaveBeenCalledWith('lacoste');
    fireEvent.click(screen.getByTestId('filtre-taille-40'));
    expect(f.onTaille).toHaveBeenCalledWith('40');
    fireEvent.click(screen.getByTestId('filtre-promo'));
    expect(f.onPromo).toHaveBeenCalledTimes(1);
    fireEvent.click(screen.getByTestId('filtre-stock'));
    expect(f.onStock).toHaveBeenCalledTimes(1);
    expect(f.onFermer).not.toHaveBeenCalled();
  });

  it('ferme par la croix, le bouton de validation et le fond', () => {
    const f = poser('filtres');
    const valider = screen.getByRole('button', { name: 'Appliquer les filtres' });
    porte(valider, VALIDER);
    fireEvent.click(screen.getByRole('button', { name: 'Fermer' }));
    fireEvent.click(valider);
    fireEvent.click(screen.getByTestId('tiroir-fond'));
    expect(f.onFermer).toHaveBeenCalledTimes(3);
  });
});

describe('TiroirsFiltres — tri', () => {
  it('rend le tiroir de tri et marque le tri courant', () => {
    poser('tri');
    const tiroir = screen.getByTestId('tiroir-tri');
    porte(tiroir, TIROIR);
    expect(tiroir).toHaveAttribute('aria-label', 'Trier');
    porte(within(tiroir).getByText('Trier par', { selector: 'p' }), TIROIR_TITRE);
    expect(within(tiroir).getAllByRole('button').map((b: HTMLElement) => b.textContent)).toEqual([
      '', 'Nouveautés', 'Prix croissant', 'Prix décroissant', 'Meilleures remises',
    ]);
    const courant = within(tiroir).getByRole('button', { name: 'Nouveautés' });
    porte(courant, OPTION_TRI, PILULE_ON);
    expect(courant).toHaveAttribute('aria-pressed', 'true');
    porte(within(tiroir).getByRole('button', { name: 'Prix croissant' }), OPTION_TRI, PILULE_OFF);
    expect(screen.queryByTestId('tiroir-filtres')).toBeNull();
  });

  it('choisit un tri puis ferme', () => {
    const f = poser('tri');
    fireEvent.click(screen.getByRole('button', { name: 'Meilleures remises' }));
    expect(f.onTri).toHaveBeenCalledWith('remise');
    expect(f.onFermer).toHaveBeenCalledTimes(1);
  });
});

describe('TiroirsFiltres — source', () => {
  it("ne code aucune couleur à la main : tout vient des constantes", () => {
    const source = readFileSync('src/components/catalogue/TiroirsFiltres.tsx', 'utf8');
    expect(source).not.toContain('var(--vs-');
    expect(source).toContain("from '@/components/catalogue/filtres-affichage'");
  });
});
