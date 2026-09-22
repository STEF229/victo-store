import { fireEvent, render, screen, within } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import { FiltresBarre } from '../src/components/catalogue/FiltresBarre';
import type { Marque } from '../src/lib/catalogue';
import type { Criteres } from '../src/lib/filtres';

const classes = (el: Element) => el.className.split(/\s+/).filter(Boolean);
const MARQUES: Marque[] = [
  { id: 'm1', nom: 'Nike', slug: 'nike' },
  { id: 'm2', nom: 'Lacoste', slug: 'lacoste' },
];
const TAILLES = ['40', '41', 'M'];

function poser(criteres: Criteres = {}, onChange = vi.fn(), onTriChange = vi.fn()) {
  render(
    <FiltresBarre
      marques={MARQUES}
      tailles={TAILLES}
      criteres={criteres}
      onChange={onChange}
      tri="nouveautes"
      onTriChange={onTriChange}
    />,
  );
  return { onChange, onTriChange };
}

describe('FiltresBarre — barre', () => {
  it('rend la barre horizontale, masquée sur téléphone', () => {
    poser();
    const barre = screen.getByTestId('barre-bureau');
    for (const k of ['hidden', 'flex-wrap', 'items-center', 'gap-3', 'lg:flex']) expect(classes(barre)).toContain(k);
  });

  it('ferme les panneaux au départ', () => {
    poser();
    expect(screen.queryByTestId('panneau-marques')).toBeNull();
    expect(screen.queryByTestId('panneau-tailles')).toBeNull();
    expect(screen.getByTestId('bouton-marques').textContent).toContain('Marque');
  });

  it('ouvre le panneau des marques et le referme', () => {
    poser();
    fireEvent.click(screen.getByTestId('bouton-marques'));
    expect(screen.getByTestId('panneau-marques')).toBeInTheDocument();
    expect(screen.getByTestId('filtre-marque-nike')).toBeInTheDocument();
    fireEvent.click(screen.getByTestId('bouton-marques'));
    expect(screen.queryByTestId('panneau-marques')).toBeNull();
  });

  it('n’ouvre qu’un panneau à la fois', () => {
    poser();
    fireEvent.click(screen.getByTestId('bouton-marques'));
    fireEvent.click(screen.getByTestId('bouton-tailles'));
    expect(screen.queryByTestId('panneau-marques')).toBeNull();
    expect(screen.getByTestId('panneau-tailles')).toBeInTheDocument();
    expect(screen.getByTestId('filtre-taille-41')).toBeInTheDocument();
  });

  it('compte les sélections dans le libellé des boutons', () => {
    poser({ marques: ['nike'], tailles: ['40', '41'] });
    expect(screen.getByTestId('bouton-marques').textContent).toContain('Marque (1)');
    expect(screen.getByTestId('bouton-tailles').textContent).toContain('Taille (2)');
  });
});

describe('FiltresBarre — critères', () => {
  it('ajoute une marque', () => {
    const { onChange } = poser();
    fireEvent.click(screen.getByTestId('bouton-marques'));
    fireEvent.click(screen.getByTestId('filtre-marque-nike'));
    expect(onChange.mock.calls[0]?.[0].marques).toEqual(['nike']);
  });

  it('retire une marque déjà choisie', () => {
    const { onChange } = poser({ marques: ['nike', 'lacoste'] });
    fireEvent.click(screen.getByTestId('bouton-marques'));
    fireEvent.click(screen.getByTestId('filtre-marque-nike'));
    expect(onChange.mock.calls[0]?.[0].marques).toEqual(['lacoste']);
  });

  it('ajoute une taille', () => {
    const { onChange } = poser();
    fireEvent.click(screen.getByTestId('bouton-tailles'));
    fireEvent.click(screen.getByTestId('filtre-taille-M'));
    expect(onChange.mock.calls[0]?.[0].tailles).toEqual(['M']);
  });

  it('bascule les deux interrupteurs', () => {
    const { onChange } = poser();
    fireEvent.click(screen.getByTestId('filtre-promo'));
    expect(onChange.mock.calls[0]?.[0].promotionSeulement).toBe(true);
    fireEvent.click(screen.getByTestId('filtre-stock'));
    expect(onChange.mock.calls[1]?.[0].enStockSeulement).toBe(true);
  });

  it('ne mute pas l’objet reçu', () => {
    const criteres = { marques: ['nike'] };
    poser(criteres);
    fireEvent.click(screen.getByTestId('bouton-marques'));
    fireEvent.click(screen.getByTestId('filtre-marque-lacoste'));
    expect(criteres.marques).toEqual(['nike']);
  });

  it('remonte le tri', () => {
    const { onTriChange } = poser();
    fireEvent.change(screen.getByTestId('tri'), { target: { value: 'remise' } });
    expect(onTriChange).toHaveBeenCalledWith('remise');
  });

  it('propose les quatre tris dans l’ordre', () => {
    poser();
    const options = within(screen.getByTestId('tri')).getAllByRole('option') as HTMLOptionElement[];
    expect(options.map((o) => o.value)).toEqual(['nouveautes', 'prix-croissant', 'prix-decroissant', 'remise']);
    expect(options.map((o) => o.textContent)).toEqual([
      'Nouveautés', 'Prix croissant', 'Prix décroissant', 'Meilleures remises',
    ]);
  });
});

