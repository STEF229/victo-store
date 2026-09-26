TICKET 099d — choix de la pointure

Crée `src/components/produit/SelecteurPointure.tsx`, export nommé `SelecteurPointure`.
Composant **sans état** : la pointure choisie vient des props.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index ;
  utilise `.map`.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Chaque `className` est écrit exactement comme ci-dessous. Aucun `<h1>`.

## Bloc d'imports exact
```tsx
import type { Variante } from '@/lib/catalogue';
```

## Props
Taille attendue : ~45 lignes.
```ts
interface SelecteurPointureProps {
  variantes: Variante[];
  valeur: string | null;
  onChoisir: (taille: string) => void;
}
```

## Rendu
```tsx
<div data-testid="selecteur-pointure" className="flex flex-col gap-3.5">
  <span id="libelle-pointure" className="text-[15px] font-extrabold text-[var(--vs-noir)]">
    Pointure{' '}
    <span data-testid="pointure-choisie" className="font-medium text-[var(--vs-gris)]">
      {valeur ?? '— à choisir'}
    </span>
  </span>
  <div role="group" aria-labelledby="libelle-pointure" className="grid grid-cols-3 gap-2.5 sm:grid-cols-6">
    {/* un bouton par variante */}
  </div>
</div>
```
Pour chaque variante `v` (avec `variantes.map((v) => ...)` et `key={v.id}`), avec
`const choisie = v.taille === valeur;` et `const epuisee = v.stock <= 0;`, un bouton
de contenu `{v.taille}` et d'attributs exactement :
```tsx
type="button"
aria-pressed={choisie}
disabled={epuisee}
onClick={() => onChoisir(v.taille)}
className={choisie
  ? 'h-14 rounded-[14px] border-[1.5px] text-base font-bold border-[var(--vs-noir)] bg-[var(--vs-noir)] text-[var(--vs-blanc)]'
  : epuisee
    ? 'h-14 rounded-[14px] border-[1.5px] text-base font-bold cursor-not-allowed border-[var(--vs-ligne)] bg-[var(--vs-blanc)] text-[#B5B5BA] line-through'
    : 'h-14 rounded-[14px] border-[1.5px] text-base font-bold border-[var(--vs-ligne)] bg-[var(--vs-blanc)] text-[var(--vs-noir)]'}
```
Un bouton désactivé ne déclenche pas `onClick` : aucune autre garde n'est à écrire.
Le commentaire du bloc de rendu indique seulement où placer les boutons : ne le
recopie pas.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
