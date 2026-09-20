TICKET 010 — tokens de marque VICTO STORE

Crée `src/lib/tokens.ts`. C'est la **source unique de vérité** des couleurs et de
la typographie. Le fichier CSS sera généré à partir de lui, pas écrit à la main.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` activé.
- **Exports nommés** uniquement, jamais `export default`.
- Aucune dépendance : ce fichier n'importe rien.
- **Ne modifie aucun fichier de test.**
- Ne crée et ne modifie aucun autre fichier.

## À exporter

### `TOKENS`
Un objet constant, figé par `as const`, avec **exactement** ces clés et valeurs,
hexadécimaux en majuscules :

```ts
export const TOKENS = {
  '--vs-noir': '#101014',
  '--vs-blanc': '#FFFFFF',
  '--vs-surface': '#F5F5F3',
  '--vs-ligne': '#E5E5E1',
  '--vs-gris': '#6B6B70',
  '--vs-accent': '#0B41CD',
  '--vs-accent-fonce': '#082F94',
  '--vs-promo': '#E4002B',
  '--vs-font-display': "'Archivo', system-ui, sans-serif",
  '--vs-maxw': '1220px',
  '--vs-radius': '6px',
} as const;
```

Rôles, pour ta compréhension : noir pour le texte et la structure, blanc pour le
fond, surface pour les cartes, ligne pour les bordures, gris pour le texte
secondaire et les prix barrés, accent cobalt pour les boutons d'action et les
liens de marque, accent foncé pour le survol, et **promo** — le seul rouge de la
charte — réservé aux prix remisés et aux badges de remise. Le rouge ne doit
jamais servir à autre chose : c'est ce qui lui garde son pouvoir de signal.

### `cssTokens(): string`
Retourne un bloc CSS complet et valide, de la forme :

```
:root {
  --vs-noir: #101014;
  ...
}
```

Une déclaration par ligne, dans l'ordre des clés de `TOKENS`, indentée de deux
espaces, chaque ligne terminée par un point-virgule. La chaîne commence par
`:root {` et se termine par `}`.

La fonction **dérive** son résultat de `TOKENS` : ne recopie pas les valeurs en
dur dans la chaîne. Si une valeur change dans `TOKENS`, le CSS doit suivre.

## Interdit strict
Aucune trace de l'ancienne marque OUTREMER : ni `--klein`, ni `--paper`, ni
`--bone`, ni `--midnight`, ni `Fraunces`, ni `Bricolage`, ni les bleus `#1F2EC8`
et `#18239A`.

## Critère de fin
`npm run typecheck` et `npm test` passent.
