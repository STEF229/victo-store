TICKET 102k — tableau de bord du compte

Crée `src/app/compte/page.tsx`. Page **client** (`'use client'`), un seul export :
l'export par défaut `PageCompte`.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index. La
  dernière commande se lit par déstructuration : `const [derniere] = commandes;`
  (elle vaut alors `Commande | undefined`). Lire `CLASSES_STATUT[x.statut]` est permis.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Aucun export nommé. Chaque `className` est écrit exactement comme ci-dessous.
- Apostrophes droites dans les textes.

## Bloc d'imports exact
```tsx
'use client';

import Link from 'next/link';
import { CarteCommande } from '@/components/compte/CarteCommande';
import { CARTE, CLASSES_STATUT, LIBELLES_STATUT, LIEN, SOUS_TITRE, TITRE_PAGE } from '@/components/compte/compte-affichage';
import { EspaceClient } from '@/components/compte/EspaceClient';
import { useSession } from '@/components/compte/SessionProvider';
import { FilAriane } from '@/components/produit/FilAriane';
import { SiteFooter } from '@/components/ui/SiteFooter';
import { SiteHeader } from '@/components/ui/SiteHeader';
import { commandesDe, formaterDate, formaterMois, type Client } from '@/lib/compte';
import { COLONNES_PIED, NAV } from '@/lib/navigation';
```

## Le contenu — fonction locale, non exportée
Taille attendue : ~95 lignes.

`function Tableau({ client }: { client: Client })` avec
`const commandes = commandesDe(client);`, `const [derniere] = commandes;` et
`const adresse = client.adresses.find((a) => a.parDefaut);`, rend :
```tsx
<>
  <div className="flex flex-col gap-2.5">
    <h1 className={TITRE_PAGE}>{`Bonjour, ${client.prenom}`}</h1>
    <p className={SOUS_TITRE}>{`Membre depuis ${formaterMois(client.membreDepuis)}`}</p>
  </div>
  <div className="grid gap-5 lg:grid-cols-3">
    <section data-testid="carte-derniere-commande" className={CARTE}>
      <h2 className="text-lg font-extrabold text-[var(--vs-noir)]">Dernière commande</h2>
      {derniere ? (
        <>
          <p className="text-[15px] font-bold">{`${derniere.numero} · ${formaterDate(derniere.date)}`}</p>
          <span className={`self-start ${CLASSES_STATUT[derniere.statut]}`}>{LIBELLES_STATUT[derniere.statut]}</span>
          <Link href="/compte/commandes" className={LIEN}>Voir mes commandes</Link>
        </>
      ) : (
        <>
          <p className={SOUS_TITRE}>Aucune commande pour l'instant.</p>
          <Link href="/soldes" className={LIEN}>Voir les soldes</Link>
        </>
      )}
    </section>
    <section data-testid="carte-adresse" className={CARTE}>
      <h2 className="text-lg font-extrabold text-[var(--vs-noir)]">Adresse de livraison</h2>
      {adresse ? (
        <p className="text-[15px] leading-relaxed">
          {adresse.nomComplet}<br />{adresse.ligne1}<br />{`${adresse.ville} (${adresse.province}) ${adresse.codePostal}`}
        </p>
      ) : (
        <p className={SOUS_TITRE}>Aucune adresse enregistrée.</p>
      )}
    </section>
    <section className="flex flex-col gap-3.5 rounded-3xl bg-[var(--vs-accent)] p-[26px] text-[var(--vs-blanc)]">
      <h2 className="text-lg font-extrabold">Votre avantage</h2>
      <p className="text-3xl font-black">−10 %</p>
      <p className="text-sm leading-relaxed">sur votre prochaine commande avec le code BIENVENUE10.</p>
    </section>
  </div>
  <section className="flex flex-col gap-4">
    <h2 className="text-lg font-extrabold text-[var(--vs-noir)]">Commandes récentes</h2>
    {commandes.length > 0
      ? commandes.slice(0, 2).map((c) => <CarteCommande key={c.numero} commande={c} />)
      : <p className={SOUS_TITRE}>Vos commandes apparaîtront ici.</p>}
  </section>
</>
```

## La page
```tsx
export default function PageCompte() {
  const session = useSession();
  return (
    <>
      <SiteHeader navItems={NAV} />
      <main className="mx-auto w-full max-w-[1440px] px-5 pb-24 lg:px-20">
        <FilAriane items={[{ label: 'Accueil', href: '/' }, { label: 'Mon compte' }]} />
        <EspaceClient actif="tableau">
          {session.client && <Tableau client={session.client} />}
        </EspaceClient>
      </main>
      <SiteFooter colonnes={COLONNES_PIED} />
    </>
  );
}
```
Le contenu n'est construit que si `session.client` existe : `EspaceClient` affiche
lui-même l'invitation à se connecter dans le cas contraire.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
