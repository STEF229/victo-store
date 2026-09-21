import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { BarreAnnonce } from '../src/components/accueil/BarreAnnonce';

const classes = (el: Element) => el.className.split(/\s+/).filter(Boolean);

describe('BarreAnnonce', () => {
  it('porte les couleurs imposées', () => {
    render(<BarreAnnonce />);
    const barre = screen.getByTestId('barre-annonce');
    for (const c of ['bg-[var(--vs-noir)]', 'text-[var(--vs-blanc)]']) expect(classes(barre)).toContain(c);
  });

  it('affiche les trois messages dans l’ordre', () => {
    render(<BarreAnnonce />);
    const items = Array.from(screen.getByTestId('barre-annonce').querySelectorAll('li'));
    expect(items.map((li) => li.textContent?.trim())).toEqual([
      'Livraison offerte au Canada',
      'Retours gratuits 30 jours',
      'Authenticité garantie',
    ]);
  });

  it('centre la liste', () => {
    render(<BarreAnnonce />);
    const ul = screen.getByTestId('barre-annonce').querySelector('ul');
    expect(ul).not.toBeNull();
    for (const c of ['flex', 'items-center', 'justify-center', 'gap-7']) {
      expect(classes(ul as Element)).toContain(c);
    }
  });

  it('ne garde que le premier message sur téléphone', () => {
    render(<BarreAnnonce />);
    const items = Array.from(screen.getByTestId('barre-annonce').querySelectorAll('li'));
    expect(classes(items[0] as Element)).not.toContain('hidden');
    for (const li of items.slice(1)) {
      expect(classes(li)).toContain('hidden');
      expect(classes(li)).toContain('sm:flex');
    }
  });
});
