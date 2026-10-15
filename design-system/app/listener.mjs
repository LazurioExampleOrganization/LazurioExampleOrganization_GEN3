import { readFileSync } from "node:fs";

const moduleLease = JSON.parse(
  readFileSync(new URL("../lazurio.module.json", import.meta.url), "utf8"),
).port_leases?.find((lease) => lease.id === "main");

if (
  !moduleLease ||
  typeof moduleLease.host !== "string" ||
  !Number.isInteger(moduleLease.port) ||
  moduleLease.port < 1024 ||
  moduleLease.port > 65535
) {
  throw new Error(
    "lazurio.module.json must declare a valid main listener lease.",
  );
}

const lease = Object.freeze({
  host: moduleLease.host,
  port: moduleLease.port,
});

export function resolveListener(env = process.env) {
  const host = env.LAZURIO_RUNTIME_HOST;
  const rawPort = env.LAZURIO_RUNTIME_PORT;
  if (host === undefined && rawPort === undefined) return lease;
  if (!host || !rawPort) {
    throw new Error(
      "Lazurio runtime must provide both LAZURIO_RUNTIME_HOST and LAZURIO_RUNTIME_PORT.",
    );
  }

  const port = Number(rawPort);
  if (host !== lease.host || port !== lease.port) {
    throw new Error(
      `Lazurio runtime listener ${host}:${rawPort} does not match the module-owned lease ${lease.host}:${lease.port}.`,
    );
  }
  return lease;
}

