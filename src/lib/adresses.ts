import type { Adresse } from '@/lib/compte';

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

export function validerAdresse(d: DonneesAdresse): ErreursAdresse {
  const erreurs: ErreursAdresse = {};
  
  if (!nettoyer(d).libelle) {
    erreurs.libelle = 'Donnez un nom à cette adresse.';
  }
  
  if (!nettoyer(d).nomComplet) {
    erreurs.nomComplet = 'Indiquez le nom du destinataire.';
  }
  
  if (!nettoyer(d).ligne1) {
    erreurs.ligne1 = 'Indiquez le numéro et la rue.';
  }
  
  if (!nettoyer(d).ville) {
    erreurs.ville = 'Indiquez la ville.';
  }
  
  if (!PROVINCES.some((p) => p.code === d.province)) {
    erreurs.province = 'Choisissez une province.';
  }
  
  if (!/^[A-Z]\d[A-Z] \d[A-Z]\d$/.test(normaliserCodePostal(d.codePostal))) {
    erreurs.codePostal = 'Code postal invalide (ex. H2J 2L3).';
  }
  
  if (d.telephone.replace(/\D/g, '').length !== 10) {
    erreurs.telephone = 'Indiquez un numéro à 10 chiffres.';
  }
  
  return erreurs;
}

export function ajouterAdresse(adresses: Adresse[], id: string, d: DonneesAdresse): Adresse[] {
  return [...adresses, { id, ...nettoyer(d), parDefaut: adresses.length === 0 }];
}

export function modifierAdresse(adresses: Adresse[], id: string, d: DonneesAdresse): Adresse[] {
  return adresses.map((a) => (a.id === id ? { ...a, ...nettoyer(d) } : a));
}

export function supprimerAdresse(adresses: Adresse[], id: string): Adresse[] {
  const restantes = adresses.filter((a) => a.id !== id);
  if (restantes.length > 0 && !restantes.some((a) => a.parDefaut)) {
    return restantes.map((a, i) => ({ ...a, parDefaut: i === 0 }));
  }
  return restantes;
}

export function definirParDefaut(adresses: Adresse[], id: string): Adresse[] {
  return adresses.map((a) => ({ ...a, parDefaut: a.id === id }));
}
