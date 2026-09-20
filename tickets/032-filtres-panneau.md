TICKET 032 — panneau de filtres

Crée `src/components/catalogue/FiltresPanneau.tsx`, export `FiltresPanneau`.

## Règles absolues
- TypeScript strict. Exports **nommés**. Ne modifie aucun test, ne crée aucun
  autre fichier.
- Couleurs via les tokens `var(--vs-*)` uniquement. Cobalt `--vs-accent` pour les
  actions, rouge `--vs-promo` réservé aux remises.
- **Aucun fichier baril nexiste** : nimporte jamais depuis un dossier.
- Les `data-testid` sont un contrat testé ; les classes Tailwind sont libres.

## Bloc d'imports exact
```tsx
'use client';

import type { Marque } from '@/lib/catalogue';
import type { Criteres } from '@/lib/filtres';
```

## Props
```ts
{ marques: Marque[]; tailles: string[]; criteres: Criteres;
  onChange: (criteres: Criteres) => void; className?: string }
```

## Contrat
- Racine `<aside data-testid="filtres">`.
- Groupe marques : `<fieldset>` avec `<legend>Marques</legend>`, une case à
  cocher par marque, libellé = `marque.nom`, attribut
  `data-testid={\`filtre-marque-${marque.slug}\`}`, cochée si le slug est dans
  `criteres.marques`.
- Groupe tailles : `<fieldset>` avec `<legend>Tailles</legend>`, une case par
  taille, libellé = la taille, `data-testid={\`filtre-taille-${taille}\`}`.
- `<input type="checkbox" data-testid="filtre-promo">` libellé
  `Promotions seulement`, reflétant `criteres.promotionSeulement`.
- `<input type="checkbox" data-testid="filtre-stock">` libellé
  `En stock seulement`, reflétant `criteres.enStockSeulement`.
- `<button type="button" data-testid="filtres-reinitialiser">Réinitialiser</button>`
  qui appelle `onChange({})`.

## Comportement
Cocher ajoute la valeur au tableau correspondant, décocher la retire. Le
composant est **contrôlé** : il ne garde aucun état, il appelle `onChange` avec
un **nouvel** objet `Criteres` complet, sans muter celui reçu. Un tableau qui
devient vide est transmis vide, pas supprimé.

## Critère de fin
`npm run typecheck` et `npm test` passent.
