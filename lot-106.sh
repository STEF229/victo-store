#!/usr/bin/env bash
# VICTO STORE — lot 106 : les pages d'aide.
#   106a GabaritAide (menu « Aide », titre)   106b blocs de contenu (section, encadré, tableau, étapes, « à compléter »)
#   106c /livraison   106d /retours   106e FormulaireContact   106f /contact
#   106g /conditions-de-vente   106h /confidentialite   (textes de départ, à faire valider par un juriste)
#   106i généré s'il le faut : les liens d'aide du pied de page mènent à ces pages
# Usage :  cd ~/victo-store && bash lot-106.sh
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
for d in 099b 102a 102b; do fusionne "$d" || mort "$d n'est pas fusionné : le lot 106 s'appuie dessus"; done
for c in MENU_LIEN MENU_LIEN_ACTIF TITRE_PAGE CHAMP CHAMP_LIBELLE CHAMP_SAISIE CHAMP_SAISIE_ERREUR CHAMP_ERREUR BOUTON_PRINCIPAL; do
  grep -qE "export const $c = " src/components/compte/compte-affichage.ts || mort "compte-affichage : $c absent"; done
grep -q "export function courrielValide" src/lib/compte.ts || mort "courrielValide absent de src/lib/compte.ts"
for f in src/components/aide src/app/livraison src/app/retours src/app/contact src/app/conditions-de-vente src/app/confidentialite; do
  [ ! -e "$f" ] || mort "$f existe déjà : lot déjà passé ?"; done
for j in noir blanc surface ligne gris accent promo; do grep -qE -- "--vs-$j\s*:" src/styles/tokens.css || mort "jeton --vs-$j absent"; done
manque="$(node -e "const l=require('lucide-react');console.log(['Mail','RotateCcw','Scale','ShieldCheck','Truck','Clock','MapPin','Phone'].filter(n=>!l[n]).join(' '))" 2>/dev/null || echo lucide-react)"
[ -z "$manque" ] || mort "icônes lucide absentes de ta version : $manque"
ok "fil d'Ariane, styles du compte, courrielValide et icônes conformes aux specs"
trap 'annuler "erreur inattendue à la ligne $LINENO du script"' ERR
mkdir -p tickets/tests
cat > 'tickets/106a-gabarit-aide.md' <<'__VICTO_FIN_0__'
TICKET 106a — gabarit des pages d'aide

Crée `src/components/aide/GabaritAide.tsx`, avec les exports nommés `RubriqueAide`
(type), `RUBRIQUES_AIDE` et `GabaritAide`. Composant **serveur** : pas de `'use client'`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index ;
  utilise `.map`.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Chaque `className` est écrit exactement comme ci-dessous.
- Icônes `lucide-react` avec `aria-hidden`.

## Bloc d'imports exact
```tsx
import { Mail, RotateCcw, Scale, ShieldCheck, Truck, type LucideIcon } from 'lucide-react';
import Link from 'next/link';
import type { ReactNode } from 'react';
import { MENU_LIEN, MENU_LIEN_ACTIF, TITRE_PAGE } from '@/components/compte/compte-affichage';
import { FilAriane } from '@/components/produit/FilAriane';
import { SiteFooter } from '@/components/ui/SiteFooter';
import { SiteHeader } from '@/components/ui/SiteHeader';
import { COLONNES_PIED, NAV } from '@/lib/navigation';
```

## Contenu
Taille attendue : ~60 lignes.
```tsx
export type RubriqueAide = 'livraison' | 'retours' | 'contact' | 'conditions' | 'confidentialite';

export const RUBRIQUES_AIDE: { cle: RubriqueAide; libelle: string; href: string; Icone: LucideIcon }[] = [
  { cle: 'livraison', libelle: 'Livraison', href: '/livraison', Icone: Truck },
  { cle: 'retours', libelle: 'Retours et échanges', href: '/retours', Icone: RotateCcw },
  { cle: 'contact', libelle: 'Contact', href: '/contact', Icone: Mail },
  { cle: 'conditions', libelle: 'Conditions de vente', href: '/conditions-de-vente', Icone: Scale },
  { cle: 'confidentialite', libelle: 'Confidentialité', href: '/confidentialite', Icone: ShieldCheck },
];
```
```tsx
export function GabaritAide({ actif, titre, intro, miseAJour, children }: {
  actif: RubriqueAide;
  titre: string;
  intro: string;
  miseAJour?: string | undefined;
  children: ReactNode;
})
```
rend :
```tsx
<>
  <SiteHeader navItems={NAV} />
  <main className="mx-auto w-full max-w-[1440px] px-5 pb-24 lg:px-20">
    <FilAriane items={[{ label: 'Accueil', href: '/' }, { label: 'Aide', href: '/livraison' }, { label: titre }]} />
    <div className="grid gap-10 lg:grid-cols-[280px_minmax(0,1fr)] lg:items-start lg:gap-14">
      <nav aria-label="Aide" className="flex gap-2 overflow-x-auto lg:sticky lg:top-6 lg:flex-col lg:gap-1 lg:overflow-visible">
        {RUBRIQUES_AIDE.map((r) => (
          <Link key={r.cle} href={r.href} aria-current={r.cle === actif ? 'page' : undefined}
            className={r.cle === actif ? MENU_LIEN_ACTIF : MENU_LIEN}>
            <r.Icone aria-hidden size={19} />
            {r.libelle}
          </Link>
        ))}
      </nav>
      <article className="flex max-w-[800px] flex-col gap-8">
        <header className="flex flex-col gap-2.5">
          <h1 className={TITRE_PAGE}>{titre}</h1>
          <p className="text-[17px] leading-relaxed text-[var(--vs-gris)]">{intro}</p>
        </header>
        {children}
        {miseAJour && <p className="text-[13px] text-[var(--vs-gris)]">{`Dernière mise à jour : ${miseAJour}`}</p>}
      </article>
    </div>
  </main>
  <SiteFooter colonnes={COLONNES_PIED} />
</>
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_0__
cat > 'tickets/106b-blocs-aide.md' <<'__VICTO_FIN_1__'
TICKET 106b — blocs de contenu des pages d'aide

Crée `src/components/aide/blocs-aide.tsx`, avec les exports nommés `Section`,
`Paragraphe`, `Liste`, `Encadre`, `Tableau`, `Etapes` et `AComplete`. Composants
**sans état**, serveur (pas de `'use client'`).

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index ;
  utilise `.map` (son deuxième argument sert de clé et de numéro).
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Chaque `className` est écrit exactement comme ci-dessous. Aucun `<h1>`.

## Bloc d'imports exact
```tsx
import type { ReactNode } from 'react';
```

## Les sept composants, recopiés tels quels
Taille attendue : ~85 lignes.
```tsx
export function Section({ titre, children }: { titre: string; children: ReactNode }) {
  return (
    <section className="flex flex-col gap-3">
      <h2 className="text-2xl font-black tracking-tight text-[var(--vs-noir)]">{titre}</h2>
      {children}
    </section>
  );
}

