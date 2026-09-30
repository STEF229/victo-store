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
