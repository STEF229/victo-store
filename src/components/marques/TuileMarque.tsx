import { ArrowUpRight } from 'lucide-react';
import Link from 'next/link';
import { hrefMarque } from '@/lib/catalogue';
import { libelleProduits, type ResumeMarque } from '@/lib/marques';

export function TuileMarque({ resume, rang }: { resume: ResumeMarque; rang: number }) {
  const fond =
    rang % 3 === 0 ? 'bg-[#EEF1F8]' : rang % 3 === 1 ? 'bg-[#E9E4DA]' : 'bg-[var(--vs-surface)]';

  return (
    <Link
      href={hrefMarque(resume.marque)}
      data-testid={`tuile-marque-${resume.marque.slug}`}
      className={`flex h-[150px] flex-col justify-between rounded-[20px] p-4 text-[var(--vs-noir)] sm:h-[240px] sm:rounded-[28px] sm:p-7 ${fond}`}
    >
      {resume.enSoldes > 0 ? (
        <span data-testid="tuile-soldes" className="self-start rounded-full bg-[var(--vs-promo)] px-[11px] py-[5px] text-xs font-extrabold text-[var(--vs-blanc)]">
          {`${resume.enSoldes} en soldes`}
        </span>
      ) : (
        <span />
      )}
      <div className="flex items-end justify-between gap-2">
        <div className="flex flex-col gap-1">
          <span className="text-lg font-black uppercase leading-none tracking-[0.04em] sm:text-[34px]">{resume.marque.nom}</span>
          <span data-testid="tuile-produits" className="text-xs text-[var(--vs-gris)] sm:text-sm">{libelleProduits(resume.nombre)}</span>
        </div>
        <span className="hidden h-11 w-11 shrink-0 items-center justify-center rounded-full bg-[var(--vs-blanc)] sm:flex">
          <ArrowUpRight aria-hidden size={18} />
        </span>
      </div>
    </Link>
  );
}
