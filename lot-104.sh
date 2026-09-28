#!/usr/bin/env bash
# VICTO STORE — lot 104 : espace client, partie 3 — adresses et favoris.
#   104a lib/adresses.ts     104b session : mettreAJourAdresses     104c FormulaireAdresse
#   104d /compte/adresses    104e FavorisProvider                   104f layout (favoris autour du panier)
#   104g cœur de la fiche produit branché sur les favoris           104h /compte/favoris
# À l'installation, l'ancien test du bloc d'achat perd ses lignes sur le favori (état local,
# qui ne peut plus basculer sans fournisseur) : ce comportement passe dans le test du 104g.
# Usage :  cd ~/victo-store && bash lot-104.sh
set -euo pipefail
cd "${REPO:-$HOME/victo-store}"
ok()  { printf '  \033[32m✓\033[0m %s\n' "$*"; }
info(){ printf '  \033[33m!\033[0m %s\n' "$*"; }
mort(){ printf '  \033[31m✗\033[0m %s\n' "$*" >&2; exit 1; }
annuler(){ rm -f tests/zz-prevol-*; git reset -q --hard HEAD; git clean -fdq -- tests tickets; mort "$*  — rien n'a été modifié"; }

pgrep -f '(^|[ /])run\.sh( |$)' >/dev/null 2>&1 && mort "le harnais tourne encore"
modifies="$(git ls-files -m -- '*.tsbuildinfo')"
[ -z "$modifies" ] || git checkout -q -- $modifies
[ -z "$(git status --porcelain)" ] || mort "arbre sale : commit ou stash d'abord (git status)"
git checkout -q main
git pull -q --rebase=merges || mort "git pull a échoué : main diverge de GitHub, à régler avant le lot"
ok "main à jour ($(git rev-parse --short HEAD))"

# ------------------------------------------------------------ ce que les specs supposent (au plus juste)
fusionne(){ git log main -1 --format=%h --fixed-strings --grep="feat($1): fusionné" | grep -q .; }
for d in 102a 102b 102c 102f 102g 103a 103b; do fusionne "$d" || mort "$d n'est pas fusionné : le lot 104 s'appuie dessus"; done
SP=src/components/compte/SessionProvider.tsx; LY=src/app/layout.tsx; BA=src/components/produit/BlocAchat.tsx
grep -qF "import type { Client, DonneesInscription } from '@/lib/compte';" "$SP" || mort "$SP : l'import depuis @/lib/compte n'est pas celui attendu (spec 104b)"
grep -q "from '@/lib/comptes-locaux'" "$SP" && grep -q "changerMotDePasse" "$SP" || mort "$SP ne ressemble pas à la version du lot 103"
grep -q "mettreAJourAdresses" "$SP" && mort "$SP a déjà mettreAJourAdresses : lot déjà passé ?"
[ "$(grep -o '<PanierProvider>' "$LY" | wc -l)" = 1 ] && [ "$(grep -o '</PanierProvider>' "$LY" | wc -l)" = 1 ] || mort "$LY : la balise PanierProvider n'est pas unique"
grep -q "FavorisProvider" "$LY" && mort "$LY a déjà FavorisProvider : lot déjà passé ?"
grep -qF "const [favori, setFavori] = useState(false);" "$BA" && grep -qF "onClick={() => setFavori(!favori)}" "$BA" || mort "$BA : les lignes du favori ne sont pas celles de la spec 099e"
for f in src/lib/adresses.ts src/components/compte/FormulaireAdresse.tsx src/components/favoris src/app/compte/adresses src/app/compte/favoris; do
  [ ! -e "$f" ] || mort "$f existe déjà : lot déjà passé ?"; done
[ -f src/components/ui/ProductCard.tsx ] || mort "ProductCard absent"
grep -qE "export function trouverProduit" src/lib/donnees.ts || mort "trouverProduit absent de donnees.ts"
for j in noir blanc surface ligne gris accent promo; do grep -qE -- "--vs-$j\s*:" src/styles/tokens.css || mort "jeton --vs-$j absent"; done
manque="$(node -e "const l=require('lucide-react');console.log(['Plus','Heart'].filter(n=>!l[n]).join(' '))" 2>/dev/null || echo lucide-react)"
[ -z "$manque" ] || mort "icônes lucide absentes de ta version : $manque"
ok "session, layout, bloc d'achat et données conformes aux specs"

trap 'annuler "erreur inattendue à la ligne $LINENO du script"' ERR
mkdir -p tickets/tests
cat > 'tickets/104a-adresses.md' <<'__VICTO_FIN_0__'
TICKET 104a — adresses : validation et opérations

Crée `src/lib/adresses.ts`. Fonctions **pures** : aucune ne modifie ses arguments,
chacune renvoie un **nouveau** tableau.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index
  (`tableau[i]`) ; utilise `.find`, `.map`, `.filter`, `.some`.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Recopie chaque texte d'erreur exactement.

## Bloc d'imports exact
```ts
import type { Adresse } from '@/lib/compte';
```

## Contenu
Taille attendue : ~95 lignes.
```ts
export type DonneesAdresse = Omit<Adresse, 'id' | 'parDefaut'>;
export type ErreursAdresse = Partial<Record<keyof DonneesAdresse, string>>;

export const PROVINCES: { code: string; nom: string }[] = [
  { code: 'AB', nom: 'Alberta' },
  { code: 'BC', nom: 'Colombie-Britannique' },
  { code: 'MB', nom: 'Manitoba' },
  { code: 'NB', nom: 'Nouveau-Brunswick' },
  { code: 'NL', nom: 'Terre-Neuve-et-Labrador' },
  { code: 'NS', nom: 'Nouvelle-Écosse' },
  { code: 'NT', nom: 'Territoires du Nord-Ouest' },
  { code: 'NU', nom: 'Nunavut' },
  { code: 'ON', nom: 'Ontario' },
  { code: 'PE', nom: 'Île-du-Prince-Édouard' },
  { code: 'QC', nom: 'Québec' },
  { code: 'SK', nom: 'Saskatchewan' },
  { code: 'YT', nom: 'Yukon' },
];

export function adresseVide(nomComplet: string): DonneesAdresse {
  return { libelle: '', nomComplet, ligne1: '', ville: '', province: 'QC', codePostal: '', telephone: '' };
}

export function donneesDe(a: Adresse): DonneesAdresse {
  return { libelle: a.libelle, nomComplet: a.nomComplet, ligne1: a.ligne1, ville: a.ville, province: a.province, codePostal: a.codePostal, telephone: a.telephone };
}

export function normaliserCodePostal(codePostal: string): string {
  const c = codePostal.replace(/[\s-]/g, '').toUpperCase();
  return c.length === 6 ? `${c.slice(0, 3)} ${c.slice(3)}` : codePostal.trim().toUpperCase();
}

function nettoyer(d: DonneesAdresse): DonneesAdresse {
  return {
    libelle: d.libelle.trim(),
    nomComplet: d.nomComplet.trim(),
    ligne1: d.ligne1.trim(),
    ville: d.ville.trim(),
    province: d.province,
    codePostal: normaliserCodePostal(d.codePostal),
    telephone: d.telephone.trim(),
  };
}
```

## Fonctions à écrire
```ts
export function validerAdresse(d: DonneesAdresse): ErreursAdresse;
export function ajouterAdresse(adresses: Adresse[], id: string, d: DonneesAdresse): Adresse[];
export function modifierAdresse(adresses: Adresse[], id: string, d: DonneesAdresse): Adresse[];
export function supprimerAdresse(adresses: Adresse[], id: string): Adresse[];
export function definirParDefaut(adresses: Adresse[], id: string): Adresse[];
```
- **`validerAdresse`** : part de `const erreurs: ErreursAdresse = {};` et ajoute, dans
  cet ordre, seulement les erreurs présentes :
  `libelle` vide après `.trim()` → `'Donnez un nom à cette adresse.'` ;
  `nomComplet` vide après `.trim()` → `'Indiquez le nom du destinataire.'` ;
  `ligne1` vide après `.trim()` → `'Indiquez le numéro et la rue.'` ;
  `ville` vide après `.trim()` → `'Indiquez la ville.'` ;
  `!PROVINCES.some((p) => p.code === d.province)` → `'Choisissez une province.'` ;
  `!/^[A-Z]\d[A-Z] \d[A-Z]\d$/.test(normaliserCodePostal(d.codePostal))` → `'Code postal invalide (ex. H2J 2L3).'` ;
  `d.telephone.replace(/\D/g, '').length !== 10` → `'Indiquez un numéro à 10 chiffres.'`.
  Renvoie `erreurs`.
