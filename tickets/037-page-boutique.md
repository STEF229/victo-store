TICKET 037 — page boutique

Crée `src/app/boutique/page.tsx`, export nommé `BoutiquePage`, plus
`export default BoutiquePage;` en fin de fichier (Next.js exige un export par
défaut pour une route ; c'est la seule exception à la règle des exports nommés).

C'est la première vraie page de la boutique : catalogue filtrable, triable et
paginé.

## Règles absolues
- TypeScript strict. Ne modifie aucun test, ne crée aucun autre fichier.
- Couleurs via les tokens `var(--vs-*)`. Cobalt pour les actions, rouge promo
  réservé aux remises.
- **Aucun fichier baril n'existe** : n'importe jamais depuis un dossier.
- Les `data-testid` sont un contrat testé.

## Bloc d'imports exact

Recopie ce bloc tel quel, sans rien y ajouter ni retirer.

```tsx
'use client';

import { useMemo, useState } from 'react';
import { FiltresPanneau } from '@/components/catalogue/FiltresPanneau';
import { GrilleProduits } from '@/components/catalogue/GrilleProduits';
import { Pagination } from '@/components/catalogue/Pagination';
import { TriSelect } from '@/components/catalogue/TriSelect';
import { SiteFooter } from '@/components/ui/SiteFooter';
import { SiteHeader } from '@/components/ui/SiteHeader';
import { Container, Heading, Section, Text } from '@/components/ui/layout';
import { listerMarques, listerProduits, taillesCatalogue } from '@/lib/donnees';
import { filtrerProduits, paginer, trierProduits, type Criteres, type Tri } from '@/lib/filtres';
```

## État
Trois états, et trois seulement :
```ts
const [criteres, setCriteres] = useState<Criteres>({});
const [tri, setTri] = useState<Tri>('nouveautes');
const [page, setPage] = useState(1);
```

## Chaîne de traitement
Dans un `useMemo` dépendant de `criteres` et `tri` : filtrer, puis trier.
Puis paginer le résultat avec **6 produits par page**.

Changer un filtre ou le tri **remet la page à 1**. C'est essentiel : sinon
l'utilisateur se retrouve sur une page vide après avoir filtré.

## Contrat de rendu
- `<SiteHeader>` en haut, trois entrées (`Femme` `/femme`, `Homme` `/homme`,
  `Soldes` `/soldes`), `cartCount={0}`.
- `<Heading level={1}>` dont le texte est exactement `Boutique`.
- `<p data-testid="compteur">` au format exact `12 produits` — le nombre de
  produits **après filtrage**, avant pagination. Au singulier : `1 produit`.
  Zéro donne `0 produit`.
- `<FiltresPanneau>` alimenté par `listerMarques()` et `taillesCatalogue()`.
- `<TriSelect>` relié à l'état `tri`.
- `<GrilleProduits>` alimenté par la page courante.
- `<Pagination>` relié à `page` et au nombre de pages.
- `<SiteFooter>` en bas, avec deux colonnes au choix et `annee={2026}`.

## Mise en page
Filtres en colonne à gauche sur grand écran, empilés au-dessus de la grille sur
mobile. Le tri et le compteur sur une même ligne au-dessus de la grille.

## Critère de fin
`npm run typecheck` et `npm test` passent.
