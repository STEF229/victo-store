import type { ReactNode } from 'react';

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
