TICKET 095b — tiroirs mobiles des filtres et du tri

Crée `src/components/catalogue/TiroirsFiltres.tsx`, export nommé `TiroirsFiltres`.
C'est un composant **sans état** : il affiche le tiroir demandé et remonte chaque
action par une prop. La barre de filtres l'utilisera au ticket suivant.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- **Aucun fichier baril n'existe.** Les déclarations des modules de `components/`
  te sont fournies en lecture seule ; les types de `lib/` sont donnés plus bas.
- **Toutes les classes de couleur et de forme viennent des constantes importées.**
  N'écris aucun `var(--vs-…)` dans ce fichier. Seules classes écrites à la main
  autorisées : celles des trois conteneurs donnés plus bas.
- Icône : `X` de `lucide-react`, avec `aria-hidden`. **Aucun `<h1>`, `<h2>`, `<h3>`.**

## Bloc d'imports exact
```tsx
import { X } from 'lucide-react';
import {
  FERMER, OPTION_MARQUE, OPTION_TAILLE, OPTION_TRI, OPTIONS_TRI, PILULE, PILULE_OFF, PILULE_ON,
  TIROIR, TIROIR_ENTETE, TIROIR_FOND, TIROIR_SECTION, TIROIR_TITRE, VALIDER,
} from '@/components/catalogue/filtres-affichage';
import type { Marque } from '@/lib/catalogue';
import type { Criteres, Tri } from '@/lib/filtres';
```

## Types importés
Leurs déclarations ne te sont pas fournies ; voici ce dont tu as besoin :
```ts
// '@/lib/catalogue' — d'autres champs peuvent exister
interface Marque { id: string; nom: string; slug: string }
// '@/lib/filtres' — d'autres champs optionnels peuvent exister
interface Criteres { marques?: string[]; tailles?: string[]; promotionSeulement?: boolean; enStockSeulement?: boolean }
type Tri = 'nouveautes' | 'prix-croissant' | 'prix-decroissant' | 'remise';
```

## Props
```ts
export type VueTiroir = 'filtres' | 'tri' | null;

interface TiroirsFiltresProps {
  vue: VueTiroir;
  marques: Marque[];
  tailles: string[];
  criteres: Criteres;
  tri: Tri;
  onMarque: (slug: string) => void;
  onTaille: (taille: string) => void;
  onPromo: () => void;
  onStock: () => void;
  onTri: (tri: Tri) => void;
  onFermer: () => void;
}
```
`VueTiroir` est exporté.

## Rendu
Taille attendue : ~130 lignes.

Si `vue` vaut `null`, le composant renvoie `null`. Sinon il renvoie un fragment :
1. `<div data-testid="tiroir-fond" aria-hidden="true" className={TIROIR_FOND} onClick={onFermer} />`
2. puis le tiroir correspondant à `vue`.

**Règle d'état** — un bouton qui a un état reçoit sa constante de forme suivie de
`PILULE_ON` s'il est actif, `PILULE_OFF` sinon, et `aria-pressed` égal à ce même
booléen : `` className={`${FORME} ${actif ? PILULE_ON : PILULE_OFF}`} ``.

**Rangée de titre**, en tête de chaque tiroir :
`<div className={TIROIR_ENTETE}>` contenant `<p className={TIROIR_TITRE}>` (texte
`Filtrer` ou `Trier par`) puis
`<button type="button" aria-label="Fermer" className={FERMER} onClick={onFermer}>`
contenant `<X aria-hidden size={18} />`.

### `vue === 'filtres'`
`<div data-testid="tiroir-filtres" role="dialog" aria-label="Filtrer" className={TIROIR}>`
contenant, dans l'ordre :
- la rangée de titre `Filtrer` ;
- `<p className={TIROIR_SECTION}>Marques</p>` puis `<div className="mb-6 flex flex-wrap gap-2">` :
  un bouton par marque, `` data-testid={`filtre-marque-${marque.slug}`} ``, texte
  `marque.nom`, forme `OPTION_MARQUE`, actif si `criteres.marques` contient
  `marque.slug`, clic → `onMarque(marque.slug)` ;
- `<p className={TIROIR_SECTION}>Tailles</p>` puis `<div className="mb-6 grid grid-cols-5 gap-2">` :
  un bouton par taille, `` data-testid={`filtre-taille-${taille}`} ``, texte `taille`,
  forme `OPTION_TAILLE`, actif si `criteres.tailles` contient `taille`, clic →
  `onTaille(taille)` ;
- `<div className="mb-6 flex gap-2">` contenant deux boutons, avec exactement ces
  attributs :
  ```tsx
  data-testid="filtre-promo"
  aria-pressed={criteres.promotionSeulement === true}
  className={`${PILULE} flex-1 justify-center ${criteres.promotionSeulement === true ? PILULE_ON : PILULE_OFF}`}
  onClick={onPromo}
  ```
  texte `Promotions` ; puis
  ```tsx
  data-testid="filtre-stock"
  aria-pressed={criteres.enStockSeulement === true}
  className={`${PILULE} flex-1 justify-center ${criteres.enStockSeulement === true ? PILULE_ON : PILULE_OFF}`}
  onClick={onStock}
  ```
  texte `En stock`. Les trois dernières classes changent avec l'état : c'est ce qui
  noircit l'interrupteur actif ;
- `<button type="button" className={VALIDER} onClick={onFermer}>Appliquer les filtres</button>`.

### `vue === 'tri'`
`<div data-testid="tiroir-tri" role="dialog" aria-label="Trier" className={TIROIR}>`
contenant la rangée de titre `Trier par`, puis `<div className="flex flex-col gap-2.5">` :
un bouton par élément de `OPTIONS_TRI`, texte `option.libelle`, forme `OPTION_TRI`,
actif si `tri === option.valeur`. Au clic : `onTri(option.valeur)` puis `onFermer()`.

Tous les boutons ont `type="button"`. Les listes utilisent `.map` avec une `key`.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