export function Paragraphe({ children }: { children: ReactNode }) {
  return <p className="text-base leading-relaxed text-[var(--vs-noir)]">{children}</p>;
}

export function Liste({ elements }: { elements: ReactNode[] }) {
  return (
    <ul className="flex list-disc flex-col gap-2 pl-6 text-base leading-relaxed text-[var(--vs-noir)]">
      {elements.map((e, i) => <li key={i}>{e}</li>)}
    </ul>
  );
}

export function Encadre({ icone, titre, alerte = false, children }: { icone: ReactNode; titre: string; alerte?: boolean; children: ReactNode }) {
  return (
    <div data-testid="encadre" className={alerte ? 'flex items-start gap-4 rounded-[22px] bg-[#FFD3DB] p-6' : 'flex items-start gap-4 rounded-[22px] bg-[#EEF1F8] p-6'}>
      <span className="flex h-11 w-11 shrink-0 items-center justify-center rounded-full bg-[var(--vs-blanc)]">{icone}</span>
      <div className="flex flex-col gap-1">
        <strong className="text-[17px] text-[var(--vs-noir)]">{titre}</strong>
        <div className="text-[15px] leading-relaxed text-[var(--vs-noir)]">{children}</div>
      </div>
    </div>
  );
}

export function Tableau({ entetes, lignes }: { entetes: string[]; lignes: string[][] }) {
  return (
    <div className="overflow-x-auto rounded-[22px] border-[1.5px] border-[var(--vs-ligne)]">
      <table className="w-full border-collapse">
        <thead>
          <tr>
            {entetes.map((e) => (
              <th key={e} scope="col" className="border-b-[1.5px] border-[var(--vs-ligne)] px-4 py-3.5 text-left text-[13px] font-extrabold uppercase tracking-wider text-[var(--vs-gris)]">{e}</th>
            ))}
          </tr>
        </thead>
        <tbody>
          {lignes.map((l, i) => (
            <tr key={i}>
              {l.map((c, j) => (
                <td key={j} className={j === 0 ? 'border-b border-[var(--vs-ligne)] px-4 py-4 text-[15px] font-bold' : 'border-b border-[var(--vs-ligne)] px-4 py-4 text-[15px]'}>{c}</td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

export function Etapes({ etapes }: { etapes: { titre: string; texte: ReactNode }[] }) {
  return (
    <ol className="grid gap-4 sm:grid-cols-3">
      {etapes.map((e, i) => (
        <li key={e.titre} className="flex flex-col gap-2 rounded-[22px] border-[1.5px] border-[var(--vs-ligne)] p-5">
          <span className="flex h-[34px] w-[34px] items-center justify-center rounded-full bg-[var(--vs-noir)] font-black text-[var(--vs-blanc)]">{i + 1}</span>
          <strong className="text-base text-[var(--vs-noir)]">{e.titre}</strong>
          <span className="text-sm leading-relaxed text-[var(--vs-gris)]">{e.texte}</span>
        </li>
      ))}
    </ol>
  );
}

export function AComplete({ children }: { children: ReactNode }) {
  return <mark className="rounded-md bg-[#EEF1F8] px-1.5 font-bold text-[var(--vs-accent)]">{children}</mark>;
}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_1__
cat > 'tickets/106c-page-livraison.md' <<'__VICTO_FIN_2__'
TICKET 106c — page Livraison

Crée `src/app/livraison/page.tsx`, export par défaut `PageLivraison`.

## Règles absolues
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- **Un seul export : l'export par défaut.** Composant serveur : pas de `'use client'`.
- Recopie **tous les textes exactement**, apostrophes droites comprises. Icônes
  `lucide-react` avec `aria-hidden`.

## Fichier
Taille attendue : ~50 lignes.
```tsx
import { Truck } from 'lucide-react';
import Link from 'next/link';
import { AComplete, Encadre, Paragraphe, Section, Tableau } from '@/components/aide/blocs-aide';
import { GabaritAide } from '@/components/aide/GabaritAide';

export default function PageLivraison() {
  return (
    <GabaritAide actif="livraison" titre="Livraison" intro="Partout au Canada, offerte, suivie de l'entrepôt à votre porte." miseAJour="27 septembre 2026">
      <Encadre icone={<Truck aria-hidden size={20} />} titre="Livraison offerte au Canada">
        Sans minimum d'achat, pour toutes les commandes livrées au Canada.
      </Encadre>
      <Section titre="Délais">
        <Paragraphe>
          Les commandes sont préparées et remises au transporteur sous 48 heures ouvrables. Les délais ci-dessous courent à partir de l'expédition <AComplete>à confirmer avec le transporteur</AComplete>.
        </Paragraphe>
        <Tableau
          entetes={['Destination', 'Délai de livraison', 'Transporteur']}
          lignes={[
            ['Québec', '2 à 4 jours ouvrables', 'Postes Canada'],
            ['Ontario et Maritimes', '3 à 5 jours ouvrables', 'Postes Canada'],
            ['Prairies et Colombie-Britannique', '4 à 7 jours ouvrables', 'Postes Canada'],
            ['Territoires', '7 à 12 jours ouvrables', 'Postes Canada'],
          ]}
        />
      </Section>
      <Section titre="Suivre votre colis">
        <Paragraphe>
          Dès l'expédition, vous recevez un courriel avec le numéro de suivi. Il apparaît aussi dans votre compte, sous <Link href="/compte/commandes" className="font-bold underline">Mes commandes</Link>.
        </Paragraphe>
      </Section>
      <Section titre="Livraison hors du Canada">
        <Paragraphe>Nous livrons seulement au Canada pour le moment.</Paragraphe>
      </Section>
      <Section titre="Colis en retard, perdu ou abîmé">
        <Paragraphe>
          Écrivez-nous dans les 14 jours suivant la date de livraison prévue <AComplete>délai à confirmer</AComplete> : nous ouvrons une enquête auprès du transporteur, puis renvoyons l'article ou vous remboursons. Si la commande n'est pas livrée dans les 30 jours suivant la date prévue, vous pouvez aussi l'annuler (voir les <Link href="/conditions-de-vente" className="font-bold underline">conditions de vente</Link>).
        </Paragraphe>
      </Section>
    </GabaritAide>
  );
}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_2__
cat > 'tickets/106d-page-retours.md' <<'__VICTO_FIN_3__'
TICKET 106d — page Retours et échanges

Crée `src/app/retours/page.tsx`, export par défaut `PageRetours`.

## Règles absolues
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- **Un seul export : l'export par défaut.** Composant serveur : pas de `'use client'`.
- Recopie **tous les textes exactement**, apostrophes droites comprises. Icônes
  `lucide-react` avec `aria-hidden`.

## Fichier
Taille attendue : ~55 lignes.
```tsx
import { RotateCcw } from 'lucide-react';
import Link from 'next/link';
import { AComplete, Encadre, Etapes, Liste, Paragraphe, Section } from '@/components/aide/blocs-aide';
import { GabaritAide } from '@/components/aide/GabaritAide';

export default function PageRetours() {
  return (
    <GabaritAide actif="retours" titre="Retours et échanges" intro="Pas la bonne pointure ? Vous avez 30 jours." miseAJour="27 septembre 2026">
      <Encadre icone={<RotateCcw aria-hidden size={20} />} titre="30 jours pour changer d'avis">
        À compter de la réception. L'échange de pointure est gratuit ; le retour est <AComplete>gratuit ou à vos frais : à décider</AComplete>.
      </Encadre>
      <Section titre="Comment faire">
        <Etapes
          etapes={[
            { titre: 'Déclarez le retour', texte: <>Dans votre compte, <Link href="/compte/commandes" className="font-bold underline">Mes commandes</Link>, choisissez la commande.</> },
            { titre: "Emballez l'article", texte: "Dans sa boîte d'origine, avec l'étiquette de retour imprimée." },
            { titre: 'Déposez le colis', texte: "Dans n'importe quel bureau de Postes Canada." },
          ]}
        />
      </Section>
      <Section titre="Conditions">
        <Liste
          elements={[
            "Articles non portés, avec leurs étiquettes, dans leur emballage d'origine.",
            "Chaussures essayées à l'intérieur seulement, semelles propres.",
            <>Articles soldés : <AComplete>remboursement ou crédit en boutique, à décider</AComplete>.</>,
            'Sous-vêtements et chaussettes ouverts : ni repris ni échangés, par hygiène.',
          ]}
        />
      </Section>
      <Section titre="Remboursement">
        <Paragraphe>
          Le remboursement est fait sur le moyen de paiement d'origine, dans les 5 à 10 jours ouvrables suivant la réception du retour à notre entrepôt. Vous recevez un courriel de confirmation.
        </Paragraphe>
      </Section>
      <Section titre="Article défectueux">
        <Paragraphe>
          Un article défectueux est remplacé ou remboursé, frais de retour compris, même après 30 jours, dans le cadre de la garantie légale (voir les <Link href="/conditions-de-vente" className="font-bold underline">conditions de vente</Link>).
        </Paragraphe>
      </Section>
    </GabaritAide>
  );
}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_3__
cat > 'tickets/106e-formulaire-contact.md' <<'__VICTO_FIN_4__'
TICKET 106e — formulaire de contact

Crée `src/components/aide/FormulaireContact.tsx`, export nommé `FormulaireContact`.
Aucun courriel n'est encore envoyé : après validation, le formulaire le dit clairement.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index ;
  utilise `.map`.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Chaque `className` est écrit exactement comme ci-dessous. Aucun `<h1>`.
- Recopie tous les textes exactement, apostrophes droites comprises.

## Bloc d'imports exact
```tsx
'use client';

import { useState, type FormEvent } from 'react';
import {
  BOUTON_PRINCIPAL, CHAMP, CHAMP_ERREUR, CHAMP_LIBELLE, CHAMP_SAISIE, CHAMP_SAISIE_ERREUR,
} from '@/components/compte/compte-affichage';
import { courrielValide } from '@/lib/compte';
```

## Contenu
Taille attendue : ~95 lignes.
```tsx
const SUJETS = ['Suivi de commande', 'Retour ou échange', 'Question sur un produit', 'Autre'];

type Champs = { nom: string; courriel: string; commande: string; sujet: string; message: string };
type Erreurs = Partial<Record<'nom' | 'courriel' | 'message', string>>;

function valider(c: Champs): Erreurs {
  const erreurs: Erreurs = {};
  if (c.nom.trim() === '') erreurs.nom = 'Indiquez votre nom.';
  if (!courrielValide(c.courriel)) erreurs.courriel = 'Indiquez un courriel valide.';
  if (c.message.trim().length < 10) erreurs.message = 'Écrivez au moins 10 caractères.';
  return erreurs;
}
```
`export function FormulaireContact()` :
```tsx
const [champs, setChamps] = useState<Champs>({ nom: '', courriel: '', commande: '', sujet: 'Suivi de commande', message: '' });
const [erreurs, setErreurs] = useState<Erreurs>({});
const [pret, setPret] = useState(false);
const changer = (cle: keyof Champs) => (valeur: string) => { setChamps({ ...champs, [cle]: valeur }); setPret(false); };

function soumettre(e: FormEvent<HTMLFormElement>) {
  e.preventDefault();
  const trouvees = valider(champs);
  setErreurs(trouvees);
  setPret(Object.keys(trouvees).length === 0);
}
```
Rendu :
```tsx
<form onSubmit={soumettre} noValidate aria-label="Écrire au service client" className="flex flex-col gap-[18px]">
  <div className="grid gap-4 sm:grid-cols-2">
    <div className={CHAMP}>
      <label htmlFor="contact-nom" className={CHAMP_LIBELLE}>Nom</label>
      <input id="contact-nom" type="text" autoComplete="name" value={champs.nom} onChange={(e) => changer('nom')(e.target.value)}
        aria-invalid={erreurs.nom ? true : undefined} className={erreurs.nom ? CHAMP_SAISIE_ERREUR : CHAMP_SAISIE} />
      {erreurs.nom && <p className={CHAMP_ERREUR}>{erreurs.nom}</p>}
    </div>
    <div className={CHAMP}>
      <label htmlFor="contact-courriel" className={CHAMP_LIBELLE}>Courriel</label>
      <input id="contact-courriel" type="email" autoComplete="email" value={champs.courriel} onChange={(e) => changer('courriel')(e.target.value)}
        aria-invalid={erreurs.courriel ? true : undefined} className={erreurs.courriel ? CHAMP_SAISIE_ERREUR : CHAMP_SAISIE} />
      {erreurs.courriel && <p className={CHAMP_ERREUR}>{erreurs.courriel}</p>}
    </div>
  </div>
  <div className={CHAMP}>
    <label htmlFor="contact-commande" className={CHAMP_LIBELLE}>Numéro de commande (facultatif)</label>
    <input id="contact-commande" type="text" value={champs.commande} onChange={(e) => changer('commande')(e.target.value)} className={CHAMP_SAISIE} />
  </div>
  <div className={CHAMP}>
    <label htmlFor="contact-sujet" className={CHAMP_LIBELLE}>Sujet</label>
    <select id="contact-sujet" value={champs.sujet} onChange={(e) => changer('sujet')(e.target.value)} className={CHAMP_SAISIE}>
      {SUJETS.map((s) => <option key={s} value={s}>{s}</option>)}
    </select>
  </div>
  <div className={CHAMP}>
    <label htmlFor="contact-message" className={CHAMP_LIBELLE}>Message</label>
    <textarea id="contact-message" rows={6} value={champs.message} onChange={(e) => changer('message')(e.target.value)}
      aria-invalid={erreurs.message ? true : undefined}
      className={erreurs.message
        ? 'w-full rounded-[14px] border-[1.5px] border-[var(--vs-promo)] bg-[var(--vs-blanc)] px-[18px] py-3.5 text-base text-[var(--vs-noir)]'
        : 'w-full rounded-[14px] border-[1.5px] border-[var(--vs-ligne)] bg-[var(--vs-blanc)] px-[18px] py-3.5 text-base text-[var(--vs-noir)]'} />
    {erreurs.message && <p className={CHAMP_ERREUR}>{erreurs.message}</p>}
  </div>
  <p className="text-[13px] leading-relaxed text-[var(--vs-gris)]">
    Vos renseignements servent uniquement à répondre à votre demande.
  </p>
  {pret && (
    <p role="status" className="rounded-2xl bg-[#EEF1F8] p-4 text-sm font-bold text-[var(--vs-accent)]">
      Votre message est prêt. L'envoi au service client sera branché à la mise en ligne de la boutique.
    </p>
  )}
  <button type="submit" className={`self-start ${BOUTON_PRINCIPAL} sm:w-auto`}>Envoyer</button>
</form>
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_4__
cat > 'tickets/106f-page-contact.md' <<'__VICTO_FIN_5__'
TICKET 106f — page Contact

Crée `src/app/contact/page.tsx`, export par défaut `PageContact`.

## Règles absolues
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- **Un seul export : l'export par défaut.** Composant serveur : pas de `'use client'`.
- Recopie tous les textes exactement, apostrophes droites comprises. Icônes
  `lucide-react` avec `aria-hidden`. Chaque `className` est écrit exactement.

## Fichier
Taille attendue : ~50 lignes.
```tsx
import { Clock, Mail, MapPin, Phone } from 'lucide-react';
import type { ReactNode } from 'react';
import { AComplete } from '@/components/aide/blocs-aide';
import { FormulaireContact } from '@/components/aide/FormulaireContact';
import { GabaritAide } from '@/components/aide/GabaritAide';

function Coordonnee({ icone, titre, children }: { icone: ReactNode; titre: string; children: ReactNode }) {
  return (
    <div className="flex items-start gap-3.5">
      <span className="flex h-[42px] w-[42px] shrink-0 items-center justify-center rounded-full bg-[var(--vs-blanc)]">{icone}</span>
      <div className="flex flex-col gap-0.5">
        <span className="text-[13px] text-[var(--vs-gris)]">{titre}</span>
        <span className="text-base font-bold text-[var(--vs-noir)]">{children}</span>
      </div>
    </div>
  );
}

export default function PageContact() {
  return (
    <GabaritAide actif="contact" titre="Contact" intro="Une question sur une commande, une pointure, un retour ? On répond en un jour ouvrable.">
      <div className="grid gap-6 lg:grid-cols-[minmax(0,3fr)_minmax(0,2fr)] lg:items-start">
        <FormulaireContact />
        <aside aria-label="Nos coordonnées" className="flex flex-col gap-5 rounded-3xl bg-[var(--vs-surface)] p-7">
          <Coordonnee icone={<Mail aria-hidden size={19} />} titre="Courriel"><AComplete>adresse du service client</AComplete></Coordonnee>
          <Coordonnee icone={<Phone aria-hidden size={19} />} titre="Téléphone"><AComplete>numéro</AComplete></Coordonnee>
          <Coordonnee icone={<Clock aria-hidden size={19} />} titre="Heures">Lundi au vendredi, 9 h à 17 h (heure de l'Est)</Coordonnee>
          <Coordonnee icone={<MapPin aria-hidden size={19} />} titre="Adresse"><AComplete>adresse de l'entreprise</AComplete></Coordonnee>
        </aside>
      </div>
    </GabaritAide>
  );
}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_5__
cat > 'tickets/106g-page-conditions.md' <<'__VICTO_FIN_6__'
TICKET 106g — page Conditions de vente

Crée `src/app/conditions-de-vente/page.tsx`, export par défaut `PageConditions`.
Texte de départ, à faire valider par un juriste.

## Règles absolues
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- **Un seul export : l'export par défaut.** Composant serveur : pas de `'use client'`.
- Recopie **tous les textes exactement**, apostrophes droites comprises. Icônes
  `lucide-react` avec `aria-hidden`.

## Fichier
Taille attendue : ~75 lignes.
```tsx
import { Scale } from 'lucide-react';
import Link from 'next/link';
import { AComplete, Encadre, Liste, Paragraphe, Section } from '@/components/aide/blocs-aide';
import { GabaritAide } from '@/components/aide/GabaritAide';

export default function PageConditions() {
  return (
    <GabaritAide actif="conditions" titre="Conditions de vente" intro="Les règles de nos ventes en ligne, écrites simplement." miseAJour="27 septembre 2026">
      <Encadre icone={<Scale aria-hidden size={20} />} titre="À faire valider par un juriste" alerte>
        Texte de départ rédigé d'après la Loi sur la protection du consommateur (contrats conclus à distance). Les passages marqués sont à compléter.
      </Encadre>
      <Section titre="1. Qui sommes-nous">
        <Paragraphe>
          VICTO STORE est exploitée par <AComplete>raison sociale</AComplete>, <AComplete>adresse</AComplete>, <AComplete>téléphone</AComplete>, <AComplete>courriel</AComplete>, numéro d'entreprise du Québec (NEQ) <AComplete>NEQ</AComplete>.
        </Paragraphe>
      </Section>
      <Section titre="2. Produits et prix">
        <Paragraphe>
          Chaque fiche décrit le produit, ses tailles disponibles et son prix. Les prix sont en dollars canadiens. Le récapitulatif de commande détaille le prix de chaque article, la livraison (offerte) et les taxes, TPS 5 % et TVQ 9,975 %, avant le paiement.
        </Paragraphe>
      </Section>
      <Section titre="3. Commande et paiement">
        <Paragraphe>
          La commande est conclue quand vous confirmez le paiement. Le paiement par carte est traité par notre prestataire de paiement ; nous ne conservons jamais votre numéro de carte. Vous recevez par courriel une confirmation reprenant les modalités de la commande.
        </Paragraphe>
      </Section>
      <Section titre="4. Livraison">
        <Paragraphe>
          Les délais sont indiqués sur la page <Link href="/livraison" className="font-bold underline">Livraison</Link> et sur votre confirmation de commande.
        </Paragraphe>
      </Section>
      <Section titre="5. Annulation et remboursement">
        <Liste
          elements={[
            "Vous pouvez annuler la commande si elle n'est pas livrée dans les 30 jours suivant la date de livraison prévue (ou suivant la commande, si aucune date n'était prévue).",
            "Vous pouvez aussi l'annuler dans les 7 jours suivant la réception de votre confirmation si des informations obligatoires y manquaient.",
            "En cas d'annulation, nous vous remboursons dans les 15 jours. À défaut, vous pouvez demander à l'émetteur de votre carte d'annuler le paiement.",
          ]}
        />
      </Section>
      <Section titre="6. Retours">
        <Paragraphe>
          En plus de vos droits légaux, nous acceptons les retours pendant 30 jours, selon la page <Link href="/retours" className="font-bold underline">Retours et échanges</Link>.
        </Paragraphe>
      </Section>
      <Section titre="7. Garantie légale">
        <Paragraphe>
          Tout article doit servir à l'usage auquel il est destiné, pendant une durée raisonnable. Cette garantie s'applique sans frais, en plus de notre politique de retour.
        </Paragraphe>
      </Section>
      <Section titre="8. Droit applicable">
        <Paragraphe>
          Ces conditions sont régies par les lois du Québec. Pour toute question ou plainte, écrivez-nous d'abord ; vous pouvez aussi vous adresser à l'Office de la protection du consommateur.
        </Paragraphe>
      </Section>
    </GabaritAide>
  );
}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_6__
cat > 'tickets/106h-page-confidentialite.md' <<'__VICTO_FIN_7__'
TICKET 106h — page Confidentialité

Crée `src/app/confidentialite/page.tsx`, export par défaut `PageConfidentialite`.
Texte de départ d'après la Loi 25, à faire valider par un juriste.

## Règles absolues
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- **Un seul export : l'export par défaut.** Composant serveur : pas de `'use client'`.
- Recopie **tous les textes exactement**, apostrophes droites comprises. Icônes
  `lucide-react` avec `aria-hidden`.

## Fichier
Taille attendue : ~80 lignes.
```tsx
import { ShieldCheck } from 'lucide-react';
import { AComplete, Encadre, Liste, Paragraphe, Section, Tableau } from '@/components/aide/blocs-aide';
import { GabaritAide } from '@/components/aide/GabaritAide';

export default function PageConfidentialite() {
  return (
    <GabaritAide actif="confidentialite" titre="Confidentialité" intro="Ce que nous faisons de vos renseignements personnels, et vos droits." miseAJour="27 septembre 2026">
      <Encadre icone={<ShieldCheck aria-hidden size={20} />} titre="À faire valider par un juriste" alerte>
        Texte de départ rédigé d'après la Loi 25 (protection des renseignements personnels dans le secteur privé). Les passages marqués sont à compléter.
      </Encadre>
      <Section titre="Responsable de la protection des renseignements personnels">
        <Paragraphe>
          <AComplete>nom et titre</AComplete>, joignable à <AComplete>courriel</AComplete>. Cette personne répond à toute question sur vos renseignements et traite vos demandes.
        </Paragraphe>
      </Section>
      <Section titre="Ce que nous recueillons, et pourquoi">
        <Tableau
          entetes={['Renseignements', 'À quoi ils servent']}
          lignes={[
            ['Nom, courriel, téléphone', 'Créer votre compte, vous écrire au sujet de vos commandes'],
            ['Adresse de livraison', 'Livrer vos commandes'],
            ["Historique d'achats", 'Suivi des commandes, retours, service client'],
            ['Paiement', 'Traité par notre prestataire de paiement ; nous ne conservons pas votre numéro de carte'],
            ['Témoins (cookies) optionnels', "Mesure d'audience, seulement si vous les acceptez"],
          ]}
        />
      </Section>
      <Section titre="Votre consentement">
        <Paragraphe>
          Nous recueillons seulement ce qui est nécessaire, avec votre consentement. L'infolettre est facultative et se désactive en un clic ; les témoins optionnels sont désactivés par défaut.
        </Paragraphe>
      </Section>
      <Section titre="Qui y a accès">
        <Paragraphe>
          Nos employés concernés, et nos prestataires pour ce qui les regarde : livraison (Postes Canada), paiement, hébergement. Certains traitent des données hors du Québec <AComplete>liste et pays à compléter</AComplete> ; nous évaluons au préalable la protection offerte.
        </Paragraphe>
      </Section>
      <Section titre="Durée de conservation">
        <Paragraphe>
          Nous conservons vos renseignements le temps nécessaire aux fins indiquées et aux obligations légales, puis nous les détruisons ou les anonymisons <AComplete>durées à préciser</AComplete>.
        </Paragraphe>
      </Section>
      <Section titre="Vos droits">
        <Liste
          elements={[
            'Accéder à vos renseignements et en obtenir une copie, y compris dans un format technologique structuré.',
            'Les faire corriger.',
            'Retirer votre consentement.',
            'Faire cesser leur diffusion ou désindexer un lien, dans les cas prévus par la loi.',
            "Porter plainte auprès de la Commission d'accès à l'information du Québec.",
          ]}
        />
        <Paragraphe>Écrivez au responsable ci-dessus : nous répondons dans les 30 jours.</Paragraphe>
      </Section>
      <Section titre="Incidents de confidentialité">
        <Paragraphe>
          En cas d'incident présentant un risque de préjudice sérieux, nous avisons la Commission d'accès à l'information et les personnes concernées, et nous tenons un registre des incidents.
        </Paragraphe>
      </Section>
    </GabaritAide>
  );
}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
__VICTO_FIN_7__
cat > 'tickets/manifest-106.tsv' <<'__VICTO_FIN_8__'
106a	src/components/aide/GabaritAide.tsx	tests/GabaritAide.test.tsx	tickets/106a-gabarit-aide.md	src/components/compte/compte-affichage.ts,src/components/produit/FilAriane.tsx,src/lib/navigation.ts		
106b	src/components/aide/blocs-aide.tsx	tests/blocs-aide.test.tsx	tickets/106b-blocs-aide.md			
106c	src/app/livraison/page.tsx	tests/page-livraison.test.tsx	tickets/106c-page-livraison.md	src/components/aide/GabaritAide.tsx,src/components/aide/blocs-aide.tsx	106a,106b	
106d	src/app/retours/page.tsx	tests/page-retours.test.tsx	tickets/106d-page-retours.md	src/components/aide/GabaritAide.tsx,src/components/aide/blocs-aide.tsx	106a,106b	
106e	src/components/aide/FormulaireContact.tsx	tests/FormulaireContact.test.tsx	tickets/106e-formulaire-contact.md	src/components/compte/compte-affichage.ts,src/lib/compte.ts		
106f	src/app/contact/page.tsx	tests/page-contact.test.tsx	tickets/106f-page-contact.md	src/components/aide/GabaritAide.tsx,src/components/aide/blocs-aide.tsx,src/components/aide/FormulaireContact.tsx	106a,106b,106e	
106g	src/app/conditions-de-vente/page.tsx	tests/page-conditions.test.tsx	tickets/106g-page-conditions.md	src/components/aide/GabaritAide.tsx,src/components/aide/blocs-aide.tsx	106a,106b	
106h	src/app/confidentialite/page.tsx	tests/page-confidentialite.test.tsx	tickets/106h-page-confidentialite.md	src/components/aide/GabaritAide.tsx,src/components/aide/blocs-aide.tsx	106a,106b	
__VICTO_FIN_8__
cat > 'tickets/tests/FormulaireContact.test.tsx' <<'__VICTO_FIN_9__'
import { fireEvent, render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { FormulaireContact } from '../src/components/aide/FormulaireContact';

const saisir = (libelle: string, valeur: string) => fireEvent.change(screen.getByLabelText(libelle), { target: { value: valeur } });
const envoyer = () => fireEvent.click(screen.getByRole('button', { name: 'Envoyer' }));

describe('FormulaireContact', () => {
  it('propose les quatre sujets', () => {
    render(<FormulaireContact />);
    expect(screen.getByRole('form', { name: 'Écrire au service client' })).toBeInTheDocument();
    expect(screen.getAllByRole('option').map((o: HTMLElement) => o.textContent)).toEqual([
      'Suivi de commande', 'Retour ou échange', 'Question sur un produit', 'Autre',
    ]);
  });

  it('signale les champs fautifs, sans rien annoncer', () => {
    render(<FormulaireContact />);
    saisir('Message', 'court');
    envoyer();
    expect(screen.getByText('Indiquez votre nom.')).toBeInTheDocument();
    expect(screen.getByText('Indiquez un courriel valide.')).toBeInTheDocument();
    expect(screen.getByText('Écrivez au moins 10 caractères.')).toBeInTheDocument();
    expect(screen.getByLabelText('Message')).toHaveAttribute('aria-invalid', 'true');
    expect(screen.queryByRole('status')).toBeNull();
  });

  it('dit honnêtement que l’envoi n’est pas encore branché', () => {
    render(<FormulaireContact />);
    saisir('Nom', 'Camille Tremblay');
    saisir('Courriel', 'camille@exemple.ca');
    saisir('Message', 'Je voudrais échanger ma pointure 41 contre une 42.');
    envoyer();
    expect(screen.getByRole('status').textContent).toBe("Votre message est prêt. L'envoi au service client sera branché à la mise en ligne de la boutique.");
    expect(screen.getByLabelText('Nom')).not.toHaveAttribute('aria-invalid');
    saisir('Message', 'Autre chose encore à dire.');
    expect(screen.queryByRole('status')).toBeNull();
  });
});
__VICTO_FIN_9__
cat > 'tickets/tests/GabaritAide.test.tsx' <<'__VICTO_FIN_10__'
import { render, screen, within } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { GabaritAide, RUBRIQUES_AIDE } from '../src/components/aide/GabaritAide';
import { MENU_LIEN_ACTIF } from '../src/components/compte/compte-affichage';

const classes = (el: Element) => (el.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);

describe('GabaritAide', () => {
  it('liste les cinq rubriques, dans l’ordre, avec leurs adresses', () => {
    expect(RUBRIQUES_AIDE.map((r) => [r.libelle, r.href])).toEqual([
      ['Livraison', '/livraison'], ['Retours et échanges', '/retours'], ['Contact', '/contact'],
      ['Conditions de vente', '/conditions-de-vente'], ['Confidentialité', '/confidentialite'],
    ]);
  });

  it('assemble en-tête, fil, menu marqué, titre, contenu, date et pied', () => {
    render(<GabaritAide actif="retours" titre="Retours et échanges" intro="Pas la bonne pointure ?" miseAJour="27 septembre 2026"><p>contenu</p></GabaritAide>);
    expect(screen.getByRole('banner')).toBeInTheDocument();
    expect(screen.getByRole('heading', { level: 1, name: 'Retours et échanges' })).toBeInTheDocument();
    expect(screen.getByText('Pas la bonne pointure ?')).toBeInTheDocument();
    const menu = screen.getByRole('navigation', { name: 'Aide' });
    const actif = within(menu).getByRole('link', { name: 'Retours et échanges' });
    expect(actif).toHaveAttribute('aria-current', 'page');
    for (const k of MENU_LIEN_ACTIF.split(' ')) expect(classes(actif)).toContain(k);
    expect(within(menu).getByRole('link', { name: 'Contact' })).not.toHaveAttribute('aria-current');
    expect(screen.getByText('contenu')).toBeInTheDocument();
    expect(screen.getByText('Dernière mise à jour : 27 septembre 2026')).toBeInTheDocument();
    expect(screen.getByRole('contentinfo')).toBeInTheDocument();
  });

  it('se passe de date quand il n’y en a pas', () => {
    render(<GabaritAide actif="contact" titre="Contact" intro="Une question ?"><p>x</p></GabaritAide>);
    expect(screen.queryByText(/Dernière mise à jour/)).toBeNull();
  });
});
__VICTO_FIN_10__
cat > 'tickets/tests/blocs-aide.test.tsx' <<'__VICTO_FIN_11__'
import { render, screen, within } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { AComplete, Encadre, Etapes, Liste, Paragraphe, Section, Tableau } from '../src/components/aide/blocs-aide';

const classes = (el: Element) => (el.getAttribute('class') ?? '').split(/\s+/).filter(Boolean);

describe('blocs des pages d’aide', () => {
  it('titre une section, avec son texte et sa liste', () => {
    render(<Section titre="Délais"><Paragraphe>Sous 48 heures.</Paragraphe><Liste elements={['Un', 'Deux']} /></Section>);
    expect(screen.getByRole('heading', { level: 2, name: 'Délais' })).toBeInTheDocument();
    expect(screen.getByText('Sous 48 heures.').tagName).toBe('P');
    expect(screen.getAllByRole('listitem').map((li: HTMLElement) => li.textContent)).toEqual(['Un', 'Deux']);
  });

  it('colore l’encadré, en bleu ou en alerte', () => {
    const { unmount } = render(<Encadre icone={<span />} titre="Offerte">Sans minimum.</Encadre>);
    expect(classes(screen.getByTestId('encadre'))).toContain('bg-[#EEF1F8]');
    expect(screen.getByText('Offerte')).toBeInTheDocument();
    unmount();
    render(<Encadre icone={<span />} titre="À valider" alerte>Juriste.</Encadre>);
    expect(classes(screen.getByTestId('encadre'))).toContain('bg-[#FFD3DB]');
  });

  it('met la première colonne du tableau en gras', () => {
    render(<Tableau entetes={['Destination', 'Délai']} lignes={[['Québec', '2 à 4 jours'], ['Ontario', '3 à 5 jours']]} />);
    expect(screen.getAllByRole('columnheader').map((th: HTMLElement) => th.textContent)).toEqual(['Destination', 'Délai']);
    const cellules = screen.getAllByRole('cell');
    expect(cellules.map((td: HTMLElement) => td.textContent)).toEqual(['Québec', '2 à 4 jours', 'Ontario', '3 à 5 jours']);
    expect(classes(cellules[0] as HTMLElement)).toContain('font-bold');
    expect(classes(cellules[1] as HTMLElement)).not.toContain('font-bold');
  });

  it('numérote les étapes', () => {
    render(<Etapes etapes={[{ titre: 'Déclarez', texte: 'a' }, { titre: 'Emballez', texte: 'b' }, { titre: 'Déposez', texte: 'c' }]} />);
    const etapes = screen.getAllByRole('listitem');
    expect(etapes.map((e: HTMLElement) => within(e).getByText(/^[0-9]$/).textContent)).toEqual(['1', '2', '3']);
  });

  it('marque ce qui reste à compléter', () => {
    render(<p>Numéro : <AComplete>NEQ</AComplete></p>);
    const marque = screen.getByText('NEQ');
    expect(marque.tagName).toBe('MARK');
    expect(classes(marque)).toContain('text-[var(--vs-accent)]');
  });
});
__VICTO_FIN_11__
cat > 'tickets/tests/page-conditions.test.tsx' <<'__VICTO_FIN_12__'
import { render, screen, within } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import PageConditions from '../src/app/conditions-de-vente/page';

describe('page Conditions de vente', () => {
  it('assemble titre, menu marqué et les huit sections dans l’ordre', () => {
    render(<PageConditions />);
    expect(screen.getByRole('heading', { level: 1, name: 'Conditions de vente' })).toBeInTheDocument();
    expect(within(screen.getByRole('navigation', { name: 'Aide' })).getByRole('link', { name: 'Conditions de vente' })).toHaveAttribute('aria-current', 'page');
    expect(screen.getAllByRole('heading', { level: 2 }).map((h: HTMLElement) => h.textContent)).toEqual([
      '1. Qui sommes-nous', '2. Produits et prix', '3. Commande et paiement', '4. Livraison',
      '5. Annulation et remboursement', '6. Retours', '7. Garantie légale', '8. Droit applicable',
    ]);
  });

  it('avertit qu’il faut faire valider le texte, et marque l’identité à compléter', () => {
    render(<PageConditions />);
    expect(screen.getByText('À faire valider par un juriste')).toBeInTheDocument();
    expect(screen.getByRole('article').querySelectorAll('mark')).toHaveLength(5);
  });

  it('renvoie vers les pages Livraison et Retours', () => {
    render(<PageConditions />);
    const article = screen.getByRole('article');
    expect(within(article).getByRole('link', { name: 'Livraison' })).toHaveAttribute('href', '/livraison');
    expect(within(article).getByRole('link', { name: 'Retours et échanges' })).toHaveAttribute('href', '/retours');
  });
});
__VICTO_FIN_12__
cat > 'tickets/tests/page-confidentialite.test.tsx' <<'__VICTO_FIN_13__'
import { render, screen, within } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import PageConfidentialite from '../src/app/confidentialite/page';

describe('page Confidentialité', () => {
  it('assemble titre, menu marqué et sections dans l’ordre', () => {
    render(<PageConfidentialite />);
    expect(screen.getByRole('heading', { level: 1, name: 'Confidentialité' })).toBeInTheDocument();
    expect(within(screen.getByRole('navigation', { name: 'Aide' })).getByRole('link', { name: 'Confidentialité' })).toHaveAttribute('aria-current', 'page');
    expect(screen.getAllByRole('heading', { level: 2 }).map((h: HTMLElement) => h.textContent)).toEqual([
      'Responsable de la protection des renseignements personnels', 'Ce que nous recueillons, et pourquoi',
      'Votre consentement', 'Qui y a accès', 'Durée de conservation', 'Vos droits', 'Incidents de confidentialité',
    ]);
  });

  it('dit ce qui est recueilli, et ce qui reste à compléter', () => {
    render(<PageConfidentialite />);
    expect(screen.getAllByRole('row')).toHaveLength(6);
    expect(screen.getByText("Commission d'accès à l'information du Québec", { exact: false })).toBeInTheDocument();
    expect(screen.getByRole('article').querySelectorAll('mark')).toHaveLength(4);
  });
});
__VICTO_FIN_13__
cat > 'tickets/tests/page-contact.test.tsx' <<'__VICTO_FIN_14__'
import { render, screen, within } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import PageContact from '../src/app/contact/page';

describe('page Contact', () => {
  it('assemble titre, menu marqué, formulaire et coordonnées', () => {
    render(<PageContact />);
    expect(screen.getByRole('heading', { level: 1, name: 'Contact' })).toBeInTheDocument();
    expect(within(screen.getByRole('navigation', { name: 'Aide' })).getByRole('link', { name: 'Contact' })).toHaveAttribute('aria-current', 'page');
    expect(screen.getByRole('form', { name: 'Écrire au service client' })).toBeInTheDocument();
    const coordonnees = screen.getByRole('complementary', { name: 'Nos coordonnées' });
    for (const t of ['Courriel', 'Téléphone', 'Heures', 'Adresse']) expect(within(coordonnees).getByText(t)).toBeInTheDocument();
    expect(coordonnees.querySelectorAll('mark')).toHaveLength(3);
  });
});
__VICTO_FIN_14__
cat > 'tickets/tests/page-livraison.test.tsx' <<'__VICTO_FIN_15__'
import { render, screen, within } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import PageLivraison from '../src/app/livraison/page';

describe('page Livraison', () => {
  it('assemble titre, menu marqué et sections dans l’ordre', () => {
    render(<PageLivraison />);
    expect(screen.getByRole('heading', { level: 1, name: 'Livraison' })).toBeInTheDocument();
    expect(within(screen.getByRole('navigation', { name: 'Aide' })).getByRole('link', { name: 'Livraison' })).toHaveAttribute('aria-current', 'page');
    expect(screen.getAllByRole('heading', { level: 2 }).map((h: HTMLElement) => h.textContent)).toEqual([
      'Délais', 'Suivre votre colis', 'Livraison hors du Canada', 'Colis en retard, perdu ou abîmé',
    ]);
  });

  it('donne les délais par destination', () => {
    render(<PageLivraison />);
    const lignes = screen.getAllByRole('row').slice(1).map((r: HTMLElement) => within(r).getAllByRole('cell')[0]?.textContent);
    expect(lignes).toEqual(['Québec', 'Ontario et Maritimes', 'Prairies et Colombie-Britannique', 'Territoires']);
  });

  it('renvoie vers le compte et les conditions, et marque ce qui reste à confirmer', () => {
    render(<PageLivraison />);
    const article = screen.getByRole('article');
    expect(within(article).getByRole('link', { name: 'Mes commandes' })).toHaveAttribute('href', '/compte/commandes');
    expect(within(article).getByRole('link', { name: 'conditions de vente' })).toHaveAttribute('href', '/conditions-de-vente');
    expect(article.querySelectorAll('mark')).toHaveLength(2);
  });
});
__VICTO_FIN_15__
cat > 'tickets/tests/page-retours.test.tsx' <<'__VICTO_FIN_16__'
import { render, screen, within } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import PageRetours from '../src/app/retours/page';

describe('page Retours et échanges', () => {
  it('assemble titre, menu marqué et sections dans l’ordre', () => {
    render(<PageRetours />);
    expect(screen.getByRole('heading', { level: 1, name: 'Retours et échanges' })).toBeInTheDocument();
    expect(within(screen.getByRole('navigation', { name: 'Aide' })).getByRole('link', { name: 'Retours et échanges' })).toHaveAttribute('aria-current', 'page');
    expect(screen.getAllByRole('heading', { level: 2 }).map((h: HTMLElement) => h.textContent)).toEqual([
      'Comment faire', 'Conditions', 'Remboursement', 'Article défectueux',
    ]);
  });

  it('explique le retour en trois étapes, depuis le compte', () => {
    render(<PageRetours />);
    const article = screen.getByRole('article');
    for (const t of ['Déclarez le retour', "Emballez l'article", 'Déposez le colis']) expect(within(article).getByText(t)).toBeInTheDocument();
    expect(within(article).getByRole('link', { name: 'Mes commandes' })).toHaveAttribute('href', '/compte/commandes');
  });

  it('marque les choix qui restent à faire', () => {
    render(<PageRetours />);
    expect(screen.getByRole('article').querySelectorAll('mark')).toHaveLength(2);
  });
});
__VICTO_FIN_16__
TESTS=(FormulaireContact.test.tsx GabaritAide.test.tsx blocs-aide.test.tsx page-conditions.test.tsx page-confidentialite.test.tsx page-contact.test.tsx page-livraison.test.tsx page-retours.test.tsx)

# ------------------------------------------------------------ 106i : les liens d'aide du pied de page
cat > /tmp/victo-analyse-pied.py <<'__ANALYSE__'
"""Lit src/lib/navigation.ts : trouve dans COLONNES_PIED les liens d'aide (par leur libellé)
et renvoie, en JSON, ceux dont l'adresse doit changer, recopiés exactement."""
import json, re, sys
s = open(sys.argv[1], encoding='utf-8').read()
i = s.find('COLONNES_PIED')
if i < 0:
    print(json.dumps({'erreur': 'COLONNES_PIED introuvable'})); sys.exit(0)
# le tableau de COLONNES_PIED seulement : du premier « [ » qui suit jusqu'au crochet qui le ferme
debut = s.find('[', i); profondeur = 0; fin = -1
for k in range(debut, len(s)):
    if s[k] == '[': profondeur += 1
    elif s[k] == ']':
        profondeur -= 1
        if profondeur == 0: fin = k; break
if debut < 0 or fin < 0:
    print(json.dumps({'erreur': 'tableau COLONNES_PIED illisible'})); sys.exit(0)
region = s[debut:fin + 1]
CIBLES = [('livraison', '/livraison'), ('retour', '/retours'), ('contact', '/contact'),
          ('condition', '/conditions-de-vente'), ('confidentialit', '/confidentialite')]
motif = re.compile(r"""\{\s*label:\s*(['"])(?P<label>[^'"]+)\1\s*,\s*href:\s*(['"])(?P<href>[^'"]*)\3\s*,?\s*\}""")
changements, justes = [], []
for m in motif.finditer(region):
    label, href = m.group('label'), m.group('href')
    cible = next((c for mot, c in CIBLES if mot in label.lower()), None)
    if cible is None: continue
    if href == cible: justes.append(label); continue
    ancien = m.group(0)
    debut = m.start('href') - m.start(0)
    nouveau = ancien[:debut] + cible + ancien[debut + len(href):]
    changements.append({'label': label, 'ancien': ancien, 'nouveau': nouveau, 'cible': cible})
print(json.dumps({'changements': changements, 'justes': justes}, ensure_ascii=False))
__ANALYSE__
python3 /tmp/victo-analyse-pied.py src/lib/navigation.ts > /tmp/victo-pied.json
python3 - <<'PYG'
import json, sys
d = json.load(open('/tmp/victo-pied.json', encoding='utf-8'))
if 'erreur' in d:
    print(f"  ! pied de page : {d['erreur']} — pas de ticket 106i"); sys.exit(0)
if d['justes']:
    print("  ✓ liens d'aide déjà justes : " + ', '.join(d['justes']))
ch = d['changements']
if not ch:
    if not d['justes']:
        print("  ! aucun lien d'aide trouvé dans le pied de page — pas de ticket 106i (dis-moi où les mettre)")
    sys.exit(0)
remplacements = '\n'.join(f"- remplace exactement `{c['ancien']}`\n  par `{c['nouveau']}`" for c in ch)
spec = f"""TICKET 106i — les liens d'aide du pied de page mènent aux pages d'aide

Modifie `src/lib/navigation.ts`. Dans `COLONNES_PIED`, seulement ces entrées changent
d'adresse ; leur libellé, leur écriture et tout le reste du fichier restent identiques.

## Règles absolues
- **Ne modifie aucun test.** Ne modifie aucun autre fichier.

## Les remplacements
{remplacements}

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
"""
lignes = '\n'.join(f"    expect(source).toContain({json.dumps(c['nouveau'], ensure_ascii=False)});\n    expect(source).not.toContain({json.dumps(c['ancien'], ensure_ascii=False)});" for c in ch)
test = f"""import {{ readFileSync }} from 'node:fs';
import {{ describe, expect, it }} from 'vitest';

describe('pied de page — liens d’aide', () => {{
  it('mène aux pages d’aide', () => {{
    const source = readFileSync('src/lib/navigation.ts', 'utf8');
{lignes}
  }});
}});
"""
open('tickets/106i-pied-aide.md', 'w', encoding='utf-8').write(spec)
open('tickets/tests/pied-aide.test.ts', 'w', encoding='utf-8').write(test)
with open('tickets/manifest-106.tsv', 'a', encoding='utf-8') as m:
    m.write('106i\tsrc/lib/navigation.ts\ttests/pied-aide.test.ts\ttickets/106i-pied-aide.md\t\t\t\n')
print("  ✓ ticket 106i généré : " + ', '.join(f"{c['label']} → {c['cible']}" for c in ch))
PYG
[ -f tickets/tests/pied-aide.test.ts ] && TESTS+=(pied-aide.test.ts)
for t in "${TESTS[@]}"; do git ls-files --error-unmatch "tests/$t" >/dev/null 2>&1 || rm -f "tests/$t"; done
ok "$(wc -l < tickets/manifest-106.tsv) tickets écrits, manifeste tickets/manifest-106.tsv"

# ------------------------------------------------------------ contrôle et budgets
CTL="$(mktemp -d)"; mkdir -p "$CTL/tests"
cp tickets/106*.md "$CTL/"; for t in "${TESTS[@]}"; do cp "tickets/tests/$t" "$CTL/tests/"; done
python3 outils/controle-lot.py "$CTL" src/styles/tokens.css || annuler "le contrôle a levé une alerte"
rm -rf "$CTL"
python3 - tickets/manifest-106.tsv <<'PYB' || annuler "un ticket dépasse le budget de contexte"
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
npm run --silent test >/tmp/victo-test.log 2>&1 || { grep -E "FAIL|×|→" /tmp/victo-test.log | head; annuler "tests rouges"; }
ok "base verte"
git add -A -- tickets tests
git diff --cached --quiet && ok "rien de nouveau à commiter" || {
  git commit -q -m "chore(tickets): lot 106 — pages d'aide"; ok "commit $(git rev-parse --short HEAD)"; }
trap - ERR
[ -z "$(git status --porcelain)" ] || mort "arbre sale après commit : $(git status --porcelain | head -3)"
if GIT_TERMINAL_PROMPT=0 git push -q origin main 2>/tmp/victo-push.log; then ok "poussé sur GitHub"
else info "push refusé (voir /tmp/victo-push.log) : le harnais poussera au premier vert"; fi

printf '\nPrêt :\n\n    MANIFEST=tickets/manifest-106.tsv ./run.sh\n\n%s tickets. Compte deux heures à deux heures et demie.\n' "$(wc -l < tickets/manifest-106.tsv)"
