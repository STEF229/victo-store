TICKET 117c — la confirmation de commande

Crée `src/app/commande/confirmation/page.tsx`. Composant serveur asynchrone : lit le numéro dans l'adresse (`?numero=VS-7`), affiche les prochaines étapes et le lien de suivi.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index, le fichier utilise
  `.find`, `.map`, `.filter`, `.reduce` et la déstructuration, jamais `t[i]`. Recopie-le tel quel.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Chaque texte affiché et chaque `className` sont recopiés exactement.

## Fichier complet
Taille attendue : ~40 lignes.
```tsx
import { CircleCheck } from 'lucide-react';
import Link from 'next/link';
import { BOUTON_PRINCIPAL, LIEN, SOUS_TITRE, TITRE_PAGE } from '@/components/compte/compte-affichage';
import { FilAriane } from '@/components/produit/FilAriane';
import { SiteFooter } from '@/components/ui/SiteFooter';
import { SiteHeader } from '@/components/ui/SiteHeader';
import { COLONNES_PIED, NAV } from '@/lib/navigation';

export default async function PageConfirmation({ searchParams }: { searchParams: Promise<{ numero?: string | string[] }> }) {
  const { numero } = await searchParams;
  const n = (Array.isArray(numero) ? numero.join('') : numero ?? '').trim();
  return (
    <>
      <SiteHeader navItems={NAV} />
      <main className="mx-auto w-full max-w-[1440px] px-5 pb-24 lg:px-20">
        <FilAriane items={[{ label: 'Accueil', href: '/' }, { label: 'Commande confirmée' }]} />
        <section data-testid="commande-confirmee" className="flex max-w-[720px] flex-col gap-6">
          <CircleCheck aria-hidden size={56} />
          <h1 className={TITRE_PAGE}>Merci, votre commande est confirmée</h1>
          <p className={SOUS_TITRE}>{n ? `Commande ${n} · une confirmation vous sera envoyée par courriel.` : 'Une confirmation vous sera envoyée par courriel.'}</p>
          <ol className="grid gap-3 sm:grid-cols-3">
            <li className="rounded-2xl border-[1.5px] border-[var(--vs-ligne)] p-4 text-[15px]"><strong>Aujourd’hui</strong><br />Commande reçue.</li>
            <li className="rounded-2xl border-[1.5px] border-[var(--vs-ligne)] p-4 text-[15px]"><strong>Sous 48 h</strong><br />Préparée et remise au transporteur.</li>
            <li className="rounded-2xl border-[1.5px] border-[var(--vs-ligne)] p-4 text-[15px]"><strong>2 à 4 jours ouvrables</strong><br />Livrée chez vous.</li>
          </ol>
          <div className="flex flex-wrap gap-4">
            {n && <Link href={`/compte/commandes/${encodeURIComponent(n)}`} className={`${BOUTON_PRINCIPAL} sm:w-auto`}>Suivre ma commande</Link>}
            <Link href="/" className={LIEN}>Continuer mes achats</Link>
          </div>
        </section>
      </main>
      <SiteFooter colonnes={COLONNES_PIED} />
    </>
  );
}
```

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