- **`ajouterAdresse`** : `[...adresses, { id, ...nettoyer(d), parDefaut: adresses.length === 0 }]`
  (la première adresse devient l'adresse par défaut).
- **`modifierAdresse`** : `adresses.map((a) => (a.id === id ? { ...a, ...nettoyer(d) } : a))`.
- **`supprimerAdresse`** — recopie exactement :
  ```ts
  const restantes = adresses.filter((a) => a.id !== id);
  if (restantes.length > 0 && !restantes.some((a) => a.parDefaut)) {
    return restantes.map((a, i) => ({ ...a, parDefaut: i === 0 }));
  }
  return restantes;
  ```
- **`definirParDefaut`** : `adresses.map((a) => ({ ...a, parDefaut: a.id === id }))`.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_0__
cat > 'tickets/104b-session-adresses.md' <<'__VICTO_FIN_1__'
TICKET 104b — la session enregistre les adresses

Modifie `src/components/compte/SessionProvider.tsx`. Le fichier actuel est correct
et testé : tu ajoutes **une** fonction au contexte, rien d'autre ne change.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index sur un
  tableau. Un compte se lit par sa clé, `comptes[cle]`, puis `if (compte)`.
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Aucune autre fonction, aucun autre effet ne change.

## Les quatre changements
1. Dans l'import depuis `'@/lib/compte'`, ajoute le type `Adresse` :
   `import type { Adresse, Client, DonneesInscription } from '@/lib/compte';`
2. Dans l'import depuis `'@/lib/comptes-locaux'`, ajoute `cleCourriel` à la liste.
3. Dans `interface ContexteSession`, ajoute, après `changerMotDePasse` :
   `mettreAJourAdresses: (adresses: Adresse[]) => void;`
   et, dans la **valeur par défaut** du contexte, `mettreAJourAdresses: () => {}`.
4. Dans `SessionProvider`, ajoute cette fonction, recopiée telle quelle, et passe-la
   dans la valeur du fournisseur avec les autres :
   ```ts
   function mettreAJourAdresses(adresses: Adresse[]) {
     if (client === null) return;
     const suivant: Client = { ...client, adresses };
     const cle = cleCourriel(client.courriel);
     const compte = comptes[cle];
     setClient(suivant);
     if (compte) setComptes({ ...comptes, [cle]: { client: suivant, motDePasse: compte.motDePasse } });
   }
   ```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont `tests/SessionProvider.test.tsx`
et `tests/session-comptes.test.tsx`.
__VICTO_FIN_1__
cat > 'tickets/104c-formulaire-adresse.md' <<'__VICTO_FIN_2__'
TICKET 104c — formulaire d'une adresse

Crée `src/components/compte/FormulaireAdresse.tsx`, export nommé `FormulaireAdresse`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index ;
  utilise `.map`.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Chaque `className` est écrit exactement comme ci-dessous. Aucun `<h1>`.

## Bloc d'imports exact
```tsx
'use client';

import { useState, type FormEvent } from 'react';
import {
  BOUTON_PRINCIPAL, BOUTON_SECONDAIRE, CARTE, CHAMP, CHAMP_ERREUR, CHAMP_LIBELLE, CHAMP_SAISIE, CHAMP_SAISIE_ERREUR,
} from '@/components/compte/compte-affichage';
import { PROVINCES, validerAdresse, type DonneesAdresse, type ErreursAdresse } from '@/lib/adresses';
```

## Un champ texte — fonction locale, non exportée, recopiée telle quelle
Taille attendue : ~105 lignes.
```tsx
function Champ(props: {
  id: keyof DonneesAdresse;
  libelle: string;
  auto: string;
  valeur: string;
  erreur: string | undefined;
  onChange: (valeur: string) => void;
}) {
  return (
    <div className={CHAMP}>
      <label htmlFor={`adresse-${props.id}`} className={CHAMP_LIBELLE}>{props.libelle}</label>
      <input id={`adresse-${props.id}`} type="text" autoComplete={props.auto} value={props.valeur}
        onChange={(e) => props.onChange(e.target.value)}
        aria-invalid={props.erreur ? true : undefined}
        aria-describedby={props.erreur ? `erreur-adresse-${props.id}` : undefined}
        className={props.erreur ? CHAMP_SAISIE_ERREUR : CHAMP_SAISIE} />
      {props.erreur && <p id={`erreur-adresse-${props.id}`} className={CHAMP_ERREUR}>{props.erreur}</p>}
    </div>
  );
}
```

## Le formulaire
```tsx
export function FormulaireAdresse({ initiales, titre, libelleBouton, onEnregistrer, onAnnuler }: {
  initiales: DonneesAdresse;
  titre: string;
  libelleBouton: string;
  onEnregistrer: (donnees: DonneesAdresse) => void;
  onAnnuler: () => void;
})
```
Contenu :
```tsx
const [donnees, setDonnees] = useState<DonneesAdresse>(initiales);
const [erreurs, setErreurs] = useState<ErreursAdresse>({});
const changer = (cle: keyof DonneesAdresse) => (valeur: string) => setDonnees({ ...donnees, [cle]: valeur });

function soumettre(e: FormEvent<HTMLFormElement>) {
  e.preventDefault();
  const trouvees = validerAdresse(donnees);
  setErreurs(trouvees);
  if (Object.keys(trouvees).length === 0) onEnregistrer(donnees);
}
```
Rendu :
```tsx
<form onSubmit={soumettre} noValidate aria-labelledby="titre-formulaire-adresse" className={`${CARTE} gap-5`}>
  <h2 id="titre-formulaire-adresse" className="text-lg font-extrabold text-[var(--vs-noir)]">{titre}</h2>
  <div className="grid gap-4 sm:grid-cols-2">
    <Champ id="libelle" libelle="Nom de l'adresse (ex. Domicile, Bureau)" auto="off" valeur={donnees.libelle} erreur={erreurs.libelle} onChange={changer('libelle')} />
    <Champ id="nomComplet" libelle="Destinataire" auto="name" valeur={donnees.nomComplet} erreur={erreurs.nomComplet} onChange={changer('nomComplet')} />
  </div>
  <Champ id="ligne1" libelle="Adresse" auto="address-line1" valeur={donnees.ligne1} erreur={erreurs.ligne1} onChange={changer('ligne1')} />
  <div className="grid gap-4 sm:grid-cols-3">
    <Champ id="ville" libelle="Ville" auto="address-level2" valeur={donnees.ville} erreur={erreurs.ville} onChange={changer('ville')} />
    <div className={CHAMP}>
      <label htmlFor="adresse-province" className={CHAMP_LIBELLE}>Province</label>
      <select id="adresse-province" value={donnees.province} onChange={(e) => changer('province')(e.target.value)}
        aria-invalid={erreurs.province ? true : undefined} className={erreurs.province ? CHAMP_SAISIE_ERREUR : CHAMP_SAISIE}>
        {PROVINCES.map((p) => <option key={p.code} value={p.code}>{p.nom}</option>)}
      </select>
      {erreurs.province && <p className={CHAMP_ERREUR}>{erreurs.province}</p>}
    </div>
    <Champ id="codePostal" libelle="Code postal" auto="postal-code" valeur={donnees.codePostal} erreur={erreurs.codePostal} onChange={changer('codePostal')} />
  </div>
  <Champ id="telephone" libelle="Téléphone" auto="tel" valeur={donnees.telephone} erreur={erreurs.telephone} onChange={changer('telephone')} />
  <div className="flex flex-col gap-3 sm:flex-row">
    <button type="submit" className={`${BOUTON_PRINCIPAL} sm:w-auto`}>{libelleBouton}</button>
    <button type="button" onClick={onAnnuler} className={`${BOUTON_SECONDAIRE} sm:w-auto`}>Annuler</button>
  </div>
</form>
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_2__
cat > 'tickets/104d-page-adresses.md' <<'__VICTO_FIN_3__'
TICKET 104d — mes adresses

Crée `src/app/compte/adresses/page.tsx`. Page **client** (`'use client'`), un seul
export : l'export par défaut `PageAdresses`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index ;
  utilise `.find`, `.map`.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Aucun export nommé. Chaque `className` est écrit exactement comme ci-dessous.
- Apostrophes droites dans les textes.

## Bloc d'imports exact
```tsx
'use client';

import { Plus } from 'lucide-react';
import { useState } from 'react';
import { CARTE, LIEN, SOUS_TITRE, TITRE_PAGE } from '@/components/compte/compte-affichage';
import { EspaceClient } from '@/components/compte/EspaceClient';
import { FormulaireAdresse } from '@/components/compte/FormulaireAdresse';
import { useSession } from '@/components/compte/SessionProvider';
import { FilAriane } from '@/components/produit/FilAriane';
import { SiteFooter } from '@/components/ui/SiteFooter';
import { SiteHeader } from '@/components/ui/SiteHeader';
import { adresseVide, ajouterAdresse, definirParDefaut, donneesDe, modifierAdresse, supprimerAdresse, type DonneesAdresse } from '@/lib/adresses';
import type { Client } from '@/lib/compte';
import { COLONNES_PIED, NAV } from '@/lib/navigation';
```

## Le contenu — fonction locale `Adresses({ client }: { client: Client })`
Taille attendue : ~120 lignes.
```tsx
const session = useSession();
const [edition, setEdition] = useState<string | null>(null);      // null, 'nouvelle' ou l'id modifié
const [aSupprimer, setASupprimer] = useState<string | null>(null);
const adresses = client.adresses;
const enCours = adresses.find((a) => a.id === edition);

function enregistrer(d: DonneesAdresse) {
  if (edition === null) return;
  session.mettreAJourAdresses(edition === 'nouvelle' ? ajouterAdresse(adresses, `adr-${Date.now()}`, d) : modifierAdresse(adresses, edition, d));
  setEdition(null);
}
function supprimer(id: string) {
  session.mettreAJourAdresses(supprimerAdresse(adresses, id));
  setASupprimer(null);
}
```
Rendu :
```tsx
<>
  <h1 className={TITRE_PAGE}>Mes adresses</h1>
  {edition !== null && (
    <FormulaireAdresse
      initiales={enCours ? donneesDe(enCours) : adresseVide(`${client.prenom} ${client.nom}`)}
      titre={enCours ? "Modifier l'adresse" : 'Nouvelle adresse'}
      libelleBouton="Enregistrer l'adresse"
      onEnregistrer={enregistrer}
      onAnnuler={() => setEdition(null)} />
  )}
  {adresses.length === 0 && edition === null && (
    <p data-testid="adresses-vides" className={SOUS_TITRE}>Aucune adresse enregistrée pour l'instant.</p>
  )}
  <div className="grid gap-5 sm:grid-cols-2">
    {adresses.map((a) => (
      <article key={a.id} data-testid={`adresse-${a.id}`} className={CARTE}>
        {a.parDefaut && (
          <span className="self-start rounded-full bg-[var(--vs-noir)] px-3 py-1 text-xs font-extrabold text-[var(--vs-blanc)]">Par défaut</span>
        )}
        <h2 className="text-[17px] font-extrabold text-[var(--vs-noir)]">{a.libelle}</h2>
        <p className="text-[15px] leading-relaxed">
          {a.nomComplet}<br />{a.ligne1}<br />{`${a.ville} (${a.province}) ${a.codePostal}`}<br />{a.telephone}
        </p>
        <div className="mt-auto flex flex-wrap gap-4">
          {aSupprimer === a.id ? (
            <>
              <button type="button" onClick={() => supprimer(a.id)} className="text-sm font-extrabold text-[var(--vs-promo)] underline">Confirmer la suppression</button>
              <button type="button" onClick={() => setASupprimer(null)} className={LIEN}>Annuler</button>
            </>
          ) : (
            <>
              <button type="button" onClick={() => setEdition(a.id)} className={LIEN}>Modifier</button>
              {!a.parDefaut && (
                <button type="button" onClick={() => session.mettreAJourAdresses(definirParDefaut(adresses, a.id))} className={LIEN}>Définir par défaut</button>
              )}
              <button type="button" onClick={() => setASupprimer(a.id)} className="text-sm font-semibold text-[var(--vs-gris)] underline">Supprimer</button>
            </>
          )}
        </div>
      </article>
    ))}
    {edition === null && (
      <button type="button" onClick={() => setEdition('nouvelle')}
        className="flex min-h-[220px] flex-col items-center justify-center gap-3 rounded-3xl border-2 border-dashed border-[var(--vs-ligne)] text-base font-extrabold text-[var(--vs-noir)]">
        <Plus aria-hidden size={22} />
        Ajouter une adresse
      </button>
    )}
  </div>
</>
```

## La page
```tsx
export default function PageAdresses() {
  const session = useSession();
  return (
    <>
      <SiteHeader navItems={NAV} />
      <main className="mx-auto w-full max-w-[1440px] px-5 pb-24 lg:px-20">
        <FilAriane items={[{ label: 'Accueil', href: '/' }, { label: 'Mon compte', href: '/compte' }, { label: 'Adresses' }]} />
        <EspaceClient actif="adresses">
          {session.client && <Adresses client={session.client} />}
        </EspaceClient>
      </main>
      <SiteFooter colonnes={COLONNES_PIED} />
    </>
  );
}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_3__
cat > 'tickets/104e-favoris.md' <<'__VICTO_FIN_4__'
TICKET 104e — favoris, gardés dans le navigateur

Crée `src/components/favoris/FavorisProvider.tsx`, avec les exports nommés
`CLE_FAVORIS`, `FavorisProvider` et `useFavoris`, et le type `ContexteFavoris`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index ;
  utilise `.includes`, `.filter`, `.every`.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Tout accès à `localStorage` est dans un `try { … } catch { }`.

## Bloc d'imports exact
```tsx
'use client';

import { createContext, useContext, useEffect, useState, type ReactNode } from 'react';
```

## Contrat
Taille attendue : ~55 lignes.
```ts
export const CLE_FAVORIS = 'victo-favoris';
export interface ContexteFavoris {
  favoris: string[];
  pret: boolean;
  estFavori: (slug: string) => boolean;
  basculer: (slug: string) => void;
}
```
**Valeur par défaut du contexte** (hors fournisseur) : `favoris: []`, `pret: true`,
`estFavori` renvoie `false`, `basculer` ne fait rien.

`export function useFavoris(): ContexteFavoris` renvoie `useContext(...)`.

`export function FavorisProvider({ children }: { children: ReactNode })` :
1. états `favoris` (`string[]`, `[]`) et `pret` (`false`) ;
2. **au montage** (effet `[]`), dans un `try` : lit `window.localStorage.getItem(CLE_FAVORIS)` ;
   si le texte existe, `const valeur: unknown = JSON.parse(texte);` puis, si
   `Array.isArray(valeur) && valeur.every((s) => typeof s === 'string')`,
   `setFavoris(valeur)` ; enfin, hors du `try`, `setPret(true)` ;
3. **quand `favoris` change**, seulement si `pret` (effet `[favoris, pret]`) :
   `setItem(CLE_FAVORIS, JSON.stringify(favoris))` ;
4. `estFavori(slug)` : `favoris.includes(slug)` ;
5. `basculer(slug)` :
   `setFavoris((f) => (f.includes(slug) ? f.filter((s) => s !== slug) : [...f, slug]))` ;
6. rend le fournisseur du contexte autour de `children`.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_4__
cat > 'tickets/104f-layout-favoris.md' <<'__VICTO_FIN_5__'
TICKET 104f — favoris autour de tout le site

Modifie `src/app/layout.tsx`. Trois changements, rien d'autre : ni les métadonnées,
ni `<head>`, ni les attributs de `<html>`, ni `SessionProvider` ne bougent.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Le fichier reste un composant serveur : **pas** de `'use client'`.

## Les trois changements
1. Ajoute, à la suite des imports existants :
   ```tsx
   import { FavorisProvider } from '@/components/favoris/FavorisProvider';
   ```
2. Remplace la balise ouvrante `<PanierProvider>` par `<FavorisProvider><PanierProvider>`.
3. Remplace la balise fermante `</PanierProvider>` par `</PanierProvider></FavorisProvider>`.

`FavorisProvider` enveloppe donc `PanierProvider`, qui enveloppe toujours
`SessionProvider` exactement comme aujourd'hui.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont `tests/layout-panier.test.ts`
et `tests/layout-session.test.ts`.
__VICTO_FIN_5__
cat > 'tickets/104g-bloc-achat-favoris.md' <<'__VICTO_FIN_6__'
TICKET 104g — le cœur de la fiche produit garde le favori

Modifie `src/components/produit/BlocAchat.tsx`. Le fichier actuel est correct et
testé : le favori, aujourd'hui un simple état local, passe par les favoris gardés.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.
- Aucune classe, aucun texte, aucun autre comportement ne change. `useState` reste
  importé : il sert encore à la taille, à la quantité, à l'erreur et à la confirmation.

## Les trois changements
1. Ajoute, à la suite des imports existants :
   `import { useFavoris } from '@/components/favoris/FavorisProvider';`
2. Remplace exactement la ligne `const [favori, setFavori] = useState(false);` par :
   ```tsx
   const favoris = useFavoris();
   const favori = favoris.estFavori(produit.slug);
   ```
3. Sur le bouton `aria-label="Ajouter aux favoris"`, remplace
   `onClick={() => setFavori(!favori)}` par `onClick={() => favoris.basculer(produit.slug)}`.
   Ses autres attributs et son icône ne changent pas.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent, dont `tests/BlocAchat.test.tsx`.
__VICTO_FIN_6__
cat > 'tickets/104h-page-favoris.md' <<'__VICTO_FIN_7__'
TICKET 104h — mes favoris

Crée `src/app/compte/favoris/page.tsx`. Page **client** (`'use client'`), un seul
export : l'export par défaut `PageFavoris`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index. Les
  produits se retrouvent **exactement** ainsi (un favori dont le produit n'existe
  plus est ignoré) :
  ```tsx
  const produits = favoris.favoris.flatMap((slug) => {
    const p = trouverProduit(slug);
    return p ? [p] : [];
  });
  ```
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Aucun export nommé. Chaque `className` est écrit exactement comme ci-dessous.
- Apostrophes droites dans les textes.

## Bloc d'imports exact
```tsx
'use client';

import Link from 'next/link';
import { BOUTON_PRINCIPAL, LIEN, SOUS_TITRE, TITRE_PAGE } from '@/components/compte/compte-affichage';
import { EspaceClient } from '@/components/compte/EspaceClient';
import { useSession } from '@/components/compte/SessionProvider';
import { useFavoris } from '@/components/favoris/FavorisProvider';
import { FilAriane } from '@/components/produit/FilAriane';
import { ProductCard } from '@/components/ui/ProductCard';
import { SiteFooter } from '@/components/ui/SiteFooter';
import { SiteHeader } from '@/components/ui/SiteHeader';
import { trouverProduit } from '@/lib/donnees';
import { COLONNES_PIED, NAV } from '@/lib/navigation';
```

## Le contenu — fonction locale `Favoris()`
Taille attendue : ~70 lignes.
```tsx
const favoris = useFavoris();
const produits = favoris.favoris.flatMap((slug) => {
  const p = trouverProduit(slug);
  return p ? [p] : [];
});
const n = produits.length;
```
Si `!favoris.pret`, renvoie `<div aria-busy="true" className="min-h-[320px]" />`. Sinon :
```tsx
<>
  <div className="flex flex-col gap-2.5">
    <h1 className={TITRE_PAGE}>Mes favoris</h1>
    <p data-testid="favoris-nombre" className={SOUS_TITRE}>{`${n} ${n > 1 ? 'produits' : 'produit'}`}</p>
  </div>
  {n === 0 ? (
    <div data-testid="favoris-vide" className="flex flex-col items-start gap-4">
      <p className={SOUS_TITRE}>Vous n'avez pas encore de favori. Touchez le cœur d'une fiche produit pour l'ajouter ici.</p>
      <Link href="/boutique" className={`${BOUTON_PRINCIPAL} sm:w-auto`}>Découvrir la boutique</Link>
    </div>
  ) : (
    <ul className="grid gap-x-5 gap-y-8 sm:grid-cols-2 lg:grid-cols-3">
      {produits.map((p) => (
        <li key={p.slug} data-testid="favori" className="flex flex-col gap-3">
          <ProductCard produit={p} />
          <button type="button" onClick={() => favoris.basculer(p.slug)} aria-label={`Retirer ${p.nom} des favoris`}
            className={`self-start ${LIEN}`}>
            Retirer des favoris
          </button>
        </li>
      ))}
    </ul>
  )}
</>
```

## La page
```tsx
export default function PageFavoris() {
  const session = useSession();
  return (
    <>
      <SiteHeader navItems={NAV} />
      <main className="mx-auto w-full max-w-[1440px] px-5 pb-24 lg:px-20">
        <FilAriane items={[{ label: 'Accueil', href: '/' }, { label: 'Mon compte', href: '/compte' }, { label: 'Favoris' }]} />
        <EspaceClient actif="favoris">
          {session.client && <Favoris />}
        </EspaceClient>
      </main>
      <SiteFooter colonnes={COLONNES_PIED} />
    </>
  );
}
```
`n` est le nombre de produits retrouvés, ce qui accorde « produit » au singulier
jusqu'à un, zéro compris.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_7__
cat > 'tickets/manifest-104.tsv' <<'__VICTO_FIN_8__'
104a	src/lib/adresses.ts	tests/adresses.test.ts	tickets/104a-adresses.md	src/lib/compte.ts		
104b	src/components/compte/SessionProvider.tsx	tests/session-adresses.test.tsx	tickets/104b-session-adresses.md	src/lib/comptes-locaux.ts,src/lib/compte.ts	104a	
104c	src/components/compte/FormulaireAdresse.tsx	tests/FormulaireAdresse.test.tsx	tickets/104c-formulaire-adresse.md	src/components/compte/compte-affichage.ts,src/lib/adresses.ts	104a	
104d	src/app/compte/adresses/page.tsx	tests/page-adresses.test.tsx	tickets/104d-page-adresses.md	src/components/compte/compte-affichage.ts,src/components/compte/EspaceClient.tsx,src/components/compte/FormulaireAdresse.tsx,src/components/compte/SessionProvider.tsx,src/lib/adresses.ts	104a,104b,104c	
104e	src/components/favoris/FavorisProvider.tsx	tests/FavorisProvider.test.tsx	tickets/104e-favoris.md			
104f	src/app/layout.tsx	tests/layout-favoris.test.ts	tickets/104f-layout-favoris.md		104e	
104g	src/components/produit/BlocAchat.tsx	tests/favoris-bloc-achat.test.tsx	tickets/104g-bloc-achat-favoris.md	src/components/favoris/FavorisProvider.tsx	104e	
104h	src/app/compte/favoris/page.tsx	tests/page-favoris.test.tsx	tickets/104h-page-favoris.md	src/components/compte/compte-affichage.ts,src/components/compte/EspaceClient.tsx,src/components/compte/SessionProvider.tsx,src/components/favoris/FavorisProvider.tsx	104e	
__VICTO_FIN_8__
cat > 'tickets/tests/FavorisProvider.test.tsx' <<'__VICTO_FIN_9__'
import { fireEvent, render, screen } from '@testing-library/react';
import { beforeEach, describe, expect, it } from 'vitest';
import { CLE_FAVORIS, FavorisProvider, useFavoris } from '../src/components/favoris/FavorisProvider';

function Temoin() {
  const f = useFavoris();
  return (
    <div>
      <span data-testid="favoris">{f.favoris.join(',') || 'aucun'}</span>
      <span data-testid="pegasus">{String(f.estFavori('air-zoom-pegasus-41'))}</span>
      <button type="button" onClick={() => f.basculer('air-zoom-pegasus-41')}>pegasus</button>
      <button type="button" onClick={() => f.basculer('polo-shirt')}>polo</button>
    </div>
  );
}
const cliquer = (n: string) => fireEvent.click(screen.getByRole('button', { name: n }));
const favoris = () => screen.getByTestId('favoris').textContent;
const garde = () => window.localStorage.getItem(CLE_FAVORIS);

beforeEach(() => window.localStorage.clear());

describe('FavorisProvider', () => {
  it('ajoute puis retire un favori, et le garde', () => {
    render(<FavorisProvider><Temoin /></FavorisProvider>);
    cliquer('pegasus');
    cliquer('polo');
    expect(favoris()).toBe('air-zoom-pegasus-41,polo-shirt');
    expect(screen.getByTestId('pegasus').textContent).toBe('true');
    expect(garde()).toBe('["air-zoom-pegasus-41","polo-shirt"]');
    cliquer('pegasus');
    expect(favoris()).toBe('polo-shirt');
    expect(garde()).toBe('["polo-shirt"]');
  });

  it('relit les favoris gardés et ignore une liste illisible', () => {
    window.localStorage.setItem(CLE_FAVORIS, '["polo-shirt"]');
    const { unmount } = render(<FavorisProvider><Temoin /></FavorisProvider>);
    expect(favoris()).toBe('polo-shirt');
    unmount();
    window.localStorage.setItem(CLE_FAVORIS, '[1,2]');
    render(<FavorisProvider><Temoin /></FavorisProvider>);
    expect(favoris()).toBe('aucun');
  });

  it('ne fait rien hors du fournisseur', () => {
    render(<Temoin />);
    cliquer('pegasus');
    expect(favoris()).toBe('aucun');
    expect(screen.getByTestId('pegasus').textContent).toBe('false');
  });
});
__VICTO_FIN_9__
cat > 'tickets/tests/FormulaireAdresse.test.tsx' <<'__VICTO_FIN_10__'
import { fireEvent, render, screen } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import { FormulaireAdresse } from '../src/components/compte/FormulaireAdresse';
import { adresseVide, type DonneesAdresse } from '../src/lib/adresses';

const COMPLETE: DonneesAdresse = {
  libelle: 'Chalet', nomComplet: 'Camille Tremblay', ligne1: '12, chemin du Lac', ville: 'Mont-Tremblant',
  province: 'QC', codePostal: 'J8E 1T1', telephone: '819 555-0101',
};
function poser(initiales: DonneesAdresse) {
  const onEnregistrer = vi.fn(); const onAnnuler = vi.fn();
  render(<FormulaireAdresse initiales={initiales} titre="Nouvelle adresse" libelleBouton="Enregistrer l'adresse"
    onEnregistrer={onEnregistrer} onAnnuler={onAnnuler} />);
  return { onEnregistrer, onAnnuler };
}
const saisir = (libelle: string, valeur: string) => fireEvent.change(screen.getByLabelText(libelle), { target: { value: valeur } });
const envoyer = () => fireEvent.click(screen.getByRole('button', { name: "Enregistrer l'adresse" }));

describe('FormulaireAdresse', () => {
  it('se nomme par son titre et préremplit ses champs', () => {
    poser(COMPLETE);
    expect(screen.getByRole('form', { name: 'Nouvelle adresse' })).toBeInTheDocument();
    expect(screen.getByLabelText('Ville')).toHaveValue('Mont-Tremblant');
    expect(screen.getByLabelText('Province')).toHaveValue('QC');
    expect(screen.getAllByRole('option')).toHaveLength(13);
  });

  it('signale les champs fautifs sans enregistrer', () => {
    const { onEnregistrer } = poser(adresseVide('Camille Tremblay'));
    envoyer();
    expect(screen.getByText('Indiquez la ville.')).toBeInTheDocument();
    expect(screen.getByText('Code postal invalide (ex. H2J 2L3).')).toBeInTheDocument();
    expect(screen.getByLabelText('Ville')).toHaveAttribute('aria-invalid', 'true');
    expect(screen.getByLabelText('Ville').getAttribute('aria-describedby')).toBe('erreur-adresse-ville');
    expect(screen.getByLabelText('Destinataire')).not.toHaveAttribute('aria-invalid');
    expect(onEnregistrer).not.toHaveBeenCalled();
  });

  it('enregistre ce qui a été saisi', () => {
    const { onEnregistrer } = poser(COMPLETE);
    saisir('Ville', 'Saint-Sauveur');
    fireEvent.change(screen.getByLabelText('Province'), { target: { value: 'ON' } });
    envoyer();
    expect(onEnregistrer).toHaveBeenCalledWith({ ...COMPLETE, ville: 'Saint-Sauveur', province: 'ON' });
  });

  it('annule', () => {
    const { onAnnuler, onEnregistrer } = poser(COMPLETE);
    fireEvent.click(screen.getByRole('button', { name: 'Annuler' }));
    expect(onAnnuler).toHaveBeenCalledTimes(1);
    expect(onEnregistrer).not.toHaveBeenCalled();
  });
});
__VICTO_FIN_10__
cat > 'tickets/tests/adresses.test.ts' <<'__VICTO_FIN_11__'
import { describe, expect, it } from 'vitest';
import { CLIENT_DEMO, type Adresse } from '../src/lib/compte';
import {
  PROVINCES, adresseVide, ajouterAdresse, definirParDefaut, donneesDe, modifierAdresse, normaliserCodePostal,
  supprimerAdresse, validerAdresse, type DonneesAdresse,
} from '../src/lib/adresses';

const DEMO: Adresse[] = CLIENT_DEMO.adresses;
const CHALET: DonneesAdresse = {
  libelle: ' Chalet ', nomComplet: 'Camille Tremblay', ligne1: '12, chemin du Lac', ville: 'Mont-Tremblant',
  province: 'QC', codePostal: 'j8e1t1', telephone: '819 555-0101',
};
const parDefaut = (l: Adresse[]) => l.filter((a) => a.parDefaut).map((a) => a.id);

describe('adresses — validation', () => {
  it('signale chaque champ fautif, dans l’ordre', () => {
    expect(validerAdresse({ ...adresseVide(''), province: 'XX' })).toEqual({
      libelle: 'Donnez un nom à cette adresse.',
      nomComplet: 'Indiquez le nom du destinataire.',
      ligne1: 'Indiquez le numéro et la rue.',
      ville: 'Indiquez la ville.',
      province: 'Choisissez une province.',
      codePostal: 'Code postal invalide (ex. H2J 2L3).',
      telephone: 'Indiquez un numéro à 10 chiffres.',
    });
  });

  it('accepte une adresse complète, code postal et téléphone en toute écriture', () => {
    expect(validerAdresse(CHALET)).toEqual({});
    expect(validerAdresse({ ...CHALET, codePostal: 'J8E-1T1', telephone: '(819) 555-0101' })).toEqual({});
    expect(validerAdresse({ ...CHALET, codePostal: '12345' }).codePostal).toBe('Code postal invalide (ex. H2J 2L3).');
  });

  it('normalise le code postal', () => {
    expect(['h2j2l3', 'H2J 2L3', 'h2j-2l3', ' h2j 2l3 '].map(normaliserCodePostal)).toEqual(['H2J 2L3', 'H2J 2L3', 'H2J 2L3', 'H2J 2L3']);
  });

  it('prépare un formulaire vide ou prérempli', () => {
    expect(adresseVide('Léa Roy')).toEqual({ libelle: '', nomComplet: 'Léa Roy', ligne1: '', ville: '', province: 'QC', codePostal: '', telephone: '' });
    const domicile = DEMO.find((a) => a.id === 'domicile') as Adresse;
    expect(donneesDe(domicile)).toEqual({
      libelle: 'Domicile', nomComplet: 'Camille Tremblay', ligne1: '4520, rue Saint-Denis, app. 3', ville: 'Montréal',
      province: 'QC', codePostal: 'H2J 2L3', telephone: '514 555-0142',
    });
    expect(PROVINCES).toHaveLength(13);
  });
});

describe('adresses — opérations', () => {
  it('ajoute une adresse nettoyée, sans toucher au tableau reçu', () => {
    const suivantes = ajouterAdresse(DEMO, 'chalet', CHALET);
    expect(DEMO).toHaveLength(2);
    expect(suivantes).toHaveLength(3);
    expect(suivantes.find((a) => a.id === 'chalet')).toEqual({
      id: 'chalet', libelle: 'Chalet', nomComplet: 'Camille Tremblay', ligne1: '12, chemin du Lac', ville: 'Mont-Tremblant',
      province: 'QC', codePostal: 'J8E 1T1', telephone: '819 555-0101', parDefaut: false,
    });
  });

  it('fait de la première adresse l’adresse par défaut', () => {
    expect(parDefaut(ajouterAdresse([], 'chalet', CHALET))).toEqual(['chalet']);
  });

  it('modifie une adresse et garde son statut', () => {
    const domicile = DEMO.find((a) => a.id === 'domicile') as Adresse;
    const suivantes = modifierAdresse(DEMO, 'domicile', { ...donneesDe(domicile), ville: 'Laval' });
    expect(suivantes.find((a) => a.id === 'domicile')).toMatchObject({ ville: 'Laval', parDefaut: true });
    expect(suivantes.find((a) => a.id === 'bureau')).toEqual(DEMO.find((a) => a.id === 'bureau'));
  });

  it('change l’adresse par défaut', () => {
    expect(parDefaut(definirParDefaut(DEMO, 'bureau'))).toEqual(['bureau']);
  });

  it('supprime, et reporte le défaut sur la première restante', () => {
    expect(supprimerAdresse(DEMO, 'bureau').map((a) => a.id)).toEqual(['domicile']);
    const sansDomicile = supprimerAdresse(DEMO, 'domicile');
    expect(sansDomicile.map((a) => a.id)).toEqual(['bureau']);
    expect(parDefaut(sansDomicile)).toEqual(['bureau']);
    expect(supprimerAdresse(supprimerAdresse(DEMO, 'domicile'), 'bureau')).toEqual([]);
  });
});
__VICTO_FIN_11__
cat > 'tickets/tests/favoris-bloc-achat.test.tsx' <<'__VICTO_FIN_12__'
import { fireEvent, render, screen } from '@testing-library/react';
import { beforeEach, describe, expect, it } from 'vitest';
import { CLE_FAVORIS, FavorisProvider } from '../src/components/favoris/FavorisProvider';
import { BlocAchat } from '../src/components/produit/BlocAchat';
import type { Produit } from '../src/lib/catalogue';

const PRODUIT: Produit = {
  id: 'p1', slug: 'air-zoom-pegasus-41', nom: 'Air Zoom Pegasus 41', marque: { id: 'm1', nom: 'Nike', slug: 'nike' },
  imageUrl: '/img/x.svg', prixCents: 12900, variantes: [{ id: 'v1', taille: '42', sku: 'NK-42', stock: 5 }],
};
const classes = (el: Element) => (el.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);
const coeur = () => screen.getByRole('button', { name: 'Ajouter aux favoris' });

beforeEach(() => window.localStorage.clear());

describe('BlocAchat — favori gardé', () => {
  it('bascule le favori et le garde', () => {
    render(<FavorisProvider><BlocAchat produit={PRODUIT} /></FavorisProvider>);
    expect(coeur()).toHaveAttribute('aria-pressed', 'false');
    fireEvent.click(coeur());
    expect(coeur()).toHaveAttribute('aria-pressed', 'true');
    const icone = coeur().querySelector('svg.lucide-heart');
    expect(icone).not.toBeNull();
    for (const k of ['fill-[var(--vs-promo)]', 'text-[var(--vs-promo)]']) expect(classes(icone as Element)).toContain(k);
    expect(window.localStorage.getItem(CLE_FAVORIS)).toBe('["air-zoom-pegasus-41"]');
    fireEvent.click(coeur());
    expect(coeur()).toHaveAttribute('aria-pressed', 'false');
  });

  it('montre un favori déjà gardé', () => {
    window.localStorage.setItem(CLE_FAVORIS, '["air-zoom-pegasus-41"]');
    render(<FavorisProvider><BlocAchat produit={PRODUIT} /></FavorisProvider>);
    expect(coeur()).toHaveAttribute('aria-pressed', 'true');
  });
});
__VICTO_FIN_12__
cat > 'tickets/tests/layout-favoris.test.ts' <<'__VICTO_FIN_13__'
import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';

describe('layout — favoris', () => {
  const source = readFileSync('src/app/layout.tsx', 'utf8');

  it('enveloppe le panier et la session dans les favoris', () => {
    expect(source).toContain("import { FavorisProvider } from '@/components/favoris/FavorisProvider';");
    expect(source).toMatch(/<FavorisProvider>\s*<PanierProvider>[\s\S]*<SessionProvider>\{children\}<\/SessionProvider>[\s\S]*<\/PanierProvider>\s*<\/FavorisProvider>/);
    expect(source).not.toContain('use client');
  });
});
__VICTO_FIN_13__
cat > 'tickets/tests/page-adresses.test.tsx' <<'__VICTO_FIN_14__'
import { fireEvent, render, screen, within } from '@testing-library/react';
import { beforeEach, describe, expect, it } from 'vitest';
import PageAdresses from '../src/app/compte/adresses/page';
import { CLE_SESSION, SessionProvider } from '../src/components/compte/SessionProvider';
import { CLIENT_DEMO } from '../src/lib/compte';

const poser = (client: object = CLIENT_DEMO) => {
  window.localStorage.setItem(CLE_SESSION, JSON.stringify(client));
  render(<SessionProvider><PageAdresses /></SessionProvider>);
};
const carte = (id: string) => screen.getByTestId(`adresse-${id}`);
const cartes = () => screen.queryAllByTestId(/^adresse-/).map((c: HTMLElement) => c.getAttribute('data-testid'));
const saisir = (libelle: string, valeur: string) => fireEvent.change(screen.getByLabelText(libelle), { target: { value: valeur } });
const enregistre = () => JSON.parse(window.localStorage.getItem(CLE_SESSION) ?? '{}') as { adresses?: { id: string; parDefaut: boolean; ville: string }[] };

beforeEach(() => window.localStorage.clear());

describe('mes adresses', () => {
  it('liste les adresses du client, la principale marquée', () => {
    poser();
    expect(screen.getByRole('heading', { level: 1, name: 'Mes adresses' })).toBeInTheDocument();
    expect(cartes()).toEqual(['adresse-domicile', 'adresse-bureau']);
    expect(within(carte('domicile')).getByText('Par défaut')).toBeInTheDocument();
    expect(within(carte('bureau')).queryByText('Par défaut')).toBeNull();
    expect(screen.getByRole('link', { name: 'Adresses' })).toHaveAttribute('aria-current', 'page');
  });

  it('ajoute une adresse, et la garde', () => {
    poser();
    fireEvent.click(screen.getByRole('button', { name: 'Ajouter une adresse' }));
    expect(screen.getByLabelText('Destinataire')).toHaveValue('Camille Tremblay');
    saisir("Nom de l'adresse (ex. Domicile, Bureau)", 'Chalet');
    saisir('Adresse', '12, chemin du Lac');
    saisir('Ville', 'Mont-Tremblant');
    saisir('Code postal', 'j8e1t1');
    saisir('Téléphone', '819 555-0101');
    fireEvent.click(screen.getByRole('button', { name: "Enregistrer l'adresse" }));
    expect(cartes()).toHaveLength(3);
    expect(screen.queryByRole('form')).toBeNull();
    // Les lignes de l'adresse sont séparées par des <br /> : on lit le texte de la carte entière.
    expect(screen.getAllByTestId(/^adresse-adr-/).map((c: HTMLElement) => c.textContent).join('')).toContain('Mont-Tremblant (QC) J8E 1T1');
    expect(enregistre().adresses).toHaveLength(3);
  });

  it('modifie une adresse existante', () => {
    poser();
    fireEvent.click(within(carte('bureau')).getByRole('button', { name: 'Modifier' }));
    expect(screen.getByRole('form', { name: "Modifier l'adresse" })).toBeInTheDocument();
    saisir('Ville', 'Laval');
    fireEvent.click(screen.getByRole('button', { name: "Enregistrer l'adresse" }));
    expect(enregistre().adresses?.find((a) => a.id === 'bureau')?.ville).toBe('Laval');
  });

  it('change l’adresse par défaut', () => {
    poser();
    fireEvent.click(within(carte('bureau')).getByRole('button', { name: 'Définir par défaut' }));
    expect(within(carte('bureau')).getByText('Par défaut')).toBeInTheDocument();
    expect(within(carte('domicile')).queryByText('Par défaut')).toBeNull();
  });

  it('supprime après confirmation seulement', () => {
    poser();
    fireEvent.click(within(carte('bureau')).getByRole('button', { name: 'Supprimer' }));
    expect(cartes()).toHaveLength(2);
    fireEvent.click(within(carte('bureau')).getByRole('button', { name: 'Annuler' }));
    fireEvent.click(within(carte('bureau')).getByRole('button', { name: 'Supprimer' }));
    fireEvent.click(within(carte('bureau')).getByRole('button', { name: 'Confirmer la suppression' }));
    expect(cartes()).toEqual(['adresse-domicile']);
  });

  it('invite un nouveau client à ajouter sa première adresse', () => {
    poser({ ...CLIENT_DEMO, courriel: 'lea@exemple.ca', adresses: [] });
    expect(screen.getByTestId('adresses-vides')).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Ajouter une adresse' })).toBeInTheDocument();
  });
});
__VICTO_FIN_14__
cat > 'tickets/tests/page-favoris.test.tsx' <<'__VICTO_FIN_15__'
import { fireEvent, render, screen } from '@testing-library/react';
import { beforeEach, describe, expect, it } from 'vitest';
import PageFavoris from '../src/app/compte/favoris/page';
import { CLE_SESSION, SessionProvider } from '../src/components/compte/SessionProvider';
import { CLE_FAVORIS, FavorisProvider } from '../src/components/favoris/FavorisProvider';
import { CLIENT_DEMO } from '../src/lib/compte';
import { trouverProduit } from '../src/lib/donnees';

const nom = (slug: string) => trouverProduit(slug)?.nom ?? slug;
const poser = (favoris: string[], connecte = true) => {
  if (connecte) window.localStorage.setItem(CLE_SESSION, JSON.stringify(CLIENT_DEMO));
  window.localStorage.setItem(CLE_FAVORIS, JSON.stringify(favoris));
  render(<SessionProvider><FavorisProvider><PageFavoris /></FavorisProvider></SessionProvider>);
};

beforeEach(() => window.localStorage.clear());

describe('mes favoris', () => {
  it('liste les produits favoris et ignore un produit disparu', () => {
    poser(['air-zoom-pegasus-41', 'produit-disparu', 'polo-shirt']);
    expect(screen.getByRole('heading', { level: 1, name: 'Mes favoris' })).toBeInTheDocument();
    expect(screen.getAllByTestId('favori')).toHaveLength(2);
    expect(screen.getByTestId('favoris-nombre').textContent).toBe('2 produits');
    expect(screen.getByRole('link', { name: 'Favoris' })).toHaveAttribute('aria-current', 'page');
  });

  it('retire un favori, et le garde retiré', () => {
    poser(['air-zoom-pegasus-41', 'polo-shirt']);
    fireEvent.click(screen.getByRole('button', { name: `Retirer ${nom('polo-shirt')} des favoris` }));
    expect(screen.getAllByTestId('favori')).toHaveLength(1);
    expect(screen.getByTestId('favoris-nombre').textContent).toBe('1 produit');
    expect(window.localStorage.getItem(CLE_FAVORIS)).toBe('["air-zoom-pegasus-41"]');
  });

  it('invite à découvrir la boutique quand il n’y a aucun favori', () => {
    poser([]);
    expect(screen.getByTestId('favoris-vide')).toBeInTheDocument();
    expect(screen.getByTestId('favoris-nombre').textContent).toBe('0 produit');
    expect(screen.getByRole('link', { name: 'Découvrir la boutique' })).toHaveAttribute('href', '/boutique');
  });

  it('invite à se connecter sans session', () => {
    poser(['polo-shirt'], false);
    expect(screen.getByTestId('compte-invitation')).toBeInTheDocument();
  });
});
__VICTO_FIN_15__
cat > 'tickets/tests/session-adresses.test.tsx' <<'__VICTO_FIN_16__'
import { fireEvent, render, screen } from '@testing-library/react';
import { beforeEach, describe, expect, it } from 'vitest';
import { SessionProvider, useSession } from '../src/components/compte/SessionProvider';
import { supprimerAdresse } from '../src/lib/adresses';
import { COURRIEL_DEMO, MOT_DE_PASSE_DEMO } from '../src/lib/compte';

function Temoin() {
  const s = useSession();
  return (
    <div>
      <span data-testid="adresses">{s.client ? s.client.adresses.map((a) => a.id).join(',') || 'aucune' : 'déconnecté'}</span>
      <button type="button" onClick={() => s.connecter(COURRIEL_DEMO, MOT_DE_PASSE_DEMO)}>entrer</button>
      <button type="button" onClick={() => s.deconnecter()}>sortir</button>
      <button type="button" onClick={() => s.client && s.mettreAJourAdresses(supprimerAdresse(s.client.adresses, 'bureau'))}>sans bureau</button>
    </div>
  );
}
const cliquer = (n: string) => fireEvent.click(screen.getByRole('button', { name: n }));
const adresses = () => screen.getByTestId('adresses').textContent;

beforeEach(() => window.localStorage.clear());

describe('session — adresses', () => {
  it('met à jour les adresses du client', () => {
    render(<SessionProvider><Temoin /></SessionProvider>);
    cliquer('entrer');
    expect(adresses()).toBe('domicile,bureau');
    cliquer('sans bureau');
    expect(adresses()).toBe('domicile');
  });

  it('les garde dans le registre : on les retrouve après s’être reconnecté', () => {
    render(<SessionProvider><Temoin /></SessionProvider>);
    cliquer('entrer');
    cliquer('sans bureau');
    cliquer('sortir');
    cliquer('entrer');
    expect(adresses()).toBe('domicile');
  });

  it('ne fait rien sans session, ni hors du fournisseur', () => {
    render(<SessionProvider><Temoin /></SessionProvider>);
    cliquer('sans bureau');
    expect(adresses()).toBe('déconnecté');
  });
});
__VICTO_FIN_16__
TESTS=(FavorisProvider.test.tsx FormulaireAdresse.test.tsx adresses.test.ts favoris-bloc-achat.test.tsx layout-favoris.test.ts page-adresses.test.tsx page-favoris.test.tsx session-adresses.test.tsx)
for t in "${TESTS[@]}"; do git ls-files --error-unmatch "tests/$t" >/dev/null 2>&1 || rm -f "tests/$t"; done

# ------------------------------------------------------------ ancien test du favori : à assouplir, où qu'il soit
python3 - <<'PYT' || annuler "le bloc du favori de tests/BlocAchat.test.tsx n'est ni celui du lot 099 ni sa version assouplie : à regarder avant le lot"
import json, subprocess, sys
ancien = json.loads('"  it(\'habille le bouton d\\u2019ajout et bascule le favori\', () => {\\n    render(<BlocAchat produit={PROMO} />);\\n    porte(bouton(\'Ajouter au panier\'), \'h-[58px] rounded-full bg-[var(--vs-accent)] text-[var(--vs-blanc)] sm:flex-1\');\\n    const favori = bouton(\'Ajouter aux favoris\');\\n    expect(favori).toHaveAttribute(\'aria-pressed\', \'false\');\\n    fireEvent.click(favori);\\n    expect(favori).toHaveAttribute(\'aria-pressed\', \'true\');\\n    const coeur = favori.querySelector(\'svg.lucide-heart\');\\n    expect(coeur).not.toBeNull();\\n    porte(coeur as Element, \'fill-[var(--vs-promo)] text-[var(--vs-promo)]\');\\n  });"'); nouveau = json.loads('"  it(\'habille le bouton d\\u2019ajout et montre le c\\u0153ur\', () => {\\n    render(<BlocAchat produit={PROMO} />);\\n    porte(bouton(\'Ajouter au panier\'), \'h-[58px] rounded-full bg-[var(--vs-accent)] text-[var(--vs-blanc)] sm:flex-1\');\\n    // Depuis le lot 104, le favori est gard\\u00e9 par FavorisProvider : son comportement est\\n    // v\\u00e9rifi\\u00e9 par tests/favoris-bloc-achat.test.tsx.\\n    expect(bouton(\'Ajouter aux favoris\').querySelector(\'svg.lucide-heart\')).not.toBeNull();\\n  });"')
fichiers = subprocess.run(['git', 'ls-files', '*.test.ts', '*.test.tsx'], capture_output=True, text=True).stdout.split()
touches, deja = [], []
for f in fichiers:
    s = open(f, encoding='utf-8').read()
    if ancien in s:
        open(f, 'w', encoding='utf-8').write(s.replace(ancien, nouveau)); touches.append(f)
    elif nouveau in s:
        deja.append(f)
sys.exit(0 if 'tests/BlocAchat.test.tsx' in touches + deja else 1)
PYT
restes="$(git ls-files '*.test.ts' '*.test.tsx' | xargs grep -lE "fireEvent\.click\(favori\)|setFavori" 2>/dev/null | grep -v "favoris-bloc-achat" || true)"
[ -z "$restes" ] || annuler "d'autres tests cliquent encore sur le cœur sans fournisseur : $(echo $restes)"
ok "ancien test du bloc d'achat assoupli (le favori est vérifié par le test du 104g)"
ok "$(wc -l < tickets/manifest-104.tsv) tickets écrits, manifeste tickets/manifest-104.tsv"

# ------------------------------------------------------------ contrôle et budgets
CTL="$(mktemp -d)"; mkdir -p "$CTL/tests"
cp tickets/104*.md "$CTL/"; for t in "${TESTS[@]}"; do cp "tickets/tests/$t" "$CTL/tests/"; done
python3 outils/controle-lot.py "$CTL" src/styles/tokens.css || annuler "le contrôle a levé une alerte"
rm -rf "$CTL"
python3 - tickets/manifest-104.tsv <<'PYB' || annuler "un ticket dépasse le budget de contexte"
import os, re, sys
ctx = 16384
try:
    m = re.search(r'num_ctx"?:\s*(\d+)', open('.aider.model.settings.yml').read()); ctx = int(m.group(1)) if m else ctx
except OSError: pass
plafond, ko = ctx * 90 // 100, False
for ligne in open(sys.argv[1]):
    c = (ligne.rstrip('\n').split('\t') + [''] * 7)[:7]
    tid, cible, test, spec, contexte, _, mode = c
    car = len(open(spec).read()) + len(open('tickets/tests/' + os.path.basename(test)).read())
    for f in filter(None, contexte.split(',')):
        car += len(open(f).read()) if os.path.isfile(f) else 3000
    existe = os.path.isfile(cible)
    if mode != 'neuf' and existe: car += len(open(cible).read())
    n = re.search(r'Taille attendue : ~?(\d+) lignes', open(spec).read())
    sortie = int(n.group(1)) * 40 // 3 if n else (len(open(cible).read()) * 11 // 30 if existe else 0)
    total = car // 3 + 2000 + sortie
    ko |= total > plafond
    print(f"  {'✓' if total <= plafond else '✗'} budget {tid} : ≈ {total} jetons / plafond {plafond}")
sys.exit(1 if ko else 0)
PYB
ok "contrôle : 0 alerte ; budgets dans le plafond"

# ------------------------------------------------------------ pré-vol de chaque test
MAUVAIS='TypeError|ReferenceError|SyntaxError|Transform failed|is not a function|Cannot read propert|is not defined'
mkdir -p tests   # git rm peut avoir retiré le dossier devenu vide
for t in "${TESTS[@]}"; do
  p="tests/zz-prevol-$t"; cp "tickets/tests/$t" "$p"
  npx --no-install vitest run "$p" > /tmp/victo-prevol.log 2>&1 || true
  rm -f "$p"; sed -i -E 's/\x1b\[[0-9;]*m//g' /tmp/victo-prevol.log
  if grep -qE "$MAUVAIS" /tmp/victo-prevol.log; then
    grep -nE "$MAUVAIS" /tmp/victo-prevol.log | head -4; annuler "pré-vol de $t : le test PLANTE — c'est le test qui est faux"
  elif grep -qE "Failed to resolve import|Cannot find module|Does the file exist" /tmp/victo-prevol.log; then
    ok "pré-vol $t : module à créer, pas encore exécutable (normal)"
  elif grep -qE "Tests +[0-9]+ (failed|passed)" /tmp/victo-prevol.log; then
    ok "pré-vol $t : $(grep -oE 'Tests +[0-9]+ (failed|passed)[^(]*' /tmp/victo-prevol.log | head -1 | tr -s ' '), sans plantage"
  else
    tail -12 /tmp/victo-prevol.log; annuler "pré-vol de $t : résultat illisible"
  fi
done

# ------------------------------------------------------------ base verte, commit
npm run --silent typecheck >/tmp/victo-tsc.log 2>&1 || { grep -E "error TS" /tmp/victo-tsc.log | head; annuler "tsc rouge"; }
npm run --silent test >/tmp/victo-test.log 2>&1 || { grep -E "FAIL|×|→" /tmp/victo-test.log | head; annuler "tests rouges après assouplissement de l'ancien test"; }
ok "base verte"
git add -A -- tickets tests
git diff --cached --quiet && ok "rien de nouveau à commiter" || {
  git commit -q -m "chore(tickets): lot 104 — adresses et favoris"; ok "commit $(git rev-parse --short HEAD)"; }
trap - ERR
[ -z "$(git status --porcelain)" ] || mort "arbre sale après commit : $(git status --porcelain | head -3)"
if GIT_TERMINAL_PROMPT=0 git push -q origin main 2>/tmp/victo-push.log; then ok "poussé sur GitHub"
else info "push refusé (voir /tmp/victo-push.log) : le harnais poussera au premier vert"; fi

printf '\nPrêt :\n\n    MANIFEST=tickets/manifest-104.tsv ./run.sh\n\nHuit tickets : adresses (104a → 104b, 104c → 104d) et favoris (104e → 104f, 104g, 104h). Compte deux heures et demie : un run à lancer le soir.\n'
