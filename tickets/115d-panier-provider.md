TICKET 115d — en mode Medusa, le panier est recopié dans un panier Medusa

Modifie `src/components/panier/PanierProvider.tsx`. En mode Medusa (`useCatalogue().source === 'medusa'`), chaque changement du panier est recopié dans un panier Medusa par la passerelle ; son identifiant est gardé dans le navigateur et exposé (`panierMedusa`). En mode démonstration, et sans fournisseur de catalogue (les tests), rien ne change.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre. Chaque « avant » est recopié tel qu'il est
  dans le fichier ; quand un « après » a plus de lignes que son « avant », **écris toutes ses lignes**.

## Remplacement 1 — ajoute `useRef` à l'import de React
Avant :
```tsx
import { createContext, useContext, useEffect, useState, type ReactNode } from 'react';
```
Après :
```tsx
import { createContext, useContext, useEffect, useRef, useState, type ReactNode } from 'react';
```

## Remplacement 2 — la ligne `} from '@/lib/panier';` reste, et **deux lignes d'import s'ajoutent juste dessous** : écris les trois lignes
Avant :
```tsx
} from '@/lib/panier';
```
Après :
```tsx
} from '@/lib/panier';
import { useCatalogue } from '@/components/catalogue/CatalogueProvider';
import { CLE_PANIER_MEDUSA, synchroniserPanier } from '@/lib/medusa/panier-medusa';
```

## Remplacement 3 — le champ `panierMedusa` s'ajoute à l'interface, sous `vider`
Avant :
```tsx
  vider: () => void;
}
```
Après :
```tsx
  vider: () => void;
  /** Identifiant du panier Medusa recopié (mode Medusa), sinon null. */
  panierMedusa: string | null;
}
```

## Remplacement 4 — valeur par défaut du contexte : `panierMedusa: null`
Avant :
```tsx
  vider: () => {},
});
```
Après :
```tsx
  vider: () => {},
  panierMedusa: null,
});
```

## Remplacement 5 — la ligne `const [pret, setPret]…` reste, et **trois lignes s'ajoutent juste dessous**
Avant :
```tsx
  const [pret, setPret] = useState(false);
```
Après :
```tsx
  const [pret, setPret] = useState(false);
  const { source, produits } = useCatalogue();
  const [panierMedusa, setPanierMedusa] = useState<string | null>(null);
  const file = useRef<Promise<void>>(Promise.resolve());
```

## Remplacement 6 — **un nouvel effet s'ajoute juste au-dessus** de `const nombre = …`, qui reste
Avant :
```tsx
  const nombre = nombreArticles(lignes);
```
Après :
```tsx
  // Mode Medusa : chaque changement du panier est recopié dans un panier Medusa, une opération à la fois.
  useEffect(() => {
    if (!pret || source !== 'medusa') return;
    const voulu = lignes.flatMap((l) => {
      const variante = produits.find((p) => p.slug === l.slug)?.variantes.find((v) => v.sku === l.sku);
      return variante ? [{ variantId: variante.id, quantite: l.quantite }] : [];
    });
    file.current = file.current.then(async () => {
      try {
        let id: string | null = null;
        try { id = window.localStorage.getItem(CLE_PANIER_MEDUSA); } catch { id = null; }
        const nouveau = await synchroniserPanier(id, voulu);
        try { if (nouveau) window.localStorage.setItem(CLE_PANIER_MEDUSA, nouveau); } catch { /* stockage indisponible */ }
        setPanierMedusa(nouveau || null);
      } catch (erreur) {
        console.warn('[panier] recopie dans Medusa impossible', erreur);
      }
    });
  }, [lignes, pret, source, produits]);

  const nombre = nombreArticles(lignes);
```

## Remplacement 7 — la valeur transmise gagne `panierMedusa`
Avant :
```tsx
        setLignes([]);
      },
    }}>
```
Après :
```tsx
        setLignes([]);
      },
      panierMedusa,
    }}>
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont les tests `PanierProvider`, `panier-pret`, `VuePanier`.
