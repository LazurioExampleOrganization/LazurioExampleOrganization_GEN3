import { defineConfig } from "astro/config";
import node from "@astrojs/node";
import tailwindcss from "@tailwindcss/vite";

// Interaktivní průvodce. SSR mód kvůli API endpointům, které zapisují
// achievement soubory do company/colleagues/<slug>/guide/achievements/.
export default defineConfig({
  output: "server",
  adapter: node({ mode: "standalone" }),
  server: {
    host: "localhost",
    port: 5292,
  },
  vite: {
    plugins: [tailwindcss()],
    server: {
      fs: {
        // Sourozenecký ../content/ + zapisování do ../../company/ vyžaduje
        // přístup mimo app/.
        allow: [".."],
      },
      watch: {
        ignored: ["!../content/**"],
      },
    },
  },
});
