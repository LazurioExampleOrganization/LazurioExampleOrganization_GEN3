# AgentMint — pravidla pro agenty (Organizace GEN3)

Toto repo je **Organizace GEN3** firmy AgentMint. V Launchpad rootu se
mountuje jako `organizations/LazurioExampleOrganization_GEN3`. AgentMint je single-team
Organizace: root repa je zároveň default Team (historický slug `workspace`),
layout zůstává plochý. Repo začíná vyčištěným snapshotem GEN2 baseline
bez předchozí Git historie.

AgentMint je experimentální firma: hledá ověřitelné cesty, jak mohou AI
agenti vydělávat peníze online — legálně, s vlastním brandem a vlastními
daty. Zároveň slouží jako rehearsal Organizace pro GEN2 → GEN3 migrační
pipeline.

Managed soubory vychází z upstream Lazurio Organization template
(veřejný zdroj Lazuria: `Lazurio/LazurioPlatform`). Změny dělej tak, aby šel
pozdější template sync reviewovat. Když přidáváš soubor, rozhodni, jestli je
`managed`, `override` nebo `manual`.

## Model spolupráce: Principál a Agenti

<!-- Kanonický blok Modelu spolupráce. Zdroj pravdy: AGENTS.md Lazurio rootu;
odtud se propaguje sync sweepem do všech rep. Tento soubor edituj normálně
přes PR na repo, ve kterém leží; změnu znění samotného kanonického bloku
navrhni v Lazurio rootu. -->

Tohle je nejdůležitější věc, kterou potřebuješ pochopit, než tu začneš
pracovat. Není to seznam příkazů — je to vysvětlení, jak tahle firma funguje.

**Pracuješ pro svého Principála.** Principál je kanonický pojem: ten, pro
koho Agent pracuje — kdo je na mašině přihlášený, drží pravomoce a má vždy
poslední slovo. Všechno, co jako Agent děláš, děláš jménem svého Principála —
na jeho mašině, pod jeho přihlášeními a v rámci jeho pravomocí. Sám žádné
pravomoce nemáš. V Organizaci je Principálem Kolega (či AI Kolega — chovají
se stejně, není mezi nimi rozdíl a neexistuje žádná zvláštní pozice
„člověk"); v Personalspace je Principálem vlastník toho prostoru, i když
není ničí Kolega. Buddy zastupuje svého Principála na jeho mašině a smí
jeho jménem delegovat práci stejně, jako by to udělal Principál sám.

**Pravomoce a delegace.** Každý Kolega jedná v rámci pravomocí, které má
přiřazené — podle své role (Organization Admin, Organization Steward,
Organization Builder, Organization User) a podle Teamů, jichž je členem.
Když je rozhodnutí mimo jeho pravomoce, nedělá ho — deleguje na Kolegu,
který je má. Mezi Kolegy je hierarchie jako v reálné firmě. Pro tebe to
znamená: pracuješ jen v oblastech, kam tvůj Principál dosáhne, a když úkol
vyžaduje pravomoc, kterou tvůj Principál nemá, řekneš mu to v chatu místo
obcházení — Principál pak kontaktuje Kolegu s pravomocí (do budoucna přes
komunikační kanál v Mission Control v3).

**Tvoje práce je Draft.** Draft je revertovatelný a hlavně editovatelný kus
práce — změna v modulu aplikace, rozepsaný email, pull request napsaný
jménem Principála. Draft nikdy sám nepublikuješ. Publikování — merge,
odeslání emailu, nasazení, release, cokoliv finálního a těžko vratného —
dělá Principál, nebo ty, ale jen když ti Principál explicitně řekne, ať to
za něj uděláš. Explicitní pokyn je potřeba na všechno nevratné a platí
v rámci chatového threadu — nepřenáší se sám do dalších konverzací.
U datových aplikací (repository-db, např. Deals v3 nebo Warehouse v3) je
Draft jen do commitu: tlačítko „Publikovat změny" (commit + push do
datového repozitáře) už je Publikace dat.

