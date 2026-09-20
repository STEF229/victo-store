# VICTO STORE — ce qui a cassé, et ce qui l'empêche maintenant

Onze problèmes ont fait échouer le premier build. Neuf venaient de ma
configuration ou de mes tests, deux du modèle. Chacun est désormais bloqué en
amont. Ce document existe pour qu'aucun ne revienne.

## Les erreurs de configuration (moi)

**`@types/node` absent, et `"types"` qui l'excluait.** Renseigner `types` dans
`tsconfig.json` restreint TypeScript à cette liste seule. Un test lisant un
fichier avec `node:fs` échouait, et le modèle ne pouvait rien y faire puisque
l'erreur pointait un fichier de test.
→ `@types/node` épinglé dans `package.json`, `"node"` en tête de `types`, et un
test fumigène qui lit `package.json` avec `node:fs`.

**`toHaveTextContent` normalise les espaces.** En JavaScript, `\s` englobe
l'espace insécable `U+00A0`. Le matcher transformait donc l'insécable du DOM en
espace ordinaire et rendait mes tests de prix impossibles à satisfaire, avec un
message où attendu et reçu paraissaient identiques.
→ Toute comparaison contenant un insécable passe par `.textContent).toBe(...)`.
Un contrôle automatique vérifie qu'aucune assertion ne mélange les deux.

**Alias `@/` non configuré.** Le modèle importe avec `@/components/...`, la
convention Next par défaut. Douze imports corrects qui ne résolvaient pas.
→ `paths` dans `tsconfig.json` **et** `resolve.alias` dans `vitest.config.ts`.
Les deux résolvent séparément, il faut les deux.

**`postcss.config.mjs` manquant.** Sans lui, Next compile la CSS sans jamais la
passer dans Tailwind. La page s'affiche en HTML brut et rien ne le signale : la
porte était verte, le site sans style.
→ Le fichier est écrit par l'installateur, et l'installation vérifie que la
feuille CSS produite par le build contient les tokens **et** des utilitaires.

**Le format CSS pour un livrable de modèle.** Aider en mode `whole` réécrit le
fichier entier ; sur `tokens.css` il a échoué six fois d'affilée alors que tous
les tickets TypeScript passaient.
→ Le ticket produit `src/lib/tokens.ts`, et `npm run tokens` génère le CSS.
Une seule source de vérité, dans le langage où le modèle est bon.

**Tests en attente placés dans `tests/`.** Un test dont le composant n'existe
pas encore fait échouer la porte de tous les autres tickets, y compris ceux
déjà corrects.
→ Les tests vivent dans `tickets/tests/` et le harnais les active au début du
ticket concerné. Ne les copie jamais à la main dans `tests/`.

**La porte ne construisait pas l'application.** Types et tests verts ne
garantissent pas qu'une page s'affiche.
→ `npm run build` est le troisième barreau de la porte. Un ticket qui casse le
rendu ne peut plus fusionner.

**Identité git absente sur un template LXC nu.** Aider commite lui-même.
→ Configurée par l'installateur.

**Fausse erreur d'hydratation.** LanguageTool injecte `data-lt-installed` dans
le `<html>` avant React.
→ `suppressHydrationWarning` sur la balise `html`.

## Les erreurs du modèle

**`image` au lieu de `imageUrl`**, et **`badge` passé en prop** au lieu d'être
dans l'objet produit. Deux fois le même mécanisme : il consommait un type qu'il
ne voyait pas et en devinait la forme.
→ Le manifeste a une cinquième colonne, `contexte_lecture_seule`. Chaque ticket
reçoit en `--read` les types et composants qu'il consomme. Un ticket qui
utilise `Produit` voit `catalogue.ts` ; `ProductCard` voit `Price` et `Badge`.

Sur quatorze tickets, c'est le seul mode d'échec réel du modèle. Il n'a jamais
inventé d'API quand il avait le fichier sous les yeux.

## Les statuts du harnais

| statut | sens | qui corrige |
|---|---|---|
| `VERT` | porte passée, fusionné | personne |
| `CALÉ` | 3 tentatives, porte rouge | lire le log, souvent le modèle |
| `TIMEOUT` | appel trop long | vérifier `ollama ps` |
| `TRICHE` | un fichier de test a bougé | resserrer la spec |
| `BLOQUÉ` | dépendance amont absente | corriger le ticket amont |
| `TEST_SUSPECT` | `tsc` n'accuse que des tests | **moi** — envoie le log |

`BLOQUÉ` et `TEST_SUSPECT` n'existaient pas au premier build. Ils ont coûté six
appels de modèle inutiles et trois diagnostics par échanges. Ils s'arrêtent
maintenant à la première tentative en nommant le responsable.

## Règles de travail

GitHub est la source de vérité. La LXC exécute, tu édites, elle tire. Plus de
transfert manuel après l'installation.

On ne lance jamais `git pull`, `git checkout` ou une édition pendant qu'un run
tourne : le harnais change de branche entre les tickets.

Les tests ne se modifient que dans `tickets/tests/`.

`tokens.css` ne s'écrit jamais à la main : `npm run tokens`.
