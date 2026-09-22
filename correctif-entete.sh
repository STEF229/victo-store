#!/usr/bin/env bash
# VICTO STORE — correctif des tickets 090, 091 et 094.
#   1. retire définitivement les trois anciens tests qui contredisent la maquette
#   2. corrige le test d'en-tête (il visait le mauvais élément)
#   3. relance les trois tickets
# Usage :  cd ~/victo-store && bash correctif-entete.sh
set -euo pipefail
cd "${REPO:-$HOME/victo-store}"
ok()  { printf '  \033[32m✓\033[0m %s\n' "$*"; }
mort(){ printf '  \033[31m✗\033[0m %s\n' "$*"; exit 1; }

pgrep -f '(^|[ /])run\.sh( |$)' >/dev/null 2>&1 && mort "le harnais tourne encore"
git checkout -q main
git pull -q --rebase 2>/dev/null || true

trouves=0
for f in tests/accueil2-SiteHeader.test.tsx tickets/tests/accueil2-SiteHeader.test.tsx \
         tests/accueil2-page.test.tsx tickets/tests/accueil2-page.test.tsx \
         tests/VueCatalogue.test.tsx tickets/tests/VueCatalogue.test.tsx; do
  if [ -e "$f" ]; then trouves=$((trouves + 1)); fi
  git rm -q --ignore-unmatch -- "$f" >/dev/null 2>&1 || true
  rm -f -- "$f"
done
ok "anciens tests retirés ($trouves fichiers trouvés)"

cat > tickets/tests/entete-v3.test.tsx <<'FIN_TEST'
import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { SiteHeader, type NavItem } from '../src/components/ui/SiteHeader';

const classes = (el: Element) => el.className.split(/\s+/).filter(Boolean);
const NAV: NavItem[] = [
  { label: 'Femme', href: '/femme' },
  { label: 'Homme', href: '/homme' },
  { label: 'Soldes', href: '/soldes', promo: true },
];

describe('en-tête — barre noire unique', () => {
  it('rend une bannière noire', () => {
    render(<SiteHeader navItems={NAV} />);
    const entete = screen.getByTestId('entete');
    expect(entete).toBe(screen.getByRole('banner'));
    for (const k of ['bg-[var(--vs-noir)]', 'text-[var(--vs-blanc)]']) expect(classes(entete)).toContain(k);
  });

  it('répartit logo, navigation et actions sur une seule ligne', () => {
    render(<SiteHeader navItems={NAV} />);
    // La rangée en grille est l'enfant direct de l'en-tête ; le lien de marque est
    // dans la zone de gauche, donc on part de l'en-tête, pas du parent du lien.
    const ligne = screen.getByTestId('entete').firstElementChild as Element;
    for (const k of ['grid', 'h-20', 'grid-cols-[auto_1fr_auto]', 'items-center']) {
      expect(classes(ligne)).toContain(k);
    }
    expect(ligne.contains(screen.getByTestId('entete-marque'))).toBe(true);
    expect(ligne.contains(screen.getByRole('navigation', { name: 'Navigation principale' }))).toBe(true);
  });

  it('centre la navigation et la masque sur téléphone', () => {
    render(<SiteHeader navItems={NAV} />);
    const nav = screen.getByRole('navigation', { name: 'Navigation principale' });
    for (const k of ['hidden', 'justify-self-center', 'gap-8', 'lg:flex']) expect(classes(nav)).toContain(k);
  });

  it('colore en rouge clair la seule entrée promo', () => {
    render(<SiteHeader navItems={NAV} />);
    expect(classes(screen.getByRole('link', { name: 'Soldes' }))).toContain('text-[#FF5A74]');
    expect(classes(screen.getByRole('link', { name: 'Femme' }))).not.toContain('text-[#FF5A74]');
  });
});

describe('en-tête — recherche et actions', () => {
  it('propose un champ de recherche étiqueté', () => {
    render(<SiteHeader navItems={NAV} />);
    const champ = screen.getByLabelText('Rechercher un produit');
    expect(champ).toHaveAttribute('id', 'recherche-entete');
    expect(champ).toHaveAttribute('type', 'search');
    expect(champ).toHaveAttribute('placeholder', 'Rechercher');
  });

  it('réserve le bouton de menu au téléphone', () => {
    render(<SiteHeader navItems={NAV} />);
    const menu = screen.getByRole('button', { name: 'Ouvrir le menu' });
    expect(menu).toHaveAttribute('type', 'button');
    expect(classes(menu)).toContain('lg:hidden');
    expect(menu.querySelector('svg.lucide-menu')).not.toBeNull();
  });

  it('rend le compte et le panier avec leurs icônes lucide', () => {
    render(<SiteHeader navItems={NAV} cartCount={2} />);
    expect(screen.getByRole('button', { name: 'Mon compte' }).querySelector('svg.lucide-user')).not.toBeNull();
    const panier = screen.getByTestId('entete-panier');
    expect(panier.querySelector('svg.lucide-shopping-bag')).not.toBeNull();
    expect(classes(screen.getByTestId('entete-panier-compte'))).toContain('bg-[var(--vs-accent)]');
  });

  it("n'utilise que des icônes lucide", () => {
    const { container } = render(<SiteHeader navItems={NAV} cartCount={1} />);
    const svgs = Array.from(container.querySelectorAll('svg'));
    expect(svgs.length).toBeGreaterThanOrEqual(4);
    for (const s of svgs) {
      expect(s.classList.contains('lucide')).toBe(true);
      expect(s.getAttribute('aria-hidden')).toBe('true');
    }
  });
});

