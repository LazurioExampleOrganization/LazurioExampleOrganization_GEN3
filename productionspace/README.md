# Productionspace

The Organization-level layer of the deployed and production systems of a GEN3
Organization (decision 0014): firmware, connect, the product monorepo, public
docs and website, and similar deployed systems. It is mounted next to the
workspace layer, the whole Organization shares it, and it belongs to no single
Team.

A module belongs here once it is really **deployed** (on a server, with its
own CI/CD) or **public** (documentation, website), not while it runs only
locally or through the Organization Host. A version is **promoted** here from
the workspace (the workshop under the universal Launchpad pattern) after it is
marked good in the workshop (for example v1.4). Unlike the workspace, there is
**no universal pattern** here: each production module has its own,
historically designed release and CI/CD pipeline and its own rules.
Productionspace **is not the Organization Host**: the Host is only a runtime
for remote access to the workshop, not a deploy or production stage.

Lazurio Example Organization is a research Organization without production
systems, so productionspace is empty for now. The folder exists on purpose, so
that the canonical GEN3 structure is complete and it is clear where release
and production systems belong once they exist.

Planning, the roadmap and decisions for productionspace and for the whole
Organization are held by Mission Control (`mission-control/`, data in
`mission-control/db/`), not by a separate planning layer.
