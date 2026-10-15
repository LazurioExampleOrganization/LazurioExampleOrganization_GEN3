---
id: 19-commit-push-pr
title: "Jak se změna uloží a odešle"
section: 4-prvni-prace
order: 19
prerequisites: ["18-prvni-mission-control-plan-a-todo"]
duration_min: 14
quiz: true
ukol: true
---

# Jak se změna uloží a odešle

**Co se v této lekci naučíš:**
- co znamená commit, push a PR
- jak AgentMint používá commit a push ve workspace s GitHub remote
- jak poznat dobrou commit zprávu

## Tři slova bez paniky

**Commit** je uložený balíček změn s popisem. Je to záchytný bod v historii.

**Push** znamená, že se tvoje commity odešlou do sdíleného repozitáře, aby je viděli i ostatní. AgentMint má GitHub organizaci a remote, takže push je běžný krok po kontrole diffu a scope.

**PR** neboli pull request je žádost o review změny před sloučením. Používá se hlavně tam, kde to vyžaduje governance nebo větší vývojový zásah.

U netechnické práce často nebudeš dělat PR ručně. Důležité je rozumět principu: změna má být zkontrolovaná, popsaná a dohledatelná.

## Proč ne ručně

AgentMint workspace má víc repozitářů v `modules/`. Ruční Git příkazy mohou snadno posunout špatnou věc. Proto se používá doctor nebo specializovaný skill.

Pro jeden nested repo modul agent typicky použije scoped commit/push workflow.

Pro změny v hlavním workspace nebo ve více částech se používá `doctor push` s přesným omezením, čeho se změna týká.

Když se mění root task ledger a zároveň sdílená dokumentace, musí jít do
jednoho logického commitu nebo do jasně oddělených commitů. Agent má použít
scope typu:

```bash
company/scripts/doctor.sh push -m $'Workspace: Clarify first experiment loop\n\nUpdate task ledgers and onboarding docs for the first AgentMint experiment.' \
  --include TODO.tasks.json \
  --include guide/content/lekce/18-prvni-mission-control-plan-a-todo/lekce.md \
  --dry-run
```

Když nevíš, jaký tvar příkazu použít, zeptej se Doctora přes nápovědu:

```bash
company/scripts/doctor.sh push --help
```

Tohle je bezpečné. Nápověda nic necommitne ani nepushne. Naopak neznámý flag
Doctor odmítne, aby omylem neposlal něco jiného, než jsi zamýšlel/a.

## Dry-run nejdřív

Dry-run je zkušební běh. Ukáže, co by se stalo, ale nic necommitne ani
neodešle.

Příklad:

```bash
company/scripts/doctor.sh push -m $'Workspace: Add mechanism research task\n\nAdd the next AgentMint research step and its acceptance criteria.' \
  --include TODO.tasks.json \
  --dry-run
```

Agent by ti měl nejdřív ukázat náhled změn. Teprve po kontrole se pokračuje.

## Dobrá zpráva ke commitu

Špatná zpráva:

- `fix`
- `update`
- `changes`

Dobrá zpráva říká, co se změnilo a proč:

```text
Workspace: Add mechanism research task

Add the next AgentMint research step so the first mechanism scan has clear acceptance criteria.
```

Za měsíc z toho kolega pochopí dopad. To je cíl.

## Co hlídat

Do commitu nikdy nemají spadnout hesla, tokeny, soukromé nastavení, účty
platforem ani citlivé finanční exporty. U experimentů si hlídej, že do Gitu
nejde cizí zákaznický obsah nebo neveřejná data.

Když si nejsi jistý/á, řekni agentovi:

> „Před commitem mi ukaž diff a řekni, jestli v něm není něco soukromého nebo mimo zadání."

## Shrnutí

Commit uloží změnu, push ji odešle a PR umožní review. V AgentMint už remote
existuje, takže důležité je hlídat správný scope, nested repo hranice a dobrou
commit zprávu. Drž se Doctora a skills, protože chrání historii a pomáhají
změnu správně popsat.

**Příště:** co dělat, když něco nefunguje nebo se objeví chyba.
