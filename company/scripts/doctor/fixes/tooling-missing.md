# Fix: tooling missing

Doctor hlásí: **`[warn] <tool> není v PATH`**.

## Co to znamená

Jeden ze základních nástrojů (git, jq, bun, node) není dostupný na PATH.
Doctor ho potřebuje pro svoje checks a základní operace.

## Fix podle OS

### macOS

```bash
brew install git jq node
curl -fsSL https://bun.sh/install | bash
```

Po instalaci restartuj shell nebo zdroj ~/.zshrc.

### Windows

```powershell
winget install -e --id Git.Git
winget install -e --id jqlang.jq
winget install -e --id OpenJS.NodeJS

# Bun pro Windows:
powershell -c "irm bun.sh/install.ps1 | iex"
```

Po instalaci restartuj PowerShell.

## Verifikace

```bash
git --version
jq --version
node --version
bun --version
```

Všechny čtyři by měly vypsat verzi. Pak spusť `doctor check` znovu.

## Alternativa

Pokud tým používá nvm/volta pro Node, nastav default verzi:

```bash
# nvm
nvm install 22 && nvm alias default 22

# volta
volta install node@22
```
