# AgentMint slovníček pojmů

Tento dokument definuje klíčové pojmy AgentMint. Když pojem ovlivňuje
rozhodnutí, experiment, peníze nebo agentní chování, nesmí zůstat jen v
chatu. Kontrakt pro doplňování pojmů drží
`lazurio.organization.json#extensions.legacy.glossary_contract`.

## Doména AgentMint

### Mechanismus

Opakovatelný způsob, jak vzniká online příjem. Mechanismus není konkrétní
cizí značka, text, databáze ani účet. Je to model: nabídka, zákazník,
kanál, provozní kroky, ekonomika a důvod, proč někdo platí.

### Adaptace

Legální převedení mechanismu do vlastního kontextu AgentMint. Adaptace
používá vlastní brand, vlastní obsah, vlastní účty, vlastní data a
respektuje pravidla platforem.

### Experiment

Malý měřitelný test hypotézy. Musí mít hypotézu, metriku, rozpočet, stop
podmínku, ownera a zapsaný výsledek.

### Důkaz

Evidence, která zvyšuje jistotu, že mechanismus funguje: reálná platba,
konverze, odpověď trhu, auditelná metrika nebo opakovatelné pozorování.
Pocit ani virální claim sám o sobě důkaz není.

### Playbook

Ověřený postup, který lze opakovat. Do playbooku patří až mechanismus,
který má dost evidence; hypotézy patří do research nebo experiments.

### Unit economics

Základní ekonomika jedné jednotky výdělku: cena, náklad, čas
agenta/člověka, akviziční náklad, marže a rizika.

### Guardrail

Pravidlo, které chrání firmu před právním, reputačním, platformním nebo
bezpečnostním problémem. U AgentMint jsou guardrails součástí každého
experimentu.

## GEN3 topologie a generace

### Conglomerate

Kanonický anglický termín (česky pro trh: Konglomerát). Conglomerate je
celek více Organizací pod jedním Launchpad rootem na jedné mašině
(například `Conglomerate`). Definuje ho `launchpad.gen3.json`; mountuje
`organizations/<org>/` a `personalspace/`. Není to business repo —
Organizace v něm zůstávají oddělené access hranice.

### Organizace GEN3 / Organization GEN3

Jedna firma = jedno super-repo = jedna GitHub organizace = jedna access
hranice. Definuje ji `lazurio.organization.json` (`company.gen3.json` je jen
jeho generovaná kompatibilní projekce); v Launchpad rootu Conglomerate se
mountuje jako `organizations/<slug>/`. Tohle repo je Organizace GEN3
AgentMint, mount `organizations/LazurioExampleOrganization_GEN3`. Uvnitř Organizace žijí Teamy
(logické N:M skupiny modulů a lidí), fyzická workspace vrstva pro kancelářské
moduly, org-level `productionspace/` a moduly. Historické aliasy „Company
Workspace GEN3“ a „Workspace GEN2“ (celé super-repo firmy) používej jen
s přívlastkem jako historický odkaz (decision 0012).

### Team

Logická N:M skupina modulů a lidí uvnitř Organizace GEN3, stejný pojem jako
GitHub Team; v obchodní řeči „digitální kancelář“ týmu nebo značky. Modul může
patřit do více Teamů; chybějící membership používá deklarovaný default Team
a productionspace repo do žádného Teamu nepatří. Team nemá vlastní adresář —
je to logické grupování, ne složka.

Kanonicky roster deklaruje `lazurio.organization.json#teams` a příslušnost
modulu `module_slots[].teams` v `modules.manifest.json`. AgentMint zatím drží
historické singulární aliasy z doby před Team refinementem:
`lazurio.organization.json#extensions.legacy.workspaces` (jeden default)
a `module_slots[].workspace`; do generované projekce `company.gen3.json` se
promítají jako `workspaces` a `modules[].workspace`. Čti je
jako deprecated wire klíče, které se do N:M Team modelu teprve převedou; význam
je „modul patří default Teamu“.

### Workspace

Fyzická a logická kancelářská vrstva Organizace pro kancelářské (ne-produkční)
moduly. Sdílí firemní kostru v `company/`, Mission Control, role/person
overlaye, dokumentaci a Doctor-managed nested repo moduly; jejich logické
grupování určují Teamy. AgentMint je single-team Organizace: má jediný default
workspace se slugem `workspace`
(`lazurio.organization.json#extensions.legacy.workspaces`), který pokrývá
všechny moduly. Moduly jsou fyzicky mountované v `modules/` (decision 0023),
ale logicky patří tomuto workspace/Teamu.

DISAMBIGUACE: GEN2 „workspace“ znamenal celé super-repo firmy — tomu v GEN3
odpovídá pojem Organizace. Slovo Workspace bez přívlastku znamená vnitřní
kancelářskou vrstvu Organizace; historické GEN2 použití piš vždy s přívlastkem
„Workspace GEN2“. Názvy template rep (CompanyWorkspaceTemplate,
CompaniesWorkspaceTemplate) jsou historické.

### Workspace GEN2

