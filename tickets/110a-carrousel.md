TICKET 110a — le carrousel de l'accueil, compact sur téléphone et à faire glisser

Modifie `src/components/accueil/Carrousel.tsx`. Sur téléphone : marges intérieures, titre de 30 px, description et image masquées, boutons de 44 px, flèches masquées ; on change de diapositive en glissant le doigt (plus de 40 px).

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre : chaque texte « avant » est
  recopié tel qu'il est dans le fichier. Les classes d'origine restent toutes ; on en ajoute.

## Remplacement 1 (l'occurrence unique)
Avant :
```tsx
import { useEffect, useState } from 'react';
```
Après :
```tsx
import { useEffect, useRef, useState } from 'react';
```

## Remplacement 2 (l'occurrence unique)
Avant :
```tsx
  const [index, setIndex] = useState(0);
```
Après :
```tsx
  const [index, setIndex] = useState(0);
  const debutGlisse = useRef<number | null>(null);
```

## Remplacement 3 (l'occurrence unique)
Avant :
```tsx
      className="relative overflow-hidden"
    >
```
Après :
```tsx
      className="relative overflow-hidden"
      onTouchStart={(e) => { debutGlisse.current = e.touches[0]?.clientX ?? null; }}
      onTouchEnd={(e) => {
        const fin = e.changedTouches[0]?.clientX;
        if (debutGlisse.current !== null && fin !== undefined) {
          const ecart = fin - debutGlisse.current;
          if (ecart < -40) allerSuivant();
          else if (ecart > 40) allerPrecedent();
        }
        debutGlisse.current = null;
      }}
    >
```

## Remplacement 4 (l'occurrence unique)
Avant :
```tsx
className="grid grid-cols-1 items-center gap-10 lg:grid-cols-2"
```
Après :
```tsx
className="grid grid-cols-1 items-center gap-10 lg:grid-cols-2 max-sm:gap-0 max-sm:px-5 max-sm:pb-14 max-sm:pt-7"
```

## Remplacement 5 (chacune des **deux** occurrences)
Avant :
```tsx
className="text-5xl font-black tracking-tight lg:text-7xl"
```
Après :
```tsx
className="text-5xl font-black tracking-tight lg:text-7xl max-sm:mt-2 max-sm:text-[30px] max-sm:leading-[1.05]"
```

## Remplacement 6 (l'occurrence unique)
Avant :
```tsx
className="mt-4 text-lg"
```
Après :
```tsx
className="mt-4 text-lg max-sm:hidden"
```

## Remplacement 7 (l'occurrence unique)
Avant :
```tsx
className="mt-8 flex flex-wrap gap-4"
```
Après :
```tsx
className="mt-8 flex flex-wrap gap-4 max-sm:mt-5 max-sm:gap-3"
```

## Remplacement 8 (l'occurrence unique)
Avant :
```tsx
className={`rounded-full h-14 px-6 flex items-center justify-center ${
```
Après :
```tsx
className={`rounded-full h-14 px-6 flex items-center justify-center font-bold max-sm:h-11 max-sm:px-5 max-sm:text-[15px] ${
```

## Remplacement 9 (l'occurrence unique)
Avant :
```tsx
              <div>
                <img src={diapo.image}
```
Après :
```tsx
              <div className="max-sm:hidden">
                <img src={diapo.image}
```

## Remplacement 10 (l'occurrence unique)
Avant :
```tsx
className="absolute left-4 top-1/2 -translate-y-1/2 rounded-full bg-[var(--vs-blanc)] p-3 shadow-lg"
```
Après :
```tsx
className="absolute left-4 top-1/2 -translate-y-1/2 rounded-full bg-[var(--vs-blanc)] p-3 shadow-lg max-sm:hidden"
```

## Remplacement 11 (l'occurrence unique)
Avant :
```tsx
className="absolute right-4 top-1/2 -translate-y-1/2 rounded-full bg-[var(--vs-blanc)] p-3 shadow-lg"
```
Après :
```tsx
className="absolute right-4 top-1/2 -translate-y-1/2 rounded-full bg-[var(--vs-blanc)] p-3 shadow-lg max-sm:hidden"
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
