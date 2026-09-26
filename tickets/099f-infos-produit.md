TICKET 099f — réassurance et sections repliables

Crée `src/components/produit/InfosProduit.tsx`, export nommé `InfosProduit`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index ;
  utilise `.filter` et `.map`.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Chaque `className` est écrit exactement comme ci-dessous. Aucun `<h1>`.
- Icônes `lucide-react` avec `aria-hidden`. Apostrophes droites (`'`) dans les textes.

## Bloc d'imports exact
```tsx
'use client';

import { ChevronDown, RotateCcw, ShieldCheck, Truck } from 'lucide-react';
import { useState } from 'react';
import type { Produit } from '@/lib/catalogue';
import { TEXTE_LIVRAISON } from '@/lib/fiche-produit';
```

## Logique
Taille attendue : ~65 lignes.

`export function InfosProduit({ produit }: { produit: Produit })`, avec :
```tsx
const sections = [
  { titre: 'Description', texte: produit.description ?? '' },
  { titre: 'Détails et composition', texte: produit.composition ?? '' },
  { titre: 'Livraison et retours', texte: TEXTE_LIVRAISON },
].filter((s) => s.texte !== '');
const [ouverts, setOuverts] = useState<number[]>([0]);
```
`basculer(i)` : `setOuverts((o) => (o.includes(i) ? o.filter((x) => x !== i) : [...o, i]))`.
La première section affichée est donc ouverte au départ, les autres fermées.

## Rendu
Racine : `<div data-testid="infos-produit" className="flex flex-col gap-[22px]">`.

**1. Réassurance** :
```tsx
<ul className="flex flex-col gap-3.5 rounded-[20px] bg-[var(--vs-surface)] p-5">
  <li className="flex items-center gap-3 text-sm"><Truck aria-hidden size={18} /><span><strong>Livraison offerte</strong> — reçue d'ici 2 à 4 jours ouvrables</span></li>
  <li className="flex items-center gap-3 text-sm"><RotateCcw aria-hidden size={18} /><span><strong>Retours gratuits</strong> pendant 30 jours</span></li>
  <li className="flex items-center gap-3 text-sm"><ShieldCheck aria-hidden size={18} /><span><strong>Authenticité garantie</strong>, neuf en boîte d'origine</span></li>
</ul>
```

**2. Sections** — `<div className="border-t border-[var(--vs-ligne)]">` contenant,
pour chaque section `s` de rang `i` (`sections.map((s, i) => ...)`, `key={s.titre}`),
avec `const ouvert = ouverts.includes(i);` :
```tsx
<div className="border-b border-[var(--vs-ligne)]">
  <button type="button" aria-expanded={ouvert} onClick={() => basculer(i)}
    className="flex h-16 w-full items-center justify-between text-left text-base font-extrabold text-[var(--vs-noir)]">
    {s.titre}
    <ChevronDown aria-hidden size={18} className={ouvert ? 'rotate-180' : undefined} />
  </button>
  {ouvert && <p className="mb-5 text-[15px] leading-relaxed text-[var(--vs-gris)]">{s.texte}</p>}
</div>
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
