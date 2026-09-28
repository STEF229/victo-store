TICKET 104a — adresses : validation et opérations

Crée `src/lib/adresses.ts`. Fonctions **pures** : aucune ne modifie ses arguments,
chacune renvoie un **nouveau** tableau.

## Règles absolues
- TypeScript strict, `noUncheckedIndexedAccess` actif : aucun accès par index
  (`tableau[i]`) ; utilise `.find`, `.map`, `.filter`, `.some`.
- **Ne modifie aucun test.** Ne crée ni ne modifie aucun autre fichier.
- Recopie chaque texte d'erreur exactement.

## Bloc d'imports exact
```ts
import type { Adresse } from '@/lib/compte';
```

## Contenu
Taille attendue : ~95 lignes.
```ts
export type DonneesAdresse = Omit<Adresse, 'id' | 'parDefaut'>;
export type ErreursAdresse = Partial<Record<keyof DonneesAdresse, string>>;

export const PROVINCES: { code: string; nom: string }[] = [
  { code: 'AB', nom: 'Alberta' },
  { code: 'BC', nom: 'Colombie-Britannique' },
  { code: 'MB', nom: 'Manitoba' },
  { code: 'NB', nom: 'Nouveau-Brunswick' },
  { code: 'NL', nom: 'Terre-Neuve-et-Labrador' },
  { code: 'NS', nom: 'Nouvelle-Écosse' },
  { code: 'NT', nom: 'Territoires du Nord-Ouest' },
  { code: 'NU', nom: 'Nunavut' },
  { code: 'ON', nom: 'Ontario' },
  { code: 'PE', nom: 'Île-du-Prince-Édouard' },
  { code: 'QC', nom: 'Québec' },
  { code: 'SK', nom: 'Saskatchewan' },
  { code: 'YT', nom: 'Yukon' },
];

export function adresseVide(nomComplet: string): DonneesAdresse {
  return { libelle: '', nomComplet, ligne1: '', ville: '', province: 'QC', codePostal: '', telephone: '' };
}

export function donneesDe(a: Adresse): DonneesAdresse {
  return { libelle: a.libelle, nomComplet: a.nomComplet, ligne1: a.ligne1, ville: a.ville, province: a.province, codePostal: a.codePostal, telephone: a.telephone };
}

export function normaliserCodePostal(codePostal: string): string {
  const c = codePostal.replace(/[\s-]/g, '').toUpperCase();
  return c.length === 6 ? `${c.slice(0, 3)} ${c.slice(3)}` : codePostal.trim().toUpperCase();
}

function nettoyer(d: DonneesAdresse): DonneesAdresse {
  return {
    libelle: d.libelle.trim(),
    nomComplet: d.nomComplet.trim(),
    ligne1: d.ligne1.trim(),
    ville: d.ville.trim(),
    province: d.province,
    codePostal: normaliserCodePostal(d.codePostal),
    telephone: d.telephone.trim(),
  };
}
```

## Fonctions à écrire
```ts
export function validerAdresse(d: DonneesAdresse): ErreursAdresse;
export function ajouterAdresse(adresses: Adresse[], id: string, d: DonneesAdresse): Adresse[];
export function modifierAdresse(adresses: Adresse[], id: string, d: DonneesAdresse): Adresse[];
export function supprimerAdresse(adresses: Adresse[], id: string): Adresse[];
export function definirParDefaut(adresses: Adresse[], id: string): Adresse[];
```
- **`validerAdresse`** : part de `const erreurs: ErreursAdresse = {};` et ajoute, dans
  cet ordre, seulement les erreurs présentes :
  `libelle` vide après `.trim()` → `'Donnez un nom à cette adresse.'` ;
  `nomComplet` vide après `.trim()` → `'Indiquez le nom du destinataire.'` ;
  `ligne1` vide après `.trim()` → `'Indiquez le numéro et la rue.'` ;
  `ville` vide après `.trim()` → `'Indiquez la ville.'` ;
  `!PROVINCES.some((p) => p.code === d.province)` → `'Choisissez une province.'` ;
  `!/^[A-Z]\d[A-Z] \d[A-Z]\d$/.test(normaliserCodePostal(d.codePostal))` → `'Code postal invalide (ex. H2J 2L3).'` ;
  `d.telephone.replace(/\D/g, '').length !== 10` → `'Indiquez un numéro à 10 chiffres.'`.
  Renvoie `erreurs`.
- **`ajouterAdresse`** : `[...adresses, { id, ...nettoyer(d), parDefaut: adresses.length === 0 }]`
  (la première adresse devient l'adresse par défaut).
- **`modifierAdresse`** : `adresses.map((a) => (a.id === id ? { ...a, ...nettoyer(d) } : a))`.
- **`supprimerAdresse`** — recopie exactement :
  ```ts
  const restantes = adresses.filter((a) => a.id !== id);
  if (restantes.length > 0 && !restantes.some((a) => a.parDefaut)) {
    return restantes.map((a, i) => ({ ...a, parDefaut: i === 0 }));
  }
  return restantes;
  ```
- **`definirParDefaut`** : `adresses.map((a) => ({ ...a, parDefaut: a.id === id }))`.

## Critère de fin
`npm run typecheck`, `npm test` et `npm run build` passent.
