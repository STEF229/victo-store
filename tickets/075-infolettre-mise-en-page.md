TICKET 075 — Infolettre : marges et disposition

Modifie `src/components/accueil/Infolettre.tsx`. Le bandeau actuel n'a aucune
marge intérieure : le titre touche le bord, le champ occupe toute la hauteur et le
message d'erreur s'affiche à droite du bouton au lieu d'en dessous.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif. Exports **nommés**.
- **Ne modifie aucun fichier de test.** Ne modifie aucun autre fichier que celui du ticket.
- **Aucun fichier baril n'existe** : n'importe jamais depuis un dossier.
- **Icônes : uniquement `lucide-react`.** Plus aucun `<svg>` dessiné à la main dans
  ce composant. Chaque icône reçoit `aria-hidden` et une taille explicite
  (`size={20}` par exemple). Importe **exactement** les noms indiqués, ils ont été
  vérifiés sur ta version installée.
- **Aucun `<h1>`** dans un composant, sauf le carrousel qui porte le titre de la page.
- Classes imposées en toutes lettres ; les tests les vérifient. Tu peux en
  ajouter, jamais en retirer.
- **Les tests existants de ce composant doivent rester verts** : tu modifies un
  composant déjà en production, tu ne le réécris pas de zéro.
## Classes imposées

| élément | classes à porter |
|---|---|
| le bloc cobalt (celui qui porte déjà `rounded-[28px]`) | ajouter `p-8 sm:p-12 lg:p-16` |
| le `<h2>` | `text-3xl font-black tracking-tight lg:text-4xl` |
| le `<p>` sous le titre | `mt-3 text-base text-[var(--vs-blanc)]/80` |
| le `<form>` | garder `flex flex-col gap-3 sm:flex-row`, ajouter `sm:items-center` |
| l'`<input>` | `h-14 w-full min-w-0 flex-1 rounded-full bg-[var(--vs-blanc)] px-6 text-[var(--vs-noir)]` |
| le `<button>` | `h-14 shrink-0 whitespace-nowrap rounded-full bg-[var(--vs-noir)] px-8 font-bold text-[var(--vs-blanc)]` |

## Structure de la colonne de droite
Le formulaire et le message d'erreur sont enveloppés ensemble, l'erreur **sous**
le formulaire et **hors** de lui :
```tsx
<div className="flex flex-col gap-3">
  <form …>…</form>
  {erreur && <p role="alert" className="text-sm font-semibold">Entrez une adresse courriel valide.</p>}
</div>
```
Après une inscription réussie, ce bloc est remplacé par le message de remerciement,
comme aujourd'hui. Les textes ne changent pas.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
