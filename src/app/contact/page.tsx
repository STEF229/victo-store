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
