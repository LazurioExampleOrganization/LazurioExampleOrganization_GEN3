# Workspace

`workspace/` holds the Organization's workspace modules. Each
`workspace/<module>/` is its own Git repository, mounted as an ignored nested
checkout. The root never tracks module contents, submodules or gitlinks.

The root `modules.manifest.json` is the only inventory of modules. A slot
declares the module's path, its repository and the Teams it belongs to
(`teams`). `lazurio update` clones every declared module you can access and
keeps it on a clean `main`.

## Teams

The Organization has a single Team, `workspace`, declared in
`lazurio.organization.json#teams`. Every workspace module belongs to it. A Team
is a declaration in the manifest, not a directory: modules stay in this one
flat layer whatever Teams they belong to. Which Teams can actually reach a
module is decided by the GitHub grants of that repository.

## Missing modules

A missing module is not automatically an error:

- `available`: the module is cloned and usable;
- `missing_access`: the module is declared, but your GitHub account has no
  access to its repository; restricted modules are cloned only by an Admin
  install;
- `planned_slot`: the slot is declared without a repository.

Do not copy data from elsewhere to work around a missing module; say what you
need.

## What does not belong here

Organization-level layers sit next to `workspace/`, not inside it:
`manual/`, `mission-control/`, `design-system/`, `productionspace/`,
`company/` and `infra/`.
