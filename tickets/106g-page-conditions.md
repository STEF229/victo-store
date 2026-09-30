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
