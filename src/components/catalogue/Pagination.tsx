'use client';

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

  return (
    <nav 
      aria-label="Pagination" 
      data-testid="pagination"
      className={className}
    >
      <button
        type="button"
        aria-label="Page précédente"
        disabled={page <= 1}
        onClick={handlePrevious}
        className="px-3 py-2 text-sm font-medium rounded-md border border-[var(--vs-ligne)] bg-[var(--vs-surface)] hover:bg-[var(--vs-accent)] hover:text-white focus:outline-none focus:ring-2 focus:ring-[var(--vs-accent)] disabled:opacity-50 disabled:cursor-not-allowed"
      >
        Page précédente
      </button>
      
      <span 
        data-testid="pagination-etat" 
        className="mx-2 px-3 py-2 text-sm font-medium"
      >
        Page {page} sur {pages}
      </span>
      
      <button
        type="button"
        aria-label="Page suivante"
        disabled={page >= pages}
        onClick={handleNext}
        className="px-3 py-2 text-sm font-medium rounded-md border border-[var(--vs-ligne)] bg-[var(--vs-surface)] hover:bg-[var(--vs-accent)] hover:text-white focus:outline-none focus:ring-2 focus:ring-[var(--vs-accent)] disabled:opacity-50 disabled:cursor-not-allowed"
      >
        Page suivante
      </button>
    </nav>
  );
}
