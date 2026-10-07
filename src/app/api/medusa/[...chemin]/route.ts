import { relayer } from '@/lib/medusa/passerelle';

type Contexte = { params: Promise<{ chemin: string[] }> };

export async function GET(requete: Request, contexte: Contexte) {
  return relayer(requete, (await contexte.params).chemin);
}
export const POST = GET;
export const DELETE = GET;
