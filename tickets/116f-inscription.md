TICKET 116f — l’inscription attend la réponse de Medusa

Modifie `src/app/inscription/page.tsx`. L'inscription fonctionne avec un résultat immédiat (démonstration) comme asynchrone (Medusa) ; si Medusa refuse, la page l'indique sous le courriel.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre. Chaque « avant » est recopié tel qu'il est
  dans le fichier ; quand un « après » a plus de lignes que son « avant », **écris toutes ses lignes**.

## Remplacement 1 — **une ligne d'import s'ajoute** sous celle de la navigation
Avant :
```tsx
import { COLONNES_PIED, NAV } from '@/lib/navigation';
```
Après :
```tsx
import { COLONNES_PIED, NAV } from '@/lib/navigation';
import { quand } from '@/lib/quand';
```

## Remplacement 2 — l'inscription passe par `quand`, et un refus s'affiche
Avant :
```tsx
      session.inscrire(donnees);
      router.push('/compte');
```
Après :
```tsx
      quand(session.inscription(donnees), (c) => {
        if (c) router.push('/compte');
        else setErreurs({ courriel: 'Inscription impossible : ce courriel a peut-être déjà un compte.' });
      });
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont les anciens tests de la session et des pages du compte.
