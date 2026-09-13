# Dotfiles de Nacho inspirado en fraruiz/dotfiles

## 🚀 Instalación

### ⚠️ Atención (para mac):

- Instalar [brew]("https://brew.sh/")


1. Ejeutar Instalador
   ```bash
   bash <(curl -s https://raw.githubusercontent.com/logos914/dotfiles/HEAD/installer)
   ```
2. Cambiar el shell a zsh
    ```bash
    chsh -s $(which zsh)
    ```

## 🔰 Actualizar
```bash
dot self update
```

## 🤖 Configuración de asistentes (Claude Code / opencode)

Las configuraciones viven en el repo y el instalador las linkea al vuelo
(`dot symlinks apply`, que ya corre dentro de `dot self install`):

| En el repo          | Symlink en el sistema        |
| ------------------- | ---------------------------- |
| `claude/<item>`     | `~/.claude/<item>`           |
| `opencode/<item>`   | `~/.config/opencode/<item>`  |

Se linkea **cada archivo/carpeta** de `claude/` y `opencode/` por separado —
nunca el directorio completo— para que Claude Code y opencode sigan guardando
su estado (sesiones, credenciales, caché, `node_modules`) fuera de los dotfiles.

Lo que ya existía se respalda como `<archivo>.<timestamp>.back`, y volver a
correr `dot symlinks apply` no duplica symlinks ya correctos.

Para traer al repo config nueva —o recuperar la que alguna herramienta haya
reescrito pisando el symlink:

```bash
dot claude backup      # ~/.claude          -> claude/
dot opencode backup    # ~/.config/opencode -> opencode/
dot symlinks apply     # y se vuelve a linkear
```

El backup copia solo configuración (`settings.json`, `CLAUDE.md`, `agents/`,
`opencode.jsonc`, `AGENTS.md`, `plugin/`…). Sesiones, credenciales, caché, base
de datos y `node_modules` nunca entran al repo.

## 🦾 Herramientas
- [SDKMAN](https://sdkman.io/) for install programming languages
- [Docker](https://www.docker.com/) installer
- [ZIM Framework](https://zimfw.sh/)
- [Aliases](https://raw.githubusercontent.com/logos914/dotfiles/master/shell/aliases.sh)


## 🥳 Inspirado en:

- [Dotly](https://github.com/CodelyTV/dotly)
. [Dotfiles de Francisco Ruiz](https://github.com/fraruiz/dotfiles) 

## ⚖️ Licencia
The MIT License (MIT). Please see [License](LICENSE) for more information.
