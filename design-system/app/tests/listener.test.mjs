import { describe, expect, test } from "bun:test";
import { readFileSync } from "node:fs";
import { resolveListener } from "../listener.mjs";

const moduleManifest = JSON.parse(
  readFileSync(new URL("../../lazurio.module.json", import.meta.url), "utf8"),
);
const packageManifest = JSON.parse(
  readFileSync(new URL("../package.json", import.meta.url), "utf8"),
);
const astroConfig = readFileSync(
  new URL("../astro.config.mjs", import.meta.url),
  "utf8",
);
const lease = moduleManifest.port_leases.find(
  (candidate) => candidate.id === "main",
);

describe("resolveListener", () => {
  test("uses the git-tracked module lease for direct dev and preview", () => {
    expect(resolveListener({ HOST: "0.0.0.0", PORT: "9999" })).toEqual({
      host: lease.host,
      port: lease.port,
    });
  });

  test("accepts an exact Lazurio runtime injection", () => {
    expect(
      resolveListener({
        LAZURIO_RUNTIME_HOST: lease.host,
        LAZURIO_RUNTIME_PORT: String(lease.port),
      }),
    ).toEqual({ host: lease.host, port: lease.port });
  });

  test("rejects partial or drifting Lazurio runtime injection", () => {
    expect(() =>
      resolveListener({ LAZURIO_RUNTIME_HOST: lease.host }),
    ).toThrow("both");
    expect(() =>
      resolveListener({
        LAZURIO_RUNTIME_HOST: lease.host,
        LAZURIO_RUNTIME_PORT: String(lease.port + 1),
      }),
    ).toThrow("does not match");
  });

  test("keeps Astro collision handling fail-closed in provider config", () => {
    expect(packageManifest.scripts.dev).toBe("astro dev");
    expect(packageManifest.scripts.preview).toBe("astro preview");
    expect(astroConfig).toMatch(
      /\bvite\s*:\s*\{[\s\S]*?\bserver\s*:\s*\{[\s\S]*?\bstrictPort\s*:\s*true\b/,
    );
    expect(astroConfig).toMatch(
      /\bvite\s*:\s*\{[\s\S]*?\bpreview\s*:\s*\{[\s\S]*?\bstrictPort\s*:\s*true\b/,
    );
  });
});
