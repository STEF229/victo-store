/**
 * Exécute la suite tout de suite si le résultat est déjà là (mode démonstration), ou à son arrivée
 * (mode Medusa). En démonstration, le déroulement reste donc exactement synchrone.
 */
export function quand<T>(resultat: T | Promise<T>, suite: (valeur: T) => void): void {
  if (resultat instanceof Promise) void resultat.then(suite);
  else suite(resultat);
}