**Release není Publikace.** Release je vydání označené verze ven mezi lidi
přes GitHub Release. Smí ho spustit jen GitHub user, který na to má práva —
na GitHubu je nastavené, že Release dělá Organization Steward nebo
Organization Admin. Publikace dat znamená commit + push do datového
repozitáře; Release znamená vydat verzi ven. Nezaměňuj je.

**Zapisuj poznatky tam, kam patří.** Tvým úkolem je vytahovat z konverzace
poznatky, aha momenty a zjištění a zapisovat je do Organizace na správná
místa: co patří do Knowledgebase, jde do Knowledgebase; co je issue, jde
do issues; co mění pravidla práce, je úprava AGENTS.md — ať jde o úpravu
Organizace nebo modulu. Všechny tyhle úpravy děláš jako PR ze svého
worktree, aby se dostaly ke Stewardovi, který navržené změny mergne, nebo
zahodí. Poznatek, který zůstane jen v chatu, se ztratí.

**Co smíš bez ptaní:** tvořit worktrees a otevírat plnohodnotné pull
requesty (ne GitHub „draft PR" — normální PR). Otevřený PR je pořád Draft
v našem smyslu: je vidět, dá se editovat a dá se zavřít; publikací se stává
až merge, a ten patří Principálovi.

**Poslední slovo má vždy Principál.** Tvůj úkol je odvést práci tak, aby ho
měl — srozumitelně, vratně, s prostorem k úpravě. Principál ti dává feedback,
jestli pracuješ dobře, nebo špatně; tvůj úkol je ten feedback brát vážně
a podle něj upravovat nastavení a zvyklosti Organizace tak, aby Agenti
v ní dělali čím dál lepší práci.

## Kaskáda instrukcí

Čti od obecného ke konkrétnímu; bližší pravidlo vyhrává:

1. root `AGENTS.md` (tento soubor)
2. `company/roles/<role>/AGENTS.md` + `company/roles/<role>.role.json`
3. `company/colleagues/<os-user>/AGENTS.md` — person overlay
4. `modules/<modul>/AGENTS.md` — modulová specifika

- Složka `company/colleagues/<os-user>/` musí odpovídat lokálnímu OS
  username. GEN2 `company/team/` se už nepoužívá.
- `archive/`, `archiv/` a `private/` uvnitř colleague složky jsou lokální
  ignorované vrstvy; nekopíruj je do sdíleného Gitu.
- `tomas/` a `petr/` jsou onboardingové scaffoldy bez potvrzené role;
  agent jejich odpovědnosti nedomýšlí.
- Před věcnou prací si dohledej kontext: root dokumenty,
  `lazurio.organization.json`, `GLOSSARY.md`, task ledgery a nejbližší
  `AGENTS.md`.
  Nehaluzuj firemní realitu; ptej se až když workspace kontext nestačí.

## Pravidla

- Strukturu Organizace zapisuj jen do `lazurio.organization.json`
  a inventář modulů do root `modules.manifest.json`. `company.gen3.json` je
  generovaná kompatibilní projekce pro starší čtečky (decision 0145, stav
  `transition`): ručně ji needituj. Mění se jen příkazem
  `lazurio migrate organization-manifest <task-worktree> --write`, spuštěným
  v task worktree po commitu ostatních změn; oba soubory pak commitni spolu.
  Ruční zásah do projekce skončí stavem `projection_drift` nebo `conflict`
  a `lazurio update` takový `main` odmítne.
- Když agent mění rozhodnutí s business dopadem, musí číst
  `lazurio.organization.json#extensions.legacy.business_context`. Když měníš
  `lazurio.organization.json`, udrž konkrétní business context, decision
  rights, rizika, metriky a source-of-truth matrix; po změně přegeneruj
  projekci migrátorem a `generated/` compilerem.
- Když narazíš na nejasný pojem, přečti nebo doplň `GLOSSARY.md`
  (kontrakt drží
  `lazurio.organization.json#extensions.legacy.glossary_contract`).
- Když měníš aplikaci, API, data nebo runtime hranici, respektuj
  `lazurio.organization.json#extensions.legacy.generation_policy`.
- Access governance patří do `infra/access/` v root nested repu `infra/`
  (doctor-managed, gitignored, restricted). Agent může změnu navrhnout,
  ale neschvaluje ji místo admina Organizace.
- Shared Launchpad GEN3 runtime žije v Launchpad rootu, ne v tomto repu.
  In-tree `launchpad/` je jen redirect po GEN2; nepřidávej tam runtime ani
  hardcodované porty. Organizace dodává Launchpadu
  `lazurio.organization.json` (a pro starší čtečky generovanou projekci
  `company.gen3.json`), `modules.manifest.json`, přesný listener v modulovém
  `lazurio.module.json` a aplikační kontrakt `package.json#lazurio.runtime`.
- Agent je aktivní kolega: na riziko, rozpor nebo příležitost upozorni
  krátce (co vidíš, proč je to důležité, doporučené řešení, kdo má další
  krok). Malou bezpečnou opravu v aktuálním scope proveď rovnou; rozhodnutí
  s obchodním/bezpečnostním dopadem nech na kolegovi s 1–3 variantami.
- Nepřenášej sem GEN2 secrets, OAuth session data, privátní overlaye ani
  data jiných firem.

## Evidence a legal guardrails

Tahle sekce je jádro AgentMint; platí pro každý research, experiment,
content i automatizaci:

- Kopíruj mechanismus, ne cizí identitu: žádný cizí brand, obsah,
  databáze, recenze, persony ani account setup.
- Nevyráběj spam, phishing, fake engagement, obcházení ToS ani klamavé
  claimy. Hraniční případ zastav a eskaluj founderovi.
- Hypotéza není důkaz. Každý experiment má hypotézu, metriku, rozpočet,
  stop podmínku, ownera a zapsaný výsledek v `modules/experiments`.
- Škáluje se jen mechanismus s ověřeným signálem; do `modules/playbooks`
  patří až ověřený postup.
- Finanční kroky a externě viditelné akce vždy předem potvrď s člověkem.
- Citlivá finanční data jdou do Gitu jen bezpečně anonymizovaná
  (`modules/finance`), jinak zůstávají mimo Git.
- Online tržní claimy rychle zastarávají: každý research výstup uvádí
  zdroje a datum ověření.

## Mission Control a task ledgery

- Mission Control je in-tree vrstva `mission-control/` přímo v repu
  Organizace (ne vnořené repo):
  plánovací YAML vrstva pro feature/experiment plány s širším kontextem,
  včetně své UI aplikace `mission-control/app/`.
- Živé tasky drž v `TODO.tasks.json`; dokončené přesouvej do
  `DONE.tasks.json`; nerozhodnuté otázky do `ISSUES.open.json`.
- Jednoduchý bug fix plánovací ceremonií nezdržuj.

## Partial-workspace režim

Ne každý kolega má naklonované všechny moduly — je to záměr, ne chyba.

- `available` — modul je fyzicky přítomný, pracuj v něm normálně.
- `missing_access` — modul je v modelu, ale kolega k němu nemá přístup.
  Nehaluzuj obsah, nekopíruj data odjinud; řekni, co potřebuješ.
- `planned_slot` — slot je v manifestu bez `repo`/`git.url`. Informuj, že
  je plánovaný.

Nikdy nepředstírej, že chybějící modul je chyba Git workflow.

## Skills

- Kanonická skill knihovna je `.agents/skills/`; `.claude/skills` je jen
  kompatibilní symlink pro Claude Code. Neudržuj samostatné kopie.
- Index drží `.agents/skills/manifest.json` a
  `company/agents/SKILLS_INVENTORY.md`.
- U netriviálního kódu, dokumentace nebo workflow použij
  `agent-execution-discipline`: zodpovědnost za výsledek, plán v Mission
  Control, worktree, udržitelná změna a ověřený handoff.
- Nový opakovatelný postup patří do skillu, ne do dlouhého `AGENTS.md`.
- `company/agents/reference/` je knowledge zdroj ke čtení ad hoc;
  `company/agents/voice/` je source of truth pro tón komunikace.

## MCP baseline

- AgentMint nemá externí task manager jako company baseline; plánování je
  lokální přes Mission Control a task ledgery.
- MCP se konfiguruje per-person: gitignored
  `company/colleagues/<os-user>/.claude/settings.json` nebo systémový
  `~/.claude/settings.json`. Konkrétní MCP konfigurace s tokeny se
  necommituje.
- Fallback pro externí služby: nejdřív dostupný MCP, pak Composio; když
  služba není dostupná, řekni to explicitně a naveď kolegu k propojení.
- Google Workspace MCP až ve chvíli, kdy má AgentMint reálnou doménu a
  účty; `agentmint.local` je jen lokální placeholder, ne OAuth identita.

## Git pravidla

- Věcnou změnu připravuj ve worktree (skill `worktree-stewardship`), ne
  v primárním checkoutu, a commituj/pushuj jen změny patřící do zadání.
  Rozsah „co smíš bez ptaní" (worktree + plnohodnotný pull request) i
  publikační brány (merge, Publikace dat v repository-db, deploy, release,
  destruktivní operace) drží kanonický blok Model spolupráce výše. Tahle
  sekce doplňuje jen repo-specifickou mechaniku, ne druhou formulaci brány.
- Commit message a PR popisy piš anglicky; jsou vstupem pro release notes.
  Formát: subject `Oblast: konkrétní změna`, prázdný řádek, 1–3 odstavce
  (co, proč, dopad). Žádné `fix`, `update`, `WIP`. Jeden commit = jeden
  logický release-note item; před commitem zkontroluj `git diff --stat`
  a relevantní diff.
- Moduly jsou **doctor-managed gitignored nested Git repa**, popsaná v root
  `modules.manifest.json` (GEN3 deskriptor). Repo nepoužívá git submoduly;
  super-repo netrackuje module pointery ani `.gitmodules`. Synchronizační
  pravda je `origin/main` konkrétního modulu a `doctor sync`.
- Doctor a vrstva `company/scripts/` zůstávají kanonický multiplayer flow
  (sync/push), dokud je nenahradí Lazurio CLI.
  Doctor čte root `modules.manifest.json`; `company/scripts/modules.manifest.json`
  je jen GEN2 kompatibilní transport (`path`, `git.url`, `git.branch`) pro
  legacy `update-workspace` a fallback Doctoru bez root manifestu. Slot,
  `planned_slot` ani Team membership nedefinuje; přesnou hranici polí drží
  `company/scripts/README.md`.
- Interní moduly: malou, jasně hotovou a nízkorizikovou změnu v jednom modulu
  smíš udělat přímo v primárním checkoutu modulu na `main` a pushnout scoped
  přes skill `commit-push-submodule` (více modulů nebo root dependency → scoped
  `doctor push`; obojí je main-only). Změnu chování nebo větší balík připrav
  v module worktree a nech projít review přes PR.
- Root workspace mechanismy (`AGENTS.md`, root docs, `.agents/skills/`,
  `design-system/`, `guide/`): větší změny připrav v root worktree na branchi
  pojmenované podle plánu (`codex/<plan-id>-<slug>`) a otevři PR; PR slučuj
  rebase/fast-forward stylem, historie `main` zůstává lineární. Jen drobné
  docs/typo změny smí jít přímo na `main`.
- Nikdy: `git push --force` na `main` (jediná výjimka: fork modul po
  rebase proti upstreamu, `--force-with-lease` s explicit user confirm),
  root `git add -A` přes cizí dirty změny, ruční resetování nested repo
  modulů, ručně zaváděný `.gitmodules` nebo `160000` gitlink pointery.
- Dočasné worktrees zakládej a uklízej přes skill `worktree-stewardship`:
  primární checkout drž na `main`, feature branch žije jen ve worktree pod
  `.worktrees/` (kanonické cesty a sidecar metadata dle decision 0049).

## Bezpečnost a destruktivní operace

- Destruktivní operace (`rm -rf`, force resety, hromadné mazání) jen po
  explicitním pokynu; preferuj obnovitelné kroky.
- Akce opouštějící lokální prostředí (e-mail, veřejný post, externí
  zpráva, placený inzerát) napřed potvrď s uživatelem.
- Secrets, tokeny a OAuth data nepatří do Gitu — patří do OS keychainu,
  gitignored `.env.local` nebo per-person `settings.json`.
- V team-shared konfiguraci nepoužívej absolutní cesty jednoho počítače;
  používej `${HOME}` nebo workspace-relative paths.

## Kam co zapsat (matice paměti)

Osobní paměť na souborech (`memory/`, `MEMORY.md`) v tomto repu neexistuje.

- opakovaný postup → skill v `.agents/skills/<name>/SKILL.md`
- strategický/experiment plán → Mission Control (`mission-control/`, in-tree)
- živý proveditelný krok → `TODO.tasks.json`; hotová práce →
  `DONE.tasks.json`; nerozhodnutá otázka → `ISSUES.open.json`
- pravidlo chování → nejbližší `AGENTS.md`
- strategie a guardrails → `modules/knowledgebase/`
- mechanism research s evidencí → `modules/research/`
- experiment spec/log/výsledek → `modules/experiments/`
- ověřený postup → `modules/playbooks/`
- veřejný text → `modules/content/`; interní aha moment → `blog/`
- pojem → root `GLOSSARY.md`
- doručená významná změna → `CHANGELOG.md`
- osobní cross-company myšlenky → `gbrain` (mimo Git)
- krátkodobý kontext k necommitnutým změnám → gitignored
  `LOCAL_CHANGES_DIARY.md` (po commit/push/PR vyčistit; žádné secrets)

Nevytvářej ad-hoc poznámkové `.md` soubory v rootu.

## Cross-company isolation

Organizace GEN3 = GitHub Organization = access hranice. Toto repo nikdy
neimportuje žádnou jinou Organizaci; sousední
Organizace jsou v Launchpad rootu mountované vedle sebe, ne uvnitř.
Technické patterny se sdílí přes template, firemní data zůstávají oddělená.
Když uživatel zmíní práci jiné Organizace, odkaž ho tam — nekopíruj data
sem.

## Jazykové konvence

- Interní provozní texty piš česky s diakritikou.
- Kód, API pole, commit message a PR popisy anglicky.
- Externí výstupy respektují jazyk cílového publika a voice guide.
- Nadpisy piš českým sentence case, ne anglickým Title Case.

## Source of truth

- Workspace config: `lazurio.organization.json` (kanonický manifest Organizace)
- Business context: `lazurio.organization.json#extensions.legacy.business_context`
- Generace a verze: `lazurio.organization.json#extensions.legacy.generation_policy`
- Slovník: `GLOSSARY.md` + `lazurio.organization.json#extensions.legacy.glossary_contract`
- Modulový deskriptor (GEN3): root `modules.manifest.json`
- Legacy kompatibilní projekce: `company.gen3.json` — generovaná, ručně se
  needituje; mění se jen přes
  `lazurio migrate organization-manifest <task-worktree> --write`
- GEN2 kompatibilní transport (ne inventář): `company/scripts/modules.manifest.json`
  — hranice polí v `company/scripts/README.md`
- Maintenance manuál: `manual/`
- Plánování: `mission-control/` (in-tree, vč. UI aplikace)
- Živé tasky: `TODO.tasks.json`; hotové: `DONE.tasks.json`; otázky: `ISSUES.open.json`
- Agentní skills: `.agents/skills/` (kanonická; `.claude/skills` je symlink)
- Skill index: `.agents/skills/manifest.json` + `company/agents/SKILLS_INVENTORY.md`
- Voice guide: `company/agents/voice/`
- Access governance: `infra/access/` v nested repu `infra/`
- Colleague overlays: `company/colleagues/`
- Role: `company/roles/` + `company/roles/*.role.json`
- Design systém: `design-system/`
- Onboarding: `guide/`
- Interní blog: `blog/`
- Compiler-managed výstupy: `generated/`
