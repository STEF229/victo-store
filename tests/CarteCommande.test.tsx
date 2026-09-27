import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { CLASSES_STATUT } from '../src/components/compte/compte-affichage';
import { CarteCommande } from '../src/components/compte/CarteCommande';
import { COMMANDES_DEMO, totauxCommande, type Commande } from '../src/lib/compte';
import { formatPrice } from '../src/lib/formatPrice';

const classes = (el: Element) => (el.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);
const commande = (numero: string) => COMMANDES_DEMO.find((c) => c.numero === numero) as Commande;

describe('CarteCommande', () => {
  it('résume numéro, date, articles et total', () => {
    const c = commande('VS-10482');
    render(<CarteCommande commande={c} />);
    expect(screen.getByRole('heading', { level: 3 }).textContent).toBe('Commande VS-10482');
    expect(screen.getByTestId('commande-resume').textContent).toBe(
      `24 septembre 2026 · 3 articles · ${formatPrice(totauxCommande(c).totalCents)}`,
    );
  });

  it('colore le statut', () => {
    render(<CarteCommande commande={commande('VS-10291')} />);
    const statut = screen.getByTestId('commande-statut');
    expect(statut.textContent).toBe('Annulée');
    for (const k of CLASSES_STATUT.annulee.split(' ')) expect(classes(statut)).toContain(k);
  });

  it('liste les articles, avec la quantité quand elle dépasse un', () => {
    render(<CarteCommande commande={commande('VS-10360')} />);
    expect(screen.getAllByRole('listitem').map((li: HTMLElement) => li.textContent)).toEqual([
      'Converse Chuck Taylor All Star · 38 × 2',
    ]);
  });
});
