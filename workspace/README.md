# Workspace

Workspace je **fyzická a logická kancelářská vrstva** Organizace GEN3 pro
kancelářské (ne-produkční) moduly (viz `GLOSSARY.md`). Logické N:M grupování
modulů a lidí obstarává **Team** (v obchodní řeči „digitální kancelář“ týmu
nebo značky). AgentMint je single-team Organizace, takže má jediný default
workspace se slugem `workspace`, který pokrývá všechny moduly.

## Co patří dovnitř

- **Pracovní povrch týmu** — každodenní operativa workspace, která nepatří do
  žádné dedikované org-level vrstvy.
- **Pravidla a config workspace** — workspace-specific instrukce a nastavení
  nad rámec root `AGENTS.md`.
- **Moduly, které workspace vlastní** — fyzicky jsou mountované v `modules/`
  (decision 0023), ale logicky patří tomuhle workspace/Teamu; jejich
  příslušnost deklaruje root `modules.manifest.json`. Kanonicky přes
  `module_slots[].teams`; AgentMint zatím drží historické aliasy `workspaces[]`
  + `module_slots[].workspace`.

## Co sem NEpatří

Org-level vrstvy sdílené celou Organizací: `manual/`, `mission-control/`
(plánování), `productionspace/` (release/produkční systémy), `design-system/`,
`guide/`, `company/`, `infra/`. Ty stojí vedle workspace, ne uvnitř něj.

## Víc týmů

Single-team Organizace vystačí s tímhle jedním default Teamem. Když Organizace
obsluhuje víc týmů nebo značek, přibudou další **Teamy** — logické N:M
grupování, ne vlastní složka (moduly zůstávají fyzicky v `modules/`).
Kanonicky se roster deklaruje v `lazurio.organization.json#teams` a příslušnost
modulu v `module_slots[].teams` (`modules.manifest.json`). AgentMint zatím drží
historické aliasy `workspaces[]` + `module_slots[].workspace` (jeden default),
které se do Team modelu teprve převedou
(viz `GLOSSARY.md`).
