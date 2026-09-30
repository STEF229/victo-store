import type { Marque, Produit } from '@/lib/catalogue';

/** Minuscules, sans accents, ponctuation remplacée par des espaces. */
export function normaliser(texte: string): string {
  return texte
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, ' ')
    .trim();
}

export function motsDe(texte: string): string[] {
  return normaliser(texte).split(' ').filter((m) => m !== '');
}

function texteDe(p: Produit): string {
  return normaliser([p.nom, p.marque.nom, p.description ?? '', p.categorie ?? '', p.genre ?? ''].join(' '));
}

function score(p: Produit, mots: string[]): number {
  const texte = texteDe(p);
  if (!mots.every((m) => texte.includes(m))) return 0;
  const nom = normaliser(p.nom);
  const marque = normaliser(p.marque.nom);
  return 1 + (mots.every((m) => nom.includes(m)) ? 2 : 0) + (mots.some((m) => marque.includes(m)) ? 1 : 0);
}

/** Tous les mots doivent se retrouver dans le produit ; les plus pertinents d'abord, l'ordre du catalogue ensuite. */
export function rechercherProduits(produits: Produit[], terme: string): Produit[] {
  const mots = motsDe(terme);
  if (mots.length === 0) return [];
  return produits
    .map((p, rang) => ({ p, rang, s: score(p, mots) }))
    .filter((x) => x.s > 0)
    .sort((a, b) => b.s - a.s || a.rang - b.rang)
    .map((x) => x.p);
}

/** Les marques dont un mot du nom commence par un mot cherché. */
export function marquesCorrespondantes(marques: Marque[], terme: string): Marque[] {
  const mots = motsDe(terme);
  if (mots.length === 0) return [];
  return marques.filter((ma) => motsDe(ma.nom).some((x) => mots.some((m) => x.startsWith(m))));
}

export function libelleResultats(n: number): string {
  return `${n} ${n > 1 ? 'résultats' : 'résultat'}`;
}
