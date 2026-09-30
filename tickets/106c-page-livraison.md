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
