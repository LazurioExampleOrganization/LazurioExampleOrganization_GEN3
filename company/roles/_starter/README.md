# Starter role katalog

Tahle složka není aktivní role overlay. Je to katalog ověřených
role archetypů, které může agent při setupu nové firmy zkopírovat do
`company/roles/<role>/` a přepsat podle reality firmy.

Proč tu je:

- nová firma nemusí role vymýšlet od nuly
- agent má jasné otázky na ownera firmy
- person overlays v `company/colleagues/<člověk>/` mají na co odkazovat
- `modules.manifest.json` může používat stabilní `required_roles`

## Jak katalog používat

1. Nejdřív se zeptej ownera firmy, jaké práce ve firmě skutečně existují.
2. Vyber jen archetypy, které mají reálného ownera nebo jasný budoucí use
   case.
3. Zkopíruj `_template/` do `company/roles/<role>/`.
4. Použij níže uvedené archetypy jako obsahový vzor pro `README.md` a
   `AGENTS.md`.
5. Zapiš finální seznam do `company/roles/README.md`.
6. Pro každého člověka v `company/colleagues/<člověk>/` nastav primární roli a
   případné multi-role disambiguace.

Nezakládej prázdné role jen proto, že jsou v katalogu. Role bez ownera,
výstupů a handoff hranic je šum.

## Starter archetypy

### `founder` / `ceo`

**Scope:** strategie, priority, obchodní směr, větší rozhodnutí, risk.

Typické vlastní:

- firemní strategie a rozhodovací rámec
- obchodní a finanční priority
- schvalování rizikových nebo strategických závazků
- executive reporting

Typické výstupy:

- rozhodnutí a jejich důvody
- priorita na další období
- stručný executive summary
- schválení / zamítnutí výjimky

Handoff:

- předává směr `technical-lead`, `operations`, `sales` nebo jiným ownerům
- přebírá eskalace, když rozhodnutí přesahuje jednu roli

Co NEdělat:

- neřešit detailní implementaci místo ownera role
- neschvalovat citlivé závazky bez zdrojových podkladů

### `technical-lead`

**Scope:** technická architektura, delivery kvalita, engineering pravidla.

Typické vlastní:

- technické rozhodování a architektura
- kvalita codebase / technického produktu
- incidenty a technická rizika
- napojení technických modulů na business kontext

Typické výstupy:

- technical decision / ADR
- review rizik před změnou
- implementační plán
- incident summary a follow-up

Handoff:

- přebírá priority od `founder` / `product-owner`
- předává zákaznický nebo obsahový dopad `product-owner` / `marketing`
- eskaluje obchodní dopad `founder`

Co NEdělat:

- nepřebírat business rozhodnutí jen proto, že mají technický detail
- neukládat interní strategii do veřejné dokumentace

### `product-owner`

**Scope:** produktová / službová identita, dokumentace, zákaznický tok
informací.

Typické vlastní:

- co firma nabízí a jak se to popisuje
- zákaznická dokumentace
- názvy produktů/služeb a jejich konzistence
- zpětná vazba od zákazníků do roadmapy

Typické výstupy:

- update dokumentace
- rozhodnutí o pojmenování
- customer-facing vysvětlení
- zadání pro marketing nebo technický tým

Handoff:

- přebírá technické změny od `technical-lead`
- předává komunikační potřeby `marketing`
- přebírá feedback od `sales`, `support`, `delivery`

Co NEdělat:

- nevymýšlet technická fakta bez technického ownera
- nemíchat interní reasoning do veřejné dokumentace

### `sales`

**Scope:** vztahy s klienty, pipeline, nabídky, follow-upy, CRM/task systém.

Typické vlastní:

- nové leady a příležitosti
- nabídky a follow-up komunikace
- klientská očekávání
- obchodní forecast a stav pipeline

Typické výstupy:

- shrnutí příležitosti
- follow-up e-mail nebo zpráva
- podklady pro nabídku
- handoff do delivery / operations

Handoff:

- předává technické nejasnosti `technical-lead` nebo `delivery`
- předává fakturaci / administrativu `operations`
- předává case-study potenciál `marketing`

