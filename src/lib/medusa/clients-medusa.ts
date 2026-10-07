import type { Adresse, Client, Commande, DonneesInscription, LigneCommande, StatutCommande } from '@/lib/compte';
import type { Profil } from '@/lib/comptes-locaux';

/** Les champs de Medusa dont le site se sert pour les clients, leurs adresses et leurs commandes. */
export interface AdresseMedusa {
  id: string;
  address_name?: string | null;
  first_name?: string | null;
  last_name?: string | null;
  address_1?: string | null;
  city?: string | null;
  province?: string | null;
  postal_code?: string | null;
  phone?: string | null;
  is_default_shipping?: boolean | null;
}
export interface ClientMedusa {
  email: string;
  first_name?: string | null;
  last_name?: string | null;
  created_at?: string | null;
  addresses?: AdresseMedusa[] | null;
}
export interface CommandeMedusa {
  display_id?: number | null;
  id: string;
  created_at: string;
  status?: string | null;
  fulfillment_status?: string | null;
  items?: { product_handle?: string | null; product_title?: string | null; title?: string | null; subtitle?: string | null;
    variant_title?: string | null; quantity: number; unit_price: number; compare_at_unit_price?: number | null }[] | null;
  shipping_address?: AdresseMedusa | null;
}

const enCents = (montant: number) => Math.round(montant * 100);

export function adresseDepuisMedusa(a: AdresseMedusa): Adresse {
  return {
    id: a.id,
    libelle: a.address_name || 'Adresse',
    nomComplet: [a.first_name, a.last_name].filter(Boolean).join(' '),
    ligne1: a.address_1 ?? '',
    ville: a.city ?? '',
    province: (a.province ?? '').toUpperCase(),
    codePostal: a.postal_code ?? '',
    telephone: a.phone ?? '',
    parDefaut: a.is_default_shipping === true,
  };
}

export function adresseVersMedusa(a: Adresse): Omit<AdresseMedusa, 'id'> & { country_code: string } {
  const [prenom = '', ...reste] = a.nomComplet.trim().split(/\s+/);
  return {
    address_name: a.libelle, first_name: prenom, last_name: reste.join(' '), address_1: a.ligne1, city: a.ville,
    province: a.province.toLowerCase(), postal_code: a.codePostal, phone: a.telephone, country_code: 'ca', is_default_shipping: a.parDefaut,
  };
}

export function clientDepuisMedusa(c: ClientMedusa): Client {
  return {
    prenom: c.first_name ?? '',
    nom: c.last_name ?? '',
    courriel: c.email.toLowerCase(),
    membreDepuis: (c.created_at ?? new Date().toISOString()).slice(0, 10),
    adresses: (c.addresses ?? []).map(adresseDepuisMedusa),
  };
}

export function statutDepuisMedusa(c: CommandeMedusa): StatutCommande {
  if (c.status === 'canceled') return 'annulee';
  if (c.fulfillment_status === 'delivered') return 'livree';
  if (c.fulfillment_status === 'shipped' || c.fulfillment_status === 'partially_shipped' || c.fulfillment_status === 'partially_delivered') return 'expediee';
  return 'preparation';
}

export function commandeDepuisMedusa(c: CommandeMedusa): Commande {
  const lignes: LigneCommande[] = (c.items ?? []).map((i) => ({
    slug: i.product_handle ?? '',
    nom: i.product_title ?? i.title ?? '',
    marque: i.subtitle ?? '',
    taille: i.variant_title ?? '',
    quantite: i.quantity,
    prixCents: enCents(i.unit_price),
    economieCents: typeof i.compare_at_unit_price === 'number' && i.compare_at_unit_price > i.unit_price ? enCents(i.compare_at_unit_price - i.unit_price) : 0,
  }));
  return {
    numero: `VS-${c.display_id ?? c.id}`,
    date: c.created_at.slice(0, 10),
    statut: statutDepuisMedusa(c),
    lignes,
    adresseId: c.shipping_address?.id ?? '',
    ...(c.shipping_address ? { adresse: adresseDepuisMedusa(c.shipping_address) } : {}),
    paiement: 'Paiement manuel (essai)',
    suivi: null,
  };
}

async function appel<T>(chemin: string, methode = 'GET', corps?: unknown): Promise<{ ok: boolean; donnees: T | null }> {
  const r = await fetch(`/api/medusa/${chemin}`, {
    method: methode, headers: { 'content-type': 'application/json' }, ...(corps !== undefined ? { body: JSON.stringify(corps) } : {}),
  });
  return { ok: r.ok, donnees: r.ok ? ((await r.json()) as T) : null };
}

export async function lireClientMedusa(): Promise<Client | null> {
  const { donnees } = await appel<{ customer: ClientMedusa }>('store/customers/me?fields=*addresses');
  return donnees ? clientDepuisMedusa(donnees.customer) : null;
}

export async function lireCommandesMedusa(): Promise<Commande[]> {
  const { donnees } = await appel<{ orders: CommandeMedusa[] }>('store/orders?fields=*items,*shipping_address&order=-created_at&limit=50');
  return (donnees?.orders ?? []).map(commandeDepuisMedusa);
}

export async function connecterClient(courriel: string, motDePasse: string): Promise<boolean> {
  return (await appel('auth/customer/emailpass', 'POST', { email: courriel.trim().toLowerCase(), password: motDePasse })).ok;
}

/** Inscription : identité, fiche client, puis connexion. Null si Medusa refuse (courriel déjà utilisé, par exemple). */
export async function inscrireClient(d: DonneesInscription): Promise<Client | null> {
  const courriel = d.courriel.trim().toLowerCase();
  if (!(await appel('auth/customer/emailpass/register', 'POST', { email: courriel, password: d.motDePasse })).ok) return null;
  if (!(await appel('store/customers', 'POST', { email: courriel, first_name: d.prenom.trim(), last_name: d.nom.trim() })).ok) return null;
  if (!(await connecterClient(courriel, d.motDePasse))) return null;
  return lireClientMedusa();
}

export async function deconnecterClient(): Promise<void> {
  await appel('deconnexion', 'POST');
}

export async function modifierProfilClient(profil: Profil): Promise<Client | null> {
  const { ok } = await appel('store/customers/me', 'POST', { first_name: profil.prenom.trim(), last_name: profil.nom.trim() });
  return ok ? lireClientMedusa() : null;
}

/** Aligne le carnet d'adresses Medusa sur la liste voulue ; renvoie le client à jour. */
export async function synchroniserAdresses(actuelles: Adresse[], voulues: Adresse[]): Promise<Client | null> {
  const memes = (a: Adresse, b: Adresse) => JSON.stringify(adresseVersMedusa(a)) === JSON.stringify(adresseVersMedusa(b));
  for (const a of actuelles) {
    if (!voulues.some((v) => v.id === a.id)) await appel(`store/customers/me/addresses/${a.id}`, 'DELETE');
  }
  for (const v of voulues) {
    const avant = actuelles.find((a) => a.id === v.id);
    if (!avant) await appel('store/customers/me/addresses', 'POST', adresseVersMedusa(v));
    else if (!memes(avant, v)) await appel(`store/customers/me/addresses/${v.id}`, 'POST', adresseVersMedusa(v));
  }
  return lireClientMedusa();
}
