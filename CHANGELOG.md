# Changelog — `AgentMint/`

Datumové verze: `YYYYMMDD`. Tento changelog drží doručené významné změny
super-repa firmy.

## 20261015

### Změněno

- Organizace publikovaná jako veřejná referenční Organizace Lazuria
  `LazurioExampleOrganization`: čerstvá Git historie z vyčištěného snapshotu
  GEN2 baseline. Lidé a firmy v datech jsou fiktivní; odkazy na jiné
  Organizace a jejich privátní repozitáře byly odstraněny. Starší záznamy
  níže popisují fiktivní historii AgentMintu před tímto snapshotem.

## 20260612

### Změněno

- AgentMint se in-place konvertoval z Workspace GEN2 na Organizaci GEN3
  (rehearsal celé migrační pipeline):
  nový strojový model `company.gen3.json` + root `modules.manifest.json`,
  `company/team/` -> `company/colleagues/`, kanonické skills v
  `.agents/skills/`, maintenance manuál v `manual/` s migračním runbookem,
  in-tree Launchpad GEN2 nahrazený redirectem na Launchpad root a root
  dokumenty přepsané pro GEN3 (MAP/ARCHITECTURE/WORKSPACE_MANUAL jsou
  redirect stuby).

## 20260608

### Změněno

- Skilly `dobre-rano` a `dobrou-noc` nově používají zpřísněný GEN2 denní Git
  flow: ráno se latest pulluje i při dirty `main` přes lokální safety stash a
  večer se bezpečně commitovatelné změny posílají na GitHub.
- `dobrou-noc` rozlišuje malé nízkorizikové drobnosti pro direct push na
  `main` a větší nebo review-sensitive balíky pro PR.

### Dopad

- AgentMint ranní/večerní rutina chrání lokální WIP při syncu a zároveň
  nenechává hotové commitovatelné změny jen lokálně.

## 20260523

### Přidáno

- Přidán root `CLAUDE.md` jako nativní Claude Code bootstrap, který odkazuje na
  `AGENTS.md` a povinný preflight.
- Založena GitHub organizace/repozitáře pro AgentMint: super-repo `AgentMint`
  a nested repo moduly `knowledgebase`, `research`, `experiments`, `playbooks`,
  `automations`, `content`, `finance`.
- Přepnuta modulová vrstva na nested repo pattern: `modules/*` jsou nested Git
  repozitáře spravované doctorem, ne Git submoduly.
- Přidán sdílený skill `agent-execution-discipline` pro netriviální kód,
  dokumentaci, research postupy a experiment workflow.
- Vybrán název **Mission Control** pro lokální plánovací a orchestrační centrum
  AgentMintu.
- Přidán planned slot `modules/mission-control/` a základní kontrakt pro
  YAML-first plánování.

### Dopad

- Claude Code má jasný vstup do workspace bez druhé kopie agentních pravidel;
  Doctor nově hlídá, že `CLAUDE.md` zůstává napojený na `AGENTS.md`.
- Super-repo nedrží `160000` gitlink pointery ani `.gitmodules`; eliminuje se
  běžný konflikt pointerů na `modules/`.
- Reálný access k modulům se řídí SSH/GitHub právy a `git.url` v manifestu.
- Agent má jednotný guardrail: nejdřív pojmenovat předpoklady a evidence,
  potom držet nejmenší bezpečný krok, chirurgický diff a ověřitelný výsledek.
- Feature kontext má žít v YAML souborech Mission Control; implementační práce
  zůstává v Git task ledgerech s traceability zpět na lokální plán.

## 20260522

### Přidáno

- Založen local-only GEN2 workspace `AgentMint` z aktualizovaného
  Lazurio company template bez GitHub remote.
- Nastaveny root dokumenty pro misi: hledat, modelovat, testovat a škálovat
  legální online revenue mechanismy pro AI agenty.
- Přidány plánované module slots: `research`, `experiments`, `playbooks`,
  `automations`, `content`, `finance`.
- Založeny role `founder`, `research-operator`, `experiment-operator` a
  person overlay `jannovak`.

### Dopad

- Agent má jasný pracovní rámec: kopírovat mechanismus, ne cizí identitu nebo
  data.
- Workspace je připravený pro první výzkumné a experimentální tasky bez
  synchronizace na GitHub.
