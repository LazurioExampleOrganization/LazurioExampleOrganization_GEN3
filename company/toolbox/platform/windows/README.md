# Windows Toolbox Notes

Sem patří `Windows`-specific dependency a install notes pro
`company/toolbox/`.

## Typické dependencies

Firma si vyplní podle capability:

- **`pdf-to-png`** (pokud je potřeba):
  [poppler-windows](https://github.com/oschwartz10612/poppler-windows)
  nebo ImageMagick (`winget install ImageMagick.ImageMagick`)
- **`audio-to-text`** (pokud je potřeba):
  `winget install Gyan.FFmpeg` + whisper engine
- další dependencies doplň až podle reálné capability

## winget

Většina Windows dependencies jde instalovat přes
[winget](https://learn.microsoft.com/en-us/windows/package-manager/winget/).
Pokud winget není dostupný, doctor check by měl hlásit missing dep.

## PowerShell

PowerShell 7+ je doporučené (Windows 10+ ma 5.1 default; upgrade
přes `winget install Microsoft.PowerShell`).

## Python

Pokud capability používá Python wrapper:

- Doporučená runtime management: Python Launcher + `pipx`, nebo `rye`
- Nepoužívat Microsoft Store Python pro toolbox (omezení
  filesystem access)
