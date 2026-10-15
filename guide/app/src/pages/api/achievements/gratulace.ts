import type { APIRoute } from "astro";
import { appendGratulace, teamMember } from "@/lib/profile";

export const prerender = false;

interface GratulaceBody {
  target_slug?: string;
  achievement_id?: string;
  from_slug?: string;
  text?: string;
}

export const POST: APIRoute = async ({ request }) => {
  let body: GratulaceBody = {};
  try {
    body = (await request.json()) as GratulaceBody;
  } catch {
    return Response.json({ ok: false, error: "Invalid JSON" }, { status: 400 });
  }
  const { target_slug, achievement_id, from_slug, text } = body;
  if (!target_slug || !achievement_id || !from_slug || !text) {
    return Response.json(
      { ok: false, error: "Missing target_slug / achievement_id / from_slug / text" },
      { status: 400 },
    );
  }
  const sender = teamMember(from_slug);
  const fromName = sender?.jmeno ?? from_slug;
  const result = appendGratulace(target_slug, achievement_id, fromName, text);
  if (!result.ok) {
    return Response.json({ ok: false, error: result.error }, { status: 400 });
  }
  return Response.json({ ok: true, file: result.file });
};
