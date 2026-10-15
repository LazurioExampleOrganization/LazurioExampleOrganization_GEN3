import { describe, expect, test } from "bun:test";
import { readFileSync } from "node:fs";
import { resolveListener } from "../src/listener.ts";

const lease = (
	JSON.parse(
		readFileSync(
			new URL("../../../lazurio.module.json", import.meta.url),
			"utf8",
		),
	) as { port_leases: Array<{ id: string; host: string; port: number }> }
).port_leases.find((candidate) => candidate.id === "main");

if (!lease) throw new Error("Test requires the main module lease.");

describe("resolveListener", () => {
	test("uses the git-tracked module lease for a direct start", () => {
		expect(resolveListener({ argv: ["bun"], env: {} })).toEqual({
			host: lease.host,
			port: lease.port,
		});
	});

	test("accepts an exact Lazurio runtime injection", () => {
		expect(
			resolveListener({
				argv: ["bun"],
				env: {
					LAZURIO_RUNTIME_HOST: lease.host,
					LAZURIO_RUNTIME_PORT: String(lease.port),
				},
			}),
		).toEqual({ host: lease.host, port: lease.port });
	});

	test("rejects a partial or drifting Lazurio runtime injection", () => {
		expect(() =>
			resolveListener({
				argv: ["bun"],
				env: { LAZURIO_RUNTIME_HOST: lease.host },
			}),
		).toThrow("both host and port");
		expect(() =>
			resolveListener({
				argv: ["bun"],
				env: {
					LAZURIO_RUNTIME_HOST: lease.host,
					LAZURIO_RUNTIME_PORT: String(lease.port + 1),
				},
			}),
		).toThrow("does not match");
	});

	test("ignores ambient HOST and PORT values", () => {
		expect(
			resolveListener({
				argv: ["bun"],
				env: { HOST: "0.0.0.0", PORT: "9999" },
			}),
		).toEqual({ host: lease.host, port: lease.port });
	});

	test("accepts only an exact explicit CLI listener", () => {
		expect(
			resolveListener({
				argv: [
					"bun",
					"server.ts",
					"--host",
					lease.host,
					"--port",
					String(lease.port),
				],
				env: {},
			}),
		).toEqual({ host: lease.host, port: lease.port });
		expect(() =>
			resolveListener({
				argv: ["bun", "server.ts", "--port", String(lease.port + 1)],
				env: {},
			}),
		).toThrow("both host and port");
	});
});

