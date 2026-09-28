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
