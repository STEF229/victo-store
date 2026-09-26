'use client';

import { ChevronLeft, ChevronRight } from 'lucide-react';

interface PaginationProps {
  page: number;
  pages: number;
  onChange: (page: number) => void;
  className?: string;
}

export function Pagination({ page, pages, onChange, className = '' }: PaginationProps) {
  if (pages <= 1) {
    return null;
  }

  const handlePrevious = () => {
    if (page > 1) {
      onChange(page - 1);
    }
  };

  const handleNext = () => {
    if (page < pages) {
      onChange(page + 1);
    }
  };

  const handlePageChange = (newPage: number) => {
    if (newPage !== page) {
      onChange(newPage);
    }
  };

  return (
    <nav
      aria-label="Pagination"
      data-testid="pagination"
      className={`mt-12 flex flex-col items-center gap-3.5 ${className}`}
    >
      <div className="flex items-center gap-2">
        <button
          type="button"
          aria-label="Page précédente"
          disabled={page <= 1}
          className={page <= 1
            ? 'flex h-[46px] w-[46px] items-center justify-center rounded-full border-[1.5px] cursor-not-allowed border-[var(--vs-ligne)] text-[#B5B5BA]'
            : 'flex h-[46px] w-[46px] items-center justify-center rounded-full border-[1.5px] border-[var(--vs-noir)] text-[var(--vs-noir)]'}
          onClick={handlePrevious}
        >
          <ChevronLeft aria-hidden size={18} />
        </button>

        {pages <= 7 && Array.from({ length: pages }, (_, i) => i + 1).map((n) => (
          <button
            key={n}
            type="button"
            aria-label={`Page ${n}`}
            aria-current={n === page ? 'page' : undefined}
            className={n === page
              ? 'flex h-[46px] min-w-[46px] items-center justify-center rounded-full border-[1.5px] px-3 text-[15px] font-semibold border-[var(--vs-noir)] bg-[var(--vs-noir)] text-[var(--vs-blanc)]'
              : 'flex h-[46px] min-w-[46px] items-center justify-center rounded-full border-[1.5px] px-3 text-[15px] font-semibold border-[var(--vs-ligne)] bg-[var(--vs-blanc)] text-[var(--vs-noir)]'}
            onClick={() => handlePageChange(n)}
          >
            {n}
          </button>
        ))}

        <button
          type="button"
          aria-label="Page suivante"
          disabled={page >= pages}
          className={page >= pages
            ? 'flex h-[46px] w-[46px] items-center justify-center rounded-full border-[1.5px] cursor-not-allowed border-[var(--vs-ligne)] text-[#B5B5BA]'
            : 'flex h-[46px] w-[46px] items-center justify-center rounded-full border-[1.5px] border-[var(--vs-noir)] text-[var(--vs-noir)]'}
          onClick={handleNext}
        >
          <ChevronRight aria-hidden size={18} />
        </button>
      </div>
      <span data-testid="pagination-etat" className="text-sm text-[var(--vs-gris)]">
        Page {page} sur {pages}
      </span>
    </nav>
  );
}
