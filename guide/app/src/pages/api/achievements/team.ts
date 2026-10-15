import type { APIRoute } from "astro";
import { readAllTeamAchievements } from "@/lib/profile";

export const prerender = false;

export const GET: APIRoute = async () => {
  return Response.json(readAllTeamAchievements());
};
