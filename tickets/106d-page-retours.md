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
