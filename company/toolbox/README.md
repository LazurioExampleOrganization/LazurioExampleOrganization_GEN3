# Toolbox

`company/toolbox/` je místo pro malé cross-platform utility, které pomáhají
lidem i agentům v AgentMint.

Aktuální stav: žádné AgentMint-specific utility nejsou založené.

Pravidla:

- capability pojmenuj stejně na macOS i Windows
- neukládej secrets ani machine-local absolutní cesty
- pokud se postup opakuje hlavně v agentní práci, zvaž raději skill v
  `.claude/skills/`
- pokud utility mění externí službu nebo peníze, musí mít approval krok