describe('FiltresBarre — pastilles', () => {
  it('n’affiche rien sans filtre actif', () => {
    poser();
    expect(screen.queryByTestId('pastilles')).toBeNull();
  });

  it('affiche une pastille par filtre actif', () => {
    poser({ marques: ['nike'], tailles: ['41'], promotionSeulement: true, enStockSeulement: true });
    const p = screen.getByTestId('pastilles');
    expect(within(p).getByRole('button', { name: 'Retirer le filtre Nike' })).toBeInTheDocument();
    expect(within(p).getByRole('button', { name: 'Retirer le filtre Taille 41' })).toBeInTheDocument();
    expect(within(p).getByRole('button', { name: 'Retirer le filtre Promotions' })).toBeInTheDocument();
    expect(within(p).getByRole('button', { name: 'Retirer le filtre En stock' })).toBeInTheDocument();
  });

  it('retire un filtre depuis sa pastille', () => {
    const { onChange } = poser({ marques: ['nike', 'lacoste'] });
    fireEvent.click(screen.getByRole('button', { name: 'Retirer le filtre Nike' }));
    expect(onChange.mock.calls[0]?.[0].marques).toEqual(['lacoste']);
  });

  it('efface tout', () => {
    const { onChange } = poser({ marques: ['nike'], promotionSeulement: true });
    fireEvent.click(screen.getByTestId('filtres-reinitialiser'));
    expect(onChange).toHaveBeenCalledWith({});
  });
});

describe('FiltresBarre — téléphone', () => {
  it('propose les deux boutons, réservés au téléphone', () => {
    poser();
    const zone = screen.getByTestId('barre-mobile');
    for (const k of ['flex', 'items-center', 'gap-3', 'lg:hidden']) expect(classes(zone)).toContain(k);
    expect(screen.getByTestId('ouvrir-tri').textContent).toBe('Trier');
  });

  it('compte les filtres actifs sur le bouton', () => {
    poser({ marques: ['nike'], tailles: ['41'], promotionSeulement: true });
    expect(screen.getByTestId('ouvrir-filtres').textContent).toContain('Filtrer (3)');
  });

  it('ouvre et ferme le tiroir de filtres', () => {
    poser();
    expect(screen.queryByTestId('tiroir-filtres')).toBeNull();
    fireEvent.click(screen.getByTestId('ouvrir-filtres'));
    const tiroir = screen.getByTestId('tiroir-filtres');
    expect(tiroir).toHaveAttribute('role', 'dialog');
    expect(within(tiroir).getByTestId('filtre-marque-nike')).toBeInTheDocument();
    fireEvent.click(within(tiroir).getByRole('button', { name: 'Fermer' }));
    expect(screen.queryByTestId('tiroir-filtres')).toBeNull();
  });

  it('ouvre le tiroir de tri', () => {
    poser();
    fireEvent.click(screen.getByTestId('ouvrir-tri'));
    const tiroir = screen.getByTestId('tiroir-tri');
    expect(within(tiroir).getByRole('button', { name: 'Meilleures remises' })).toBeInTheDocument();
  });

  it('ne rend jamais deux fois le même filtre', () => {
    poser();
    fireEvent.click(screen.getByTestId('ouvrir-filtres'));
    expect(screen.getAllByTestId('filtre-marque-nike')).toHaveLength(1);
  });
});
