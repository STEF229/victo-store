TICKET 099c — galerie de la fiche produit

Crée `src/components/produit/GalerieProduit.tsx`, export nommé `GalerieProduit`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index.
  L'image affichée se lit avec
  `const courante = images.find((_, i) => i === vue) ?? '';`.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Chaque `className` est écrit exactement comme ci-dessous. Aucun `<h1>`.
- Utilise une balise `<img>` ordinaire, pas `next/image`.

## Bloc d'imports exact
```tsx
'use client';

import { useState } from 'react';
```

## Props et état
Taille attendue : ~50 lignes.
```ts
interface GalerieProduitProps {
  images: string[];
  nom: string;
  remise: number | null;
}
```
État : `const [vue, setVue] = useState(0);` (rang de l'image affichée).

## Rendu
```tsx
<div data-testid="galerie" className="flex flex-col gap-4">
  <div className="relative flex aspect-square items-center justify-center overflow-hidden rounded-[28px] bg-[var(--vs-surface)] lg:aspect-auto lg:h-[680px]">
    {/* pastille de remise */}
    <img src={courante} alt={`${nom}, vue ${vue + 1}`} className="h-full w-full object-contain" />
  </div>
  {/* vignettes */}
</div>
```
**Pastille de remise**, seulement si `remise !== null` :
```tsx
<span data-testid="galerie-remise" className="absolute left-6 top-6 rounded-full bg-[var(--vs-promo)] px-[13px] py-[7px] text-sm font-extrabold text-[var(--vs-blanc)]">
  {`\u2212${remise}\u00a0%`}
</span>
```
**Vignettes**, seulement si `images.length > 1` :
`<div className="grid grid-cols-4 gap-4">` contenant, pour chaque image `src` de
rang `i` (avec `images.map((src, i) => ...)` et `key={src + i}`), un bouton avec
exactement ces attributs :
```tsx
type="button"
aria-label={`Afficher la vue ${i + 1}`}
aria-pressed={i === vue}
onClick={() => setVue(i)}
className={i === vue
  ? 'h-[110px] overflow-hidden rounded-[18px] border-2 border-[var(--vs-noir)] bg-[var(--vs-surface)]'
  : 'h-[110px] overflow-hidden rounded-[18px] border-2 border-transparent bg-[var(--vs-surface)]'}
```
et pour seul contenu `<img src={src} alt="" className="h-full w-full object-contain" />`.

Les deux commentaires du bloc de rendu indiquent seulement où placer ces
éléments : ne les recopie pas.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
