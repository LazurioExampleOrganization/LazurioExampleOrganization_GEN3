import { readFileSync } from "node:fs";

type ListenerLease = {
	id?: string;
	host?: string;
	port?: number;
};

type ListenerInputs = {
	argv?: string[];
	env?: Record<string, string | undefined>;
};

const MODULE_LEASE = (
	JSON.parse(
		readFileSync(
			new URL("../../../lazurio.module.json", import.meta.url),
			"utf8",
		),
	) as { port_leases?: ListenerLease[] }
).port_leases?.find((lease) => lease.id === "main");

if (
	!MODULE_LEASE ||
	typeof MODULE_LEASE.host !== "string" ||
	!Number.isInteger(MODULE_LEASE.port) ||
	Number(MODULE_LEASE.port) < 1024 ||
	Number(MODULE_LEASE.port) > 65535
) {
	throw new Error(
		"lazurio.module.json must declare a valid main listener lease.",
	);
}

const LEASE = {
	host: MODULE_LEASE.host,
	port: Number(MODULE_LEASE.port),
};

function argValue(argv: string[], name: string): string | undefined {
	const index = argv.indexOf(name);
	return index === -1 ? undefined : argv[index + 1];
}

function exactListener(
	host: string | undefined,
	portValue: string | undefined,
	source: string,
): { host: string; port: number } | undefined {
	if (host === undefined && portValue === undefined) return undefined;
	if (!host || !portValue) {
		throw new Error(`${source} must provide both host and port.`);
	}

	const port = Number(portValue);
	if (host !== LEASE.host || port !== LEASE.port) {
		throw new Error(
			`${source} listener ${host}:${portValue} does not match the module-owned lease ${LEASE.host}:${LEASE.port}.`,
		);
	}
	return LEASE;
}

export function resolveListener({
	argv = process.argv,
	env = process.env,
}: ListenerInputs = {}): { host: string; port: number } {
	const cli = exactListener(
		argValue(argv, "--host"),
		argValue(argv, "--port"),
		"CLI",
	);
	if (cli) return cli;

	const injected = exactListener(
		env.LAZURIO_RUNTIME_HOST,
		env.LAZURIO_RUNTIME_PORT,
		"Lazurio runtime",
	);
	return injected ?? LEASE;
}

