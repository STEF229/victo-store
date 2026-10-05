import { render, screen, within } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { RubriquesRapides } from '../src/components/accueil/RubriquesRapides';
import { NAV } from '../src/lib/navigation';

const classes = (el: Element | null) => (el?.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);

describe('pastilles des rubriques', () => {
  it('propose chaque rubrique, sur téléphone et tablette seulement', () => {
    render(<RubriquesRapides items={NAV} />);
    const nav = screen.getByRole('navigation', { name: 'Rubriques' });
    for (const k of ['lg:hidden', 'overflow-x-auto', '[scrollbar-width:none]']) expect(classes(nav), k).toContain(k);
    expect(within(nav).getAllByRole('link').map((l: HTMLElement) => l.getAttribute('href'))).toEqual(NAV.map((n) => n.href));
  });

  it('colore chaque pastille, et met les soldes en rouge', () => {
    render(<RubriquesRapides items={NAV} />);
    const femme = screen.getByRole('link', { name: 'Femme' });
    expect(classes(femme.querySelector('[aria-hidden="true"]'))).toContain('bg-[#EEF1F8]');
    expect(classes(screen.getByText('Soldes'))).toContain('text-[var(--vs-promo)]');
    expect(classes(screen.getByText('Homme'))).toContain('text-[var(--vs-noir)]');
  });

  it('donne une teinte neutre à une rubrique inconnue', () => {
    render(<RubriquesRapides items={[{ label: 'Nouveautés', href: '/nouveautes' }]} />);
    expect(classes(screen.getByRole('link', { name: 'Nouveautés' }).querySelector('[aria-hidden="true"]'))).toContain('bg-[var(--vs-surface)]');
  });
});
