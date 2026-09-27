TICKET 102a — compte : types, données de démonstration, validations, totaux

Crée `src/lib/compte.ts`. Fonctions **pures** ; données de démonstration en
attendant Medusa (le vrai branchement ne changera que ce fichier).

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index
  (`tableau[i]`) ; utilise `.find`, `.filter`, `.reduce`.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier. Aucun import.
- Recopie les données de démonstration **exactement**.

## Types et données
Taille attendue : ~140 lignes.
```ts
export type StatutCommande = 'preparation' | 'expediee' | 'livree' | 'annulee';
export type FiltreCommandes = 'toutes' | 'en-cours' | 'livrees' | 'annulees';

export interface Adresse {
  id: string;
  libelle: string;
  nomComplet: string;
  ligne1: string;
  ville: string;
  province: string;
  codePostal: string;
  telephone: string;
  parDefaut: boolean;
}
export interface Client {
  prenom: string;
  nom: string;
  courriel: string;
  membreDepuis: string;
  adresses: Adresse[];
}
export interface LigneCommande {
  slug: string;
  nom: string;
  marque: string;
  taille: string;
  quantite: number;
  prixCents: number;
  economieCents: number;
}
export interface Commande {
  numero: string;
  date: string;
  statut: StatutCommande;
  lignes: LigneCommande[];
  adresseId: string;
  paiement: string;
  suivi: string | null;
}
export interface DonneesInscription {
  prenom: string;
  nom: string;
  courriel: string;
  motDePasse: string;
}
export type ErreursInscription = Partial<Record<keyof DonneesInscription, string>>;
export interface TotauxCommande {
  articles: number;
  sousTotalCents: number;
  economiesCents: number;
  tpsCents: number;
  tvqCents: number;
  totalCents: number;
}

export const COURRIEL_DEMO = 'camille.tremblay@exemple.ca';
export const MOT_DE_PASSE_DEMO = 'victo2026';

export const CLIENT_DEMO: Client = {
  prenom: 'Camille',
  nom: 'Tremblay',
  courriel: COURRIEL_DEMO,
  membreDepuis: '2026-03-12',
  adresses: [
    { id: 'domicile', libelle: 'Domicile', nomComplet: 'Camille Tremblay', ligne1: '4520, rue Saint-Denis, app. 3', ville: 'Montréal', province: 'QC', codePostal: 'H2J 2L3', telephone: '514 555-0142', parDefaut: true },
    { id: 'bureau', libelle: 'Bureau', nomComplet: 'Camille Tremblay', ligne1: '1000, rue De La Gauchetière O., 12e étage', ville: 'Montréal', province: 'QC', codePostal: 'H3B 4W5', telephone: '514 555-0188', parDefaut: false },
  ],
};

export const COMMANDES_DEMO: Commande[] = [
  {
    numero: 'VS-10482', date: '2026-09-24', statut: 'expediee', adresseId: 'domicile',
    paiement: 'Visa se terminant par 4242', suivi: '7302 1154 8890 4412',
    lignes: [
      { slug: 'air-zoom-pegasus-41', nom: 'Air Zoom Pegasus 41', marque: 'Nike', taille: '41', quantite: 1, prixCents: 12900, economieCents: 3000 },
      { slug: 'polo-shirt', nom: 'Polo Shirt', marque: 'Lacoste', taille: 'M', quantite: 1, prixCents: 5900, economieCents: 2000 },
      { slug: 'chuck-taylor-all-star', nom: 'Chuck Taylor All Star', marque: 'Converse', taille: '39', quantite: 1, prixCents: 8900, economieCents: 0 },
    ],
  },
  {
    numero: 'VS-10417', date: '2026-09-02', statut: 'livree', adresseId: 'domicile',
    paiement: 'Visa se terminant par 4242', suivi: '7302 1154 8871 0935',
    lignes: [
      { slug: 'ultra-boost-22', nom: 'Ultra Boost 22', marque: 'Adidas', taille: '42', quantite: 1, prixCents: 18900, economieCents: 3000 },
    ],
  },
  {
    numero: 'VS-10360', date: '2026-08-18', statut: 'livree', adresseId: 'bureau',
    paiement: 'Mastercard se terminant par 8210', suivi: '7302 1154 8702 3318',
    lignes: [
      { slug: 'chuck-taylor-all-star', nom: 'Chuck Taylor All Star', marque: 'Converse', taille: '38', quantite: 2, prixCents: 8900, economieCents: 0 },
    ],
  },
  {
    numero: 'VS-10291', date: '2026-07-30', statut: 'annulee', adresseId: 'domicile',
    paiement: 'Visa se terminant par 4242', suivi: null,
    lignes: [
      { slug: 'polo-shirt', nom: 'Polo Shirt', marque: 'Lacoste', taille: 'L', quantite: 1, prixCents: 5900, economieCents: 2000 },
    ],
  },
];
```

## Fonctions
```ts
export function courrielValide(courriel: string): boolean;
export function verifierConnexion(courriel: string, motDePasse: string): boolean;
export function validerInscription(donnees: DonneesInscription): ErreursInscription;
export function commandesDe(client: Client): Commande[];
export function filtrerCommandes(commandes: Commande[], filtre: FiltreCommandes): Commande[];
export function totauxCommande(commande: Commande): TotauxCommande;
export function formaterDate(iso: string): string;
export function formaterMois(iso: string): string;
export function libelleCommandes(n: number): string;
```
- **`courrielValide`** : `/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(courriel.trim())`.
- **`verifierConnexion`** : vrai si `courriel.trim().toLowerCase() === COURRIEL_DEMO`
  et `motDePasse === MOT_DE_PASSE_DEMO`.
- **`validerInscription`** : part d'un objet vide `const erreurs: ErreursInscription = {};`
  et ajoute, dans cet ordre, seulement les erreurs présentes :
  `prenom` vide après `.trim()` → `'Indiquez votre prénom.'` ;
  `nom` vide après `.trim()` → `'Indiquez votre nom.'` ;
  `!courrielValide(courriel)` → `'Indiquez un courriel valide.'` ;
  `motDePasse.length < 8 || !/\d/.test(motDePasse)` → `'Au moins 8 caractères, dont un chiffre.'`.
  Renvoie `erreurs` (objet vide si tout est bon).
- **`commandesDe`** : `COMMANDES_DEMO` si `client.courriel === COURRIEL_DEMO`, sinon `[]`.
- **`filtrerCommandes`** (nouveau tableau, ordre conservé) : `'toutes'` → toutes ;
  `'en-cours'` → statut `'preparation'` ou `'expediee'` ; `'livrees'` → `'livree'` ;
  `'annulees'` → `'annulee'`.
- **`totauxCommande`** : `articles` = somme des quantités ; `sousTotalCents` = somme
  de `prixCents * quantite` ; `economiesCents` = somme de `economieCents * quantite` ;
  `tpsCents = Math.round(sousTotalCents * 0.05)` ;
  `tvqCents = Math.round(sousTotalCents * 0.09975)` (taxes non composées) ;
  `totalCents = sousTotalCents + tpsCents + tvqCents`.
- **`formaterDate`** : `new Intl.DateTimeFormat('fr-CA', { day: 'numeric', month: 'long', year: 'numeric', timeZone: 'UTC' }).format(new Date(iso))`
  (donne par exemple `24 septembre 2026`).
- **`formaterMois`** : même chose avec `{ month: 'long', year: 'numeric', timeZone: 'UTC' }`
  (donne `mars 2026`).
- **`libelleCommandes`** renvoie exactement `` `${n} ${n > 1 ? 'commandes' : 'commande'}` ``.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
