/**
 * Passerelle entre le navigateur et Medusa, côté serveur (sous /api/medusa). Elle ne relaie que l'API
 * de la boutique (adresses store) et l'authentification des clients (adresses auth/customer), ajoute la clé
 * publique, et garde le jeton du client dans un cookie HttpOnly : le navigateur ne le voit jamais.
 * Pas de CORS à régler, et tout passe aussi à travers le tunnel.
 */
export const COOKIE_JETON = 'victo_jeton';
const DUREE_SESSION = 60 * 60 * 24 * 7;
const CONNEXIONS = ['auth/customer/emailpass', 'auth/customer/emailpass/register'];

export function cheminAutorise(segments: string[]): boolean {
  const chemin = segments.join('/');
  return segments.every((s) => s !== '..' && s !== '') && (chemin.startsWith('store/') || chemin.startsWith('auth/customer/'));
}

export function lireJeton(cookies: string | null): string | null {
  const trouve = (cookies ?? '').split(';').map((c) => c.trim()).find((c) => c.startsWith(`${COOKIE_JETON}=`));
  return trouve ? decodeURIComponent(trouve.slice(COOKIE_JETON.length + 1)) : null;
}

function cookieSession(jeton: string, duree: number): string {
  return `${COOKIE_JETON}=${encodeURIComponent(jeton)}; HttpOnly; Path=/; SameSite=Lax; Max-Age=${duree}`;
}

const json = (corps: unknown, statut: number, entetes: Record<string, string> = {}) =>
  new Response(JSON.stringify(corps), { status: statut, headers: { 'content-type': 'application/json', ...entetes } });

export async function relayer(requete: Request, segments: string[], env: Record<string, string | undefined> = process.env): Promise<Response> {
  if (segments.join('/') === 'deconnexion') return json({ deconnecte: true }, 200, { 'set-cookie': cookieSession('', 0) });
  if (!cheminAutorise(segments)) return json({ message: 'Adresse non relayée' }, 404);
  const base = env.MEDUSA_URL; const cle = env.MEDUSA_CLE;
  if (!base || !cle) return json({ message: 'Medusa n’est pas configuré (MEDUSA_URL, MEDUSA_CLE)' }, 503);
  const chemin = segments.join('/');
  let corps: string | undefined = requete.method === 'GET' || requete.method === 'HEAD' ? undefined : await requete.text();
  if (requete.method === 'POST' && chemin === 'store/carts' && env.MEDUSA_REGION) {
    const donnees = corps ? (JSON.parse(corps) as Record<string, unknown>) : {};
    if (donnees.region_id === undefined) corps = JSON.stringify({ ...donnees, region_id: env.MEDUSA_REGION });
  }
  const entetes: Record<string, string> = { 'x-publishable-api-key': cle, 'content-type': 'application/json' };
  const jeton = lireJeton(requete.headers.get('cookie'));
  if (jeton) entetes.authorization = `Bearer ${jeton}`;
  let reponse: Response;
  try {
    reponse = await fetch(`${base.replace(/\/+$/, '')}/${chemin}${new URL(requete.url).search}`, { method: requete.method, headers: entetes, ...(corps !== undefined ? { body: corps } : {}), cache: 'no-store' });
  } catch {
    return json({ message: 'Medusa ne répond pas' }, 502);
  }
  const texte = await reponse.text();
  if (requete.method === 'POST' && CONNEXIONS.includes(chemin) && reponse.ok) {
    const { token } = JSON.parse(texte) as { token?: string };
    if (token) return json({ connecte: true }, 200, { 'set-cookie': cookieSession(token, DUREE_SESSION) });
  }
  return new Response(texte, { status: reponse.status, headers: { 'content-type': reponse.headers.get('content-type') ?? 'application/json' } });
}