Předchozí generace: standalone super-repo s in-tree Launchpadem a
doctorem per firma. Tato veřejná Organizace začíná vyčištěným snapshotem
AgentMint GEN2 baseline bez předchozí Git historie.

### Modul / Module

Doctor-managed gitignored nested Git repo (`modules/<slug>/`, plus
root-level `infra/` a `mission-control/`) s jedním doménovým source of
truth, popsané v root `modules.manifest.json` (`company.gen3.json#modules`
se z něj jen generuje). Modul patří do jednoho nebo více Teamů (N:M);
příslušnost deklaruje definice modulu (kanonicky `module_slots[].teams`, dnes
ještě přes historický alias `module_slots[].workspace`). Nejmenší jednotka
hierarchie Conglomerate → Organizace → Team → Modul. Super-repo netrackuje
obsah modulů ani gitlink pointery. Chybějící modul není automaticky chyba;
rozlišuj stavy `available`, `missing_access`, `planned_slot`.

### Productionspace

Org-level vrstva nasazených/produkčních systémů Organizace, mimo workspace
vrstvu. Modul sem patří, jakmile je reálně **nasazený** (na serveru, s vlastním
CI/CD) nebo **veřejný** (dokumentace, web) — ne když běží jen lokálně nebo přes
Organization Host. Verze se sem **povyšuje** z workspace (dílny pod univerzálním
Launchpad patternem) poté, co je v dílně označená za dobrou (např. v1.4). V
productionspace **není univerzální pattern**: každý produkční modul má vlastní,
historicky navrženou release/CI-CD pipelinu a vlastní pravidla. Mountuje se jako
`productionspace/` vedle workspace mountpointu; patří celé Organizaci, ne jednomu
Teamu, a řídí se vlastními production pravidly (decision 0014). **Není to
Organization Host** — ten je jen runtime pro vzdálený přístup k workspace dílně,
ne deploy/produkční stage. AgentMint zatím productionspace nemá; pojem platí pro
GEN3 topologii.

### Personalspace

Privátní osobní repo/mount vlastníka mašiny, mountované v Launchpad rootu
jako `personalspace/` mimo sdílené GitHub organizace. Drží osobní kontext
vlastníka; nikdy nedrží firemní pravdu žádné Organizace.

### Launchpad root

Kořenová složka Conglomerate na jedné mašině, definovaná
`launchpad.gen3.json`. Mountuje `organizations/<org>/` a `personalspace/`,
hostí shared Launchpad GEN3 a Guide a orchestruje doctory Organizací. Na
jedné mašině je právě jeden Launchpad root; není to fork template repa, ale
přímý klon/pull sdíleného Conglomerate Launchpadu z veřejného Lazurio rootu
(decision 0030). Rozhraní nad rootem popisuje pojem Launchpad GEN3.

### Launchpad GEN3

Builder-first přehledové a orchestrační rozhraní Conglomerate. Dynamicky
načítá Organizace z `launchpad.gen3.json` a jejich moduly a Teamy z
`lazurio.organization.json` + `modules.manifest.json` (starší čtečky z
generované projekce `company.gen3.json`) a ukazuje stav: co je lokálně
naklonované a stavy modulů `available` / `missing_access` / `planned_slot`.
Je to místo, kde builder na své mašině vidí a spouští, co je v lokálně
naklonovaném Conglomerate — spolehlivé přehledové rozhraní, ne dev-first
konzole. Builder-first záměr reviduje starší CEO-first formulaci (decision
0047 nad 0024); executive/admin přehled řeší samostatný Dashboard surface.
Discovery, health, spouštění aplikací a orchestrace doctorů jsou
control-plane mechanika pod tímto principem, ne jeho definice.

### Mission Control

Plánovací a orchestrační centrum workspace. U AgentMint nested repo
`mission-control/`: YAML plány drží kontext, scope a akceptační kritéria;
implementační kroky žijí v `TODO.tasks.json`.

### Doctor

CLI pro sync/push doctor-managed nested rep a diagnostiku workspace
(`company/scripts/doctor.sh`). Přechodný multiplayer flow, dokud ho
nenahradí Lazurio CLI.

### Partial workspace

Stav lokálního klonu Organizace, kdy některý modul není naklonovaný
(`available`, `missing_access`, `planned_slot`). Je to záměr, ne chyba Git
workflow.

### Skill

Kanonický formát opakovatelného agentního postupu. Žije v
`.agents/skills/<název>/SKILL.md` (`.claude/skills` je kompatibilní
symlink); index drží `.agents/skills/manifest.json`.

## Role

### Founder

Role, která drží směr firmy, rozhoduje o riziku, rozpočtu a tom, který
mechanismus se testuje dál. Strojový popis:
`company/roles/founder.role.json`.

### Research operator

Role, která mapuje online mechanismy, rozkládá je na model a připravuje
evidence pro rozhodnutí. Strojový popis:
`company/roles/research-operator.role.json`.

### Experiment operator

Role, která převádí hypotézu na měřitelný test, hlídá guardrails a
zapisuje výsledek. Strojový popis:
`company/roles/experiment-operator.role.json`.
