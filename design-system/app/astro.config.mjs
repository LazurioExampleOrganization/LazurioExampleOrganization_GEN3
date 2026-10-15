import { defineConfig } from "astro/config";
import { resolveListener } from "./listener.mjs";

const servesRuntime = process.argv.some(
  (argument) => argument === "dev" || argument === "preview",
);
const listener = servesRuntime ? resolveListener() : undefined;

export default defineConfig({
  ...(servesRuntime
    ? {
        server: {
          host: listener.host,
          port: listener.port,
        },
      }
    : {}),
  vite: {
    server: {
      strictPort: true,
      fs: {
        allow: [".."],
      },
    },
    preview: {
      strictPort: true,
    },
  },
});
