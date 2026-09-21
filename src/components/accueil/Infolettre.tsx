'use client';

import { useState, type FormEvent } from 'react';

export function Infolettre() {
  const [email, setEmail] = useState('');
  const [submitted, setSubmitted] = useState(false);
  const [error, setError] = useState('');

  const envoyer = (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    
    if (!email.includes('@')) {
      setError('Entrez une adresse courriel valide.');
      return;
    }
    
    setSubmitted(true);
  };

  return (
    <section data-testid="infolettre">
      <div className="grid grid-cols-1 items-center gap-8 rounded-[28px] bg-[var(--vs-accent)] text-[var(--vs-blanc)] lg:grid-cols-2">
        <div>
          <h2 className="text-4xl font-900">−10 % sur votre première commande.</h2>
          <p>Les arrivages et les ventes privées, avant tout le monde.</p>
        </div>
        
        <div>
          {submitted ? (
            <p data-testid="infolettre-merci">Merci, votre code arrive par courriel.</p>
          ) : (
            <form 
              data-testid="infolettre-formulaire" 
              noValidate 
              onSubmit={envoyer}
              className="flex flex-col gap-3 sm:flex-row"
            >
              <label htmlFor="infolettre-courriel" className="sr-only">Votre courriel</label>
              <input
                id="infolettre-courriel"
                type="email"
                placeholder="Votre courriel"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="flex-1 rounded-full bg-[var(--vs-blanc)] px-6 py-4 text-[var(--vs-noir)] focus:outline-none focus:ring-2 focus:ring-[var(--vs-noir)]"
              />
              <button 
                type="submit" 
                className="rounded-full bg-[var(--vs-noir)] px-6 py-4 text-[var(--vs-blanc)] hover:bg-[#1E1E26] focus:outline-none focus:ring-2 focus:ring-[var(--vs-noir)]"
              >
                Recevoir le code
              </button>
              {error && <p role="alert" className="mt-2 text-center text-[var(--vs-blanc)]">{error}</p>}
            </form>
          )}
        </div>
      </div>
    </section>
  );
}
