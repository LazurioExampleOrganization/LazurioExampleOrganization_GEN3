# macOS Toolbox Notes

Sem patří `macOS`-specific dependency a install notes pro
`company/toolbox/`.

## Typické dependencies

Firma si vyplní podle capability, které používá:

- **`pdf-to-png`** (pokud je potřeba): `brew install poppler` pro
  `pdftoppm` binárku
- **`audio-to-text`** (pokud je potřeba): `brew install ffmpeg` +
  whisper engine (`whisper.cpp` build nebo openai-whisper pip)
- další dependencies doplň až podle reálné capability

## Homebrew

Většina macOS dependencies jde instalovat přes
[Homebrew](https://brew.sh/). Pokud Homebrew není dostupný, doctor
check by měl hlásit missing dep.

## Python

Pokud capability používá Python wrapper:

- Doporučená runtime management: `rye`, `uv`, nebo `pipx`
- Nepoužívat systémový `/usr/bin/python3` pro toolbox deps (kolize
  s OS)
