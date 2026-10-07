TICKET 116g — les informations personnelles attendent la réponse de Medusa

Modifie `src/app/compte/informations/page.tsx`. Le profil et le mot de passe fonctionnent avec un résultat immédiat (démonstration) comme asynchrone (Medusa).

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre. Chaque « avant » est recopié tel qu'il est
  dans le fichier ; quand un « après » a plus de lignes que son « avant », **écris toutes ses lignes**.

## Remplacement 1 — **une ligne d'import s'ajoute** sous celle du type `Client`
Avant :
```tsx
import type { Client } from '@/lib/compte';
```
Après :
```tsx
import type { Client } from '@/lib/compte';
import { quand } from '@/lib/quand';
```

## Remplacement 2 — le profil passe par `quand`
Avant :
```tsx
    const erreurs = session.modifierProfil(profil);
    setErreursProfil(erreurs);
    setProfilEnregistre(Object.keys(erreurs).length === 0);
```
Après :
```tsx
    quand(session.enregistrerProfil(profil), (erreurs) => {
      setErreursProfil(erreurs);
      setProfilEnregistre(Object.keys(erreurs).length === 0);
    });
```

## Remplacement 3 — le mot de passe passe par `quand`
Avant :
```tsx
    const erreurs = session.changerMotDePasse(actuel, nouveau);
    setErreursMdp(erreurs);
    const ok = Object.keys(erreurs).length === 0;
    setMdpChange(ok);
    if (ok) {
      setActuel('');
      setNouveau('');
    }
```
Après :
```tsx
    quand(session.enregistrerMotDePasse(actuel, nouveau), (erreurs) => {
      setErreursMdp(erreurs);
      const ok = Object.keys(erreurs).length === 0;
      setMdpChange(ok);
      if (ok) {
        setActuel('');
        setNouveau('');
      }
    });
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont les anciens tests de la session et des pages du compte.