Co NEdělat:

- neslibovat technické, právní ani finanční závazky bez ownera
- neukládat klientská data mimo schválený source-of-truth

### `operations`

**Scope:** administrativa, provoz, finance, logistika, koordinace práce.

Typické vlastní:

- provozní checklisty a stav administrativy
- fakturace / objednávky / dodávky, pokud to firma používá
- koordinace interních termínů
- provozní reporting

Typické výstupy:

- provozní stav
- checklist dokončení
- podklady pro fakturaci nebo dodávku
- upozornění na blokér

Handoff:

- přebírá podklady od `sales` nebo `delivery`
- eskaluje cashflow/risk `founder`
- předává provozní změny do `wiki` nebo jiné interní vrstvy

Co NEdělat:

- nerozhodovat strategii místo ownera
- necommitovat finanční nebo osobní data do Gitu, pokud tam nepatří

### `marketing`

**Scope:** obsah, kampaně, case studies, brand konzistence, veřejná
komunikace.

Typické vlastní:

- publikovatelný obsah
- case studies a reference
- newslettery, sociální sítě, webové texty
- konzistence s tone of voice a design systémem

Typické výstupy:

- návrh postu / článku / newsletteru
- brief pro grafiku nebo web
- case-study osnova
- repurposing existujícího obsahu

Handoff:

- přebírá fakta od `product-owner`, `sales`, `delivery`
- ověřuje technická tvrzení s `technical-lead`
- u klientských referencí čeká na schválení ownera vztahu

Co NEdělat:

- nevymýšlet reference, výsledky ani klientská tvrzení
- neměnit design systém bez `design-system-lookup`

### `delivery`

**Scope:** doručení služby/projektu zákazníkovi, technická nebo procesní
realizace, feedback z praxe.

Typické vlastní:

- konkrétní klientský/projektový průběh
- implementační checklist
- předávka výsledku
- zpětná vazba do produktu, dokumentace nebo provozu

Typické výstupy:

- stav projektu / zakázky
- technický nebo procesní návrh realizace
- handoff do operations
- feedback pro `product-owner` nebo `technical-lead`

Handoff:

- přebírá schválený scope od `sales`
- předává provozní detaily `operations`
- eskaluje produktový nebo technický problém `product-owner` /
  `technical-lead`

Co NEdělat:

- neměnit rozsah zakázky bez obchodního ownera
- neřešit systémové bugy jen lokálním workaroundem

### `external-collaborator`

**Scope:** omezené, jasně zadané úkoly pro externistu, brigádníka nebo
dočasného spolupracovníka.

Typické vlastní:

- konkrétní task s jasným zadáním
- práce jen ve schválených modulech nebo souborech
- výstup připravený k review

Typické výstupy:

- návrh změny
- zpracovaná data / obsah / rešerše
- krátký handoff pro interního ownera

Handoff:

- přebírá zadání od interního ownera
- výstup vždy předává internímu ownerovi k review

Co NEdělat:

- nepředpokládat plný workspace access
- nepracovat s citlivými daty bez explicitního scope
- neposílat výstupy externě bez interního schválení

## Otázky pro ownera firmy

Při setupu se ptej krátce:

- Kdo ve firmě rozhoduje strategii a priority?
- Kdo vlastní technické / odborné rozhodování?
- Kdo komunikuje s klienty a drží pipeline?
- Kdo drží provoz, fakturaci, administrativu nebo logistiku?
- Kdo vlastní dokumentaci, produkt/službu a veřejné texty?
- Kdo doručuje práci zákazníkovi?
- Existují externisté nebo brigádníci s omezeným přístupem?
- Které role může držet jeden člověk současně?
- Kdy se agent má doptat na aktivní roli místo hádání?

## Minimální dobrý role model

Pro malou firmu často stačí:

- `founder`
- `technical-lead` nebo odborný owner služby
- `sales`
- `operations`
- `external-collaborator`, pokud firma pracuje s externisty

Marketing, product-owner a delivery se mohou sloučit s jinou rolí, dokud
firma nemá dost lidí nebo dost práce na jejich oddělení.