describe('en-tête — filet d’annonces', () => {
  it('reprend les trois messages sous la barre', () => {
    render(<SiteHeader navItems={NAV} />);
    const filet = screen.getByTestId('filet-annonce');
    expect(Array.from(filet.querySelectorAll('span')).map((s) => s.textContent)).toEqual([
      'Livraison offerte au Canada',
      'Retours gratuits 30 jours',
      'Authenticité garantie',
    ]);
  });

  it('se place après la barre', () => {
    render(<SiteHeader navItems={NAV} />);
    const entete = screen.getByTestId('entete');
    const filet = screen.getByTestId('filet-annonce');
    expect(entete.contains(filet)).toBe(false);
    expect(entete.compareDocumentPosition(filet) & Node.DOCUMENT_POSITION_FOLLOWING).toBeTruthy();
  });

  it('porte les couleurs du filet et ne garde qu’un message sur téléphone', () => {
    render(<SiteHeader navItems={NAV} />);
    const filet = screen.getByTestId('filet-annonce');
    for (const k of ['bg-[var(--vs-surface)]', 'text-[var(--vs-gris)]', 'border-b', 'border-[var(--vs-ligne)]']) {
      expect(classes(filet)).toContain(k);
    }
    const messages = Array.from(filet.querySelectorAll('span'));
    expect(classes(messages[0] as Element)).not.toContain('hidden');
    for (const m of messages.slice(1)) {
      expect(classes(m)).toContain('hidden');
      expect(classes(m)).toContain('sm:inline');
    }
  });
});
FIN_TEST
cat > tickets/tests/VueCatalogue-v2.test.tsx <<'FIN_VUE'
import { fireEvent, render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
// Dépendance déclarée pour le harnais : sans la barre de filtres, ce ticket est BLOQUÉ.
import { FiltresBarre as _dependance } from '../src/components/catalogue/FiltresBarre';
import { VueCatalogue } from '../src/components/catalogue/VueCatalogue';
import type { Marque, Produit } from '../src/lib/catalogue';

const classes = (el: Element) => el.className.split(/\s+/).filter(Boolean);
const NIKE: Marque = { id: 'm1', nom: 'Nike', slug: 'nike' };
const LACOSTE: Marque = { id: 'm2', nom: 'Lacoste', slug: 'lacoste' };
const P = (id: string, marque: Marque, prix: number): Produit => ({
  id, slug: `p-${id}`, nom: `Produit ${id}`, marque,
  imageUrl: '/img/pegasus.svg', prixCents: prix,
  variantes: [{ id: `${id}v`, taille: '41', sku: `${id}-41`, stock: 2 }],
});
const HUIT = [
  P('a', NIKE, 5000), P('b', NIKE, 6000), P('c', LACOSTE, 7000), P('d', NIKE, 8000),
  P('e', LACOSTE, 9000), P('f', NIKE, 10000), P('g', LACOSTE, 11000), P('h', NIKE, 12000),
];

describe('VueCatalogue — nouvelle disposition', () => {
  it('rend en-tête, titre, description et pied', () => {
    render(<VueCatalogue titre="Soldes" description="Une description." produits={HUIT} />);
    expect(screen.getByRole('banner')).toBeInTheDocument();
    expect(screen.getByTestId('liste-titre').textContent).toBe('Soldes');
    expect(screen.getByTestId('liste-description').textContent).toBe('Une description.');
    expect(screen.getByRole('contentinfo')).toBeInTheDocument();
  });

  it('remplace la colonne de filtres par la barre', () => {
    render(<VueCatalogue titre="Soldes" produits={HUIT} />);
    expect(screen.getByTestId('filtres-barre')).toBeInTheDocument();
    expect(screen.queryByTestId('filtres')).toBeNull();
  });

  it('affiche la grille sur quatre colonnes', () => {
    render(<VueCatalogue titre="Soldes" produits={HUIT} />);
    expect(classes(screen.getByTestId('grille'))).toContain('lg:grid-cols-4');
  });

  it('impose la taille du titre', () => {
    render(<VueCatalogue titre="Soldes" produits={HUIT} />);
    for (const k of ['text-5xl', 'font-black', 'tracking-tight', 'lg:text-6xl']) {
      expect(classes(screen.getByTestId('liste-titre'))).toContain(k);
    }
  });

  it('aligne le compteur avec le titre', () => {
    render(<VueCatalogue titre="Soldes" produits={HUIT} />);
    const rangee = screen.getByTestId('compteur').closest('.justify-between') as Element;
    expect(rangee).not.toBeNull();
    for (const k of ['flex', 'items-end', 'justify-between', 'gap-8']) expect(classes(rangee)).toContain(k);
    expect(rangee.contains(screen.getByTestId('liste-titre'))).toBe(true);
  });
});

describe('VueCatalogue — contenu', () => {
  it('compte les produits et en montre six par page', () => {
    render(<VueCatalogue titre="Soldes" produits={HUIT} />);
    expect(screen.getByTestId('compteur').textContent).toBe('8 produits');
    expect(screen.getAllByTestId('carte-produit')).toHaveLength(6);
    fireEvent.click(screen.getByRole('button', { name: 'Page suivante' }));
    expect(screen.getAllByTestId('carte-produit')).toHaveLength(2);
  });

  it('filtre par marque depuis la barre et revient à la première page', () => {
    render(<VueCatalogue titre="Soldes" produits={HUIT} />);
    fireEvent.click(screen.getByRole('button', { name: 'Page suivante' }));
    fireEvent.click(screen.getByTestId('bouton-marques'));
    fireEvent.click(screen.getByTestId('filtre-marque-lacoste'));
    expect(screen.getByTestId('compteur').textContent).toBe('3 produits');
    expect(screen.getAllByTestId('carte-produit')).toHaveLength(3);
  });

  it('ne propose que les marques présentes', () => {
    render(<VueCatalogue titre="Soldes" produits={HUIT} />);
    fireEvent.click(screen.getByTestId('bouton-marques'));
    expect(screen.getByTestId('filtre-marque-nike')).toBeInTheDocument();
    expect(screen.queryByTestId('filtre-marque-adidas')).toBeNull();
  });

  it('trie par prix croissant', () => {
    render(<VueCatalogue titre="Soldes" produits={HUIT} />);
    fireEvent.change(screen.getByTestId('tri'), { target: { value: 'prix-croissant' } });
    expect(screen.getAllByTestId('carte-nom').map((e) => e.textContent)).toEqual(
      [...HUIT].sort((a, b) => a.prixCents - b.prixCents).slice(0, 6).map((p) => p.nom),
    );
  });

  it('accorde le compteur et gère la liste vide', () => {
    const { unmount } = render(<VueCatalogue titre="Nike" produits={[P('z', NIKE, 9000)]} />);
    expect(screen.getByTestId('compteur').textContent).toBe('1 produit');
    unmount();
    render(<VueCatalogue titre="Marque introuvable" produits={[]} />);
    expect(screen.getByTestId('compteur').textContent).toBe('0 produit');
    expect(screen.getByTestId('grille-vide')).toBeInTheDocument();
  });
});
FIN_VUE
rm -f tests/entete-v3.test.tsx
ok "tests d'en-tête et de vue catalogue corrigés (plus de parentElement)"

git branch -D auto/090 auto/091 auto/094 >/dev/null 2>&1 || true
rm -f tests/accueil3-page.test.tsx tests/VueCatalogue-v2.test.tsx
grep -P '^(090|091|094)\t' tickets/manifest-entete-liste.tsv > tickets/manifest-rattrapage.tsv
[ "$(wc -l < tickets/manifest-rattrapage.tsv)" -eq 3 ] || mort "manifeste de rattrapage incomplet"
ok "branches et tests activés remis à zéro"

npm run --silent typecheck || mort "tsc rouge"
npm run --silent test >/tmp/victo-test.log 2>&1 || { grep -E "FAIL|×" /tmp/victo-test.log | head -10; mort "tests rouges"; }
ok "base verte"

git add -A -- tests tickets
git commit -q -m "fix(tests): retrait des anciens tests d'en-tete et de vue, correction du test d'entete"
GIT_TERMINAL_PROMPT=0 git push -q origin main 2>/dev/null && ok "poussé sur GitHub" || true

cat <<'TXT'

Prêt :

    MANIFEST=tickets/manifest-rattrapage.tsv ./run.sh

Trois tickets, compte 30 à 45 minutes.
TXT
