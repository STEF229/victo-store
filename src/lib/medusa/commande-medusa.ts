import type { DonneesAdresse } from '@/lib/adresses';

/** Les étapes d'une commande dans Medusa, par la passerelle (/api/medusa). Montants en dollars chez Medusa, en cents ici. */
export interface LigneRecap {
  id: string;
  titre: string;
  marque: string;
  taille: string;
  quantite: number;
  totalCents: number;
}
export interface RecapCommande {
  lignes: LigneRecap[];
  sousTotalCents: number;
  livraisonCents: number;
  taxesCents: number;
  totalCents: number;
  livraisonChoisie: boolean;
}
export interface OptionLivraison {
  id: string;
  nom: string;
  montantCents: number;
}
type PanierBrut = {
  items?: { id: string; product_title?: string | null; title?: string | null; product_subtitle?: string | null; variant_title?: string | null; quantity: number; unit_price: number }[] | null;
  shipping_total?: number | null;
  tax_total?: number | null;
  total?: number | null;
  shipping_methods?: { id: string }[] | null;
};

const enCents = (montant: number | null | undefined) => Math.round((montant ?? 0) * 100);

async function appel<T>(chemin: string, methode = 'GET', corps?: unknown): Promise<T> {
  const r = await fetch(`/api/medusa/${chemin}`, {
    method: methode, headers: { 'content-type': 'application/json' }, ...(corps !== undefined ? { body: JSON.stringify(corps) } : {}),
  });
  if (!r.ok) throw new Error(`Medusa a répondu ${r.status} pour ${methode} ${chemin}`);
  return (await r.json()) as T;
}

export function recapDepuisMedusa(p: PanierBrut): RecapCommande {
  const lignes = (p.items ?? []).map((i) => ({
    id: i.id, titre: i.product_title ?? i.title ?? '', marque: i.product_subtitle ?? '', taille: i.variant_title ?? '',
    quantite: i.quantity, totalCents: enCents(i.unit_price * i.quantity),
  }));
  return {
    lignes,
    sousTotalCents: lignes.reduce((t, l) => t + l.totalCents, 0),
    livraisonCents: enCents(p.shipping_total),
    taxesCents: enCents(p.tax_total),
    totalCents: enCents(p.total),
    livraisonChoisie: (p.shipping_methods ?? []).length > 0,
  };
}

export async function lireRecap(panierId: string): Promise<RecapCommande> {
  const r = await appel<{ cart: PanierBrut }>(`store/carts/${panierId}?fields=*items,*shipping_methods,+total,+tax_total,+shipping_total`);
  return recapDepuisMedusa(r.cart);
}

/** L'adresse au format d'un panier Medusa (Canada). */
export function adresseDePanier(d: DonneesAdresse) {
  const [prenom = '', ...reste] = d.nomComplet.trim().split(/\s+/);
  return { first_name: prenom, last_name: reste.join(' '), address_1: d.ligne1, city: d.ville, province: d.province.toLowerCase(),
    postal_code: d.codePostal, phone: d.telephone, country_code: 'ca' };
}

export async function enregistrerCoordonnees(panierId: string, courriel: string, d: DonneesAdresse): Promise<void> {
  const adresse = adresseDePanier(d);
  await appel(`store/carts/${panierId}`, 'POST', { email: courriel.trim().toLowerCase(), shipping_address: adresse, billing_address: adresse });
}

export async function optionsLivraison(panierId: string): Promise<OptionLivraison[]> {
  const r = await appel<{ shipping_options: { id: string; name: string; amount?: number | null }[] }>(`store/shipping-options?cart_id=${panierId}`);
  return r.shipping_options.map((o) => ({ id: o.id, nom: o.name, montantCents: enCents(o.amount) }));
}

export async function choisirLivraison(panierId: string, optionId: string): Promise<void> {
  await appel(`store/carts/${panierId}/shipping-methods`, 'POST', { option_id: optionId });
}

/** Paiement (manuel en mode essai, Stripe plus tard) puis commande. Renvoie le numéro, ou un message d'erreur. */
export async function commander(panierId: string): Promise<{ numero: string } | { erreur: string }> {
  try {
    const { payment_collection } = await appel<{ payment_collection: { id: string } }>('store/payment-collections', 'POST', { cart_id: panierId });
    await appel(`store/payment-collections/${payment_collection.id}/payment-sessions`, 'POST', { provider_id: 'pp_system_default' });
    const fin = await appel<{ type: string; order?: { id: string; display_id?: number | null }; error?: { message?: string } }>(`store/carts/${panierId}/complete`, 'POST');
    if (fin.type === 'order' && fin.order) return { numero: `VS-${fin.order.display_id ?? fin.order.id}` };
    return { erreur: fin.error?.message ?? 'La commande n’a pas pu être enregistrée.' };
  } catch {
    return { erreur: 'La commande n’a pas pu être enregistrée. Aucun montant n’a été prélevé.' };
  }
}
