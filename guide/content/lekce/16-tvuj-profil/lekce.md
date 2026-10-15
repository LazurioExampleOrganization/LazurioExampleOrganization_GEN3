---
id: 16-tvuj-profil
title: "Tvoje místo ve workspace"
section: 4-prvni-prace
order: 16
prerequisites: ["15-mcp-servery"]
duration_min: 12
quiz: true
ukol: true
---

# Tvoje místo ve workspace

**Co se v této lekci naučíš:**
- proč má každý kolega vlastní složku
- co do ní patří
- co do ní nikdy nedávat

## Proč máš vlastní složku

V GEN2 má každý kolega svoje místo v `company/colleagues/<jmeno>/`. Není to soukromý zápisník. Je to pracovní profil, podle kterého se workspace a agent lépe orientují.

Typicky v něm je:

- kdo jsi a jakou máš roli
- jaký máš pracovní kontakt a případné externí task-manager ID
- jak má agent s tebou komunikovat
- jaké máš osobní postupy nebo skills
- jak se má otevřít tvůj VS Code nebo Cursor workspace

Agent díky tomu ví, jestli mluví s founderem, research operátorem nebo experiment operátorem.

## Co se sdílí

Do Gitu se ukládají věci, které mohou vidět kolegové:

- `README.md`
- `AGENTS.md`
- `.gitignore`
- `workspace.code-workspace`
- osobní skills, pokud je chceš sdílet
- malé pomocné skripty nebo šablony

Tvoje složka je součástí hlavního workspace. Není to submodul a nezakládá se zvlášť.

## Co zůstává jen u tebe

Do Gitu nikdy nedávej:

- hesla
- API klíče
- osobní tokeny
- soukromé nastavení editoru
- náhodné poznámky nebo scratch soubory

Takové věci patří do souborů, které jsou v `.gitignore`, nebo do bezpečného úložiště. Když si nejsi jistý/á, zeptej se agenta dřív, než něco uložíš.

## Jak profil vznikne

Začíná se ze šablony v `company/colleagues/_template/`. Tu zkopíruješ do nové složky se svým jménem, vyplníš základní údaje a zkontroluješ, že tam nejsou žádné tajné informace.

Nemusíš to dělat ručně bez pomoci. Řekni agentovi:

> „Pomoz mi založit profil v `company/colleagues/` podle šablony. Než cokoliv uložíš, ukaž mi, co budeš měnit."

## Shrnutí

Tvoje složka v `company/colleagues/` říká workspace, kdo jsi a jak s tebou pracovat. Sdílí se pracovní profil a pravidla, ne soukromé tokeny ani hesla.

**Příště:** podíváme se na role v AgentMint a na to, jak agent pozná, co se od tebe v práci očekává.
