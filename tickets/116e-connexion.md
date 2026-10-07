TICKET 116e — la connexion attend la réponse de Medusa

Modifie `src/app/connexion/page.tsx`. La connexion fonctionne avec un résultat immédiat (démonstration) comme asynchrone (Medusa), grâce à `quand`. Le compte de démonstration n'est rappelé qu'en mode démonstration.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Fais **exactement** les remplacements ci-dessous, rien d'autre. Chaque « avant » est recopié tel qu'il est
  dans le fichier ; quand un « après » a plus de lignes que son « avant », **écris toutes ses lignes**.

## Remplacement 1 — la ligne d'import de la navigation reste, et **deux lignes d'import s'ajoutent juste dessous**
Avant :
```tsx
import { COLONNES_PIED, NAV } from '@/lib/navigation';
```
Après :
```tsx
import { COLONNES_PIED, NAV } from '@/lib/navigation';
import { quand } from '@/lib/quand';
import { useCatalogue } from '@/components/catalogue/CatalogueProvider';
```

## Remplacement 2 — **une ligne s'ajoute** entre `const session` et `const router`, qui restent
Avant :
```tsx
  const session = useSession();
  const router = useRouter();
```
Après :
```tsx
  const session = useSession();
  const demo = useCatalogue().source !== 'medusa';
  const router = useRouter();
```

## Remplacement 3 — la connexion passe par `quand`
Avant :
```tsx
    if (session.connecter(courriel, motDePasse)) {
      setErreur(false);
      router.push('/compte');
    } else {
      setErreur(true);
    }
```
Après :
```tsx
    quand(session.connexion(courriel, motDePasse), (ok) => {
      if (ok) {
        setErreur(false);
        router.push('/compte');
      } else {
        setErreur(true);
      }
    });
```

## Remplacement 4 — le compte de démonstration ne s'affiche qu'en démonstration
Avant :
```tsx
            <p data-testid="connexion-demo" className="rounded-2xl bg-[var(--vs-surface)] p-4 text-sm text-[var(--vs-noir)]">
              {`Compte de démonstration : ${COURRIEL_DEMO} — mot de passe ${MOT_DE_PASSE_DEMO}`}
            </p>
```
Après :
```tsx
            {demo && (
              <p data-testid="connexion-demo" className="rounded-2xl bg-[var(--vs-surface)] p-4 text-sm text-[var(--vs-noir)]">
                {`Compte de démonstration : ${COURRIEL_DEMO} — mot de passe ${MOT_DE_PASSE_DEMO}`}
              </p>
            )}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont les anciens tests de la session et des pages du compte.
