/** Le panier Medusa, recopié du panier du site par la passerelle (/api/medusa). */
export const CLE_PANIER_MEDUSA = 'victo-panier-medusa';

export interface LigneMedusa {
  id: string;
  variant_id: string;
  quantity: number;
}
export interface Voulu {
  variantId: string;
  quantite: number;
}
export interface Operations {
  ajouter: Voulu[];
  modifier: { ligneId: string; quantite: number }[];
  retirer: string[];
}

/** Ce qu'il faut faire au panier Medusa pour qu'il ait exactement les lignes voulues. */
export function operationsSynchro(voulu: Voulu[], actuel: LigneMedusa[]): Operations {
  const ajouter = voulu.filter((v) => !actuel.some((l) => l.variant_id === v.variantId));
  const modifier = actuel.flatMap((l) => {
    const v = voulu.find((x) => x.variantId === l.variant_id);
    return v && v.quantite !== l.quantity ? [{ ligneId: l.id, quantite: v.quantite }] : [];
  });
  const retirer = actuel.filter((l) => !voulu.some((v) => v.variantId === l.variant_id)).map((l) => l.id);
  return { ajouter, modifier, retirer };
}

async function appel<T>(chemin: string, methode = 'GET', corps?: unknown): Promise<T> {
  const reponse = await fetch(`/api/medusa/${chemin}`, {
    method: methode,
    headers: { 'content-type': 'application/json' },
    ...(corps !== undefined ? { body: JSON.stringify(corps) } : {}),
  });
  if (!reponse.ok) throw new Error(`Medusa a répondu ${reponse.status} pour ${methode} ${chemin}`);
  return (await reponse.json()) as T;
}
type ReponsePanier = { cart: { id: string; completed_at?: string | null; items?: LigneMedusa[] | null } };

async function creer(): Promise<ReponsePanier['cart']> {
  return (await appel<ReponsePanier>('store/carts', 'POST', {})).cart;
}
async function lire(id: string): Promise<ReponsePanier['cart'] | null> {
  try {
    const panier = (await appel<ReponsePanier>(`store/carts/${id}?fields=id,completed_at,*items`)).cart;
    return panier.completed_at ? null : panier;
  } catch {
    return null;
  }
}

/** Aligne le panier Medusa sur les lignes voulues ; renvoie son identifiant (vide s'il n'y a rien à garder). */
export async function synchroniserPanier(idActuel: string | null, voulu: Voulu[]): Promise<string> {
  if (!idActuel && voulu.length === 0) return '';
  const panier = (idActuel ? await lire(idActuel) : null) ?? await creer();
  const ops = operationsSynchro(voulu, panier.items ?? []);
  for (const v of ops.ajouter) await appel(`store/carts/${panier.id}/line-items`, 'POST', { variant_id: v.variantId, quantity: v.quantite });
  for (const m of ops.modifier) await appel(`store/carts/${panier.id}/line-items/${m.ligneId}`, 'POST', { quantity: m.quantite });
  for (const id of ops.retirer) await appel(`store/carts/${panier.id}/line-items/${id}`, 'DELETE');
  return panier.id;
}
