TICKET 099e — bloc d'achat de la fiche produit

Crée `src/components/produit/BlocAchat.tsx`, export nommé `BlocAchat`. Il affiche
le prix, la description, le choix de pointure, la quantité, et ajoute au panier.
Le titre `<h1>` n'est **pas** dans ce composant : la page le porte.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index.
  La variante choisie se lit toujours avec
  `produit.variantes.find((v) => v.taille === taille)`.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- **Aucun fichier baril n'existe.** Les déclarations des modules importés te sont
  fournies en lecture seule.
- Chaque `className` est écrit exactement comme ci-dessous. Aucun `<h1>`.
- Icônes `lucide-react` avec `aria-hidden`. Apostrophes droites (`'`) dans tous les textes.

## Bloc d'imports exact
```tsx
'use client';

import { Check, Heart } from 'lucide-react';
import { useState } from 'react';
import { usePanier } from '@/components/panier/PanierProvider';
import { SelecteurPointure } from '@/components/produit/SelecteurPointure';
import { economieCents, estEnPromotion, type Produit } from '@/lib/catalogue';
import { texteStockBas } from '@/lib/fiche-produit';
import { formatPrice } from '@/lib/formatPrice';
```

## Props, état, logique
Taille attendue : ~120 lignes.

`export function BlocAchat({ produit }: { produit: Produit })`, avec :
```tsx
const panier = usePanier();
const [taille, setTaille] = useState<string | null>(null);
const [quantite, setQuantite] = useState(1);
const [favori, setFavori] = useState(false);
const [erreur, setErreur] = useState(false);
const [confirme, setConfirme] = useState(false);
const promo = estEnPromotion(produit);
const choisie = produit.variantes.find((v) => v.taille === taille);
const plafond = choisie ? choisie.stock : 9;
const alerte = texteStockBas(produit, taille);
```
- **`choisir(t: string)`** (passée à `onChoisir`) : `setTaille(t)`, `setErreur(false)`,
  `setConfirme(false)`, puis, si la variante de pointure `t` existe (lue avec `.find`),
  `setQuantite((q) => Math.min(q, Math.max(1, variante.stock)))`.
- **Moins** : `setQuantite(Math.max(1, quantite - 1))`. **Plus** :
  `setQuantite(Math.min(plafond, quantite + 1))`.
- **`ajouter()`** : si `choisie` est indéfinie → `setErreur(true)`,
  `setConfirme(false)`, et rien d'autre. Sinon
  `panier.ajouter({ slug: produit.slug, sku: choisie.sku }, quantite, choisie.stock)`,
  puis `setErreur(false)` et `setConfirme(true)`.

## Rendu
Racine : `<div data-testid="bloc-achat" className="flex flex-col gap-[22px]">`, qui
contient dans l'ordre :

**1. Prix** — `<div className="flex flex-wrap items-baseline gap-3.5">` :
```tsx
<span data-testid="fiche-prix" className={promo
  ? 'text-[32px] font-black text-[var(--vs-promo)]'
  : 'text-[32px] font-black text-[var(--vs-noir)]'}>
  {formatPrice(produit.prixCents)}
</span>
```
puis, seulement si `promo` et `produit.prixCompareCents !== undefined` :
`<s data-testid="fiche-prix-barre" className="text-lg text-[var(--vs-gris)]">{formatPrice(produit.prixCompareCents)}</s>`,
puis, seulement si `promo` :
`<span data-testid="fiche-economie" className="rounded-full bg-[#FFD3DB] px-[11px] py-[5px] text-sm font-extrabold text-[var(--vs-promo)]">{`Économisez ${formatPrice(economieCents(produit))}`}</span>`.

**2. Description**, seulement si `produit.description` est défini :
`<p data-testid="fiche-description" className="text-base leading-relaxed text-[var(--vs-gris)]">{produit.description}</p>`.

**3. Séparateur** : `<div className="h-px bg-[var(--vs-ligne)]" />`.

**4. Pointure** : `<SelecteurPointure variantes={produit.variantes} valeur={taille} onChoisir={choisir} />`,
puis, seulement si `alerte !== null` :
`<p data-testid="stock-bas" className="text-sm font-bold text-[var(--vs-promo)]">{alerte}</p>`.

**5. Actions** — `<div className="flex flex-wrap items-stretch gap-3">`, avec dans
l'ordre la quantité, le bouton d'ajout, le favori :
```tsx
<div className="flex h-[58px] items-center rounded-full border-[1.5px] border-[var(--vs-ligne)]">
  <button type="button" aria-label="Diminuer la quantité" disabled={quantite <= 1} onClick={moins}
    className={quantite <= 1 ? 'h-14 w-[52px] text-[22px] text-[#B5B5BA]' : 'h-14 w-[52px] text-[22px] text-[var(--vs-noir)]'}>
    −
  </button>
  <span data-testid="quantite" aria-live="polite" className="min-w-7 text-center text-[17px] font-extrabold">{quantite}</span>
  <button type="button" aria-label="Augmenter la quantité" onClick={plus} className="h-14 w-[52px] text-[22px] text-[var(--vs-noir)]">
    +
  </button>
</div>
<button type="button" onClick={ajouter}
  className="order-last h-[58px] basis-full rounded-full bg-[var(--vs-accent)] text-[17px] font-extrabold text-[var(--vs-blanc)] sm:order-none sm:basis-auto sm:flex-1">
  Ajouter au panier
</button>
<button type="button" aria-label="Ajouter aux favoris" aria-pressed={favori} onClick={() => setFavori(!favori)}
  className="flex h-[58px] w-[58px] items-center justify-center rounded-full border-[1.5px] border-[var(--vs-ligne)] bg-[var(--vs-blanc)]">
  <Heart aria-hidden size={20} className={favori ? 'fill-[var(--vs-promo)] text-[var(--vs-promo)]' : 'text-[var(--vs-noir)]'} />
</button>
```
(`moins` et `plus` sont les deux fonctions décrites plus haut.)

**6. Erreur**, seulement si `erreur` :
`<p role="alert" className="text-sm font-bold text-[var(--vs-promo)]">Choisissez une pointure avant d'ajouter au panier.</p>`.

**7. Confirmation**, seulement si `confirme` :
```tsx
<p role="status" className="flex items-center gap-2 text-sm font-bold text-[var(--vs-accent)]">
  <Check aria-hidden size={18} />
  {`Ajouté au panier — pointure ${taille}, quantité ${quantite}`}
</p>
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
