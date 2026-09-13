# Dotfiles de Nacho inspirado en fraruiz/dotfiles

## 🚀 Instalación

### ⚠️ Atención (para mac):

- Instalar [brew]("https://brew.sh/")

1. Generar un **Project Access Token** en
   [gitlab.com/log.os/dotfiles/-/settings/access_tokens](https://gitlab.com/log.os/dotfiles/-/settings/access_tokens)
   con scope `read_api`. Copiar el valor (no se vuelve a mostrar).

2. Ejeutar el instalador pasándole el token como argumento (no se persiste en
   ningún lado, se usa una sola vez para bajar las 3 vars de Infisical):
   ```bash
   bash <(curl -fsSL https://gitlab.com/log.os/dotfiles/-/raw/master/installer) <token>
   ```
   El instalador clona el repo desde GitLab, corre `dot self install` (que
   instala el CLI de Infisical si falta) y termina haciendo login en Infisical
   para dejar las env vars disponibles en cada shell nuevo.

3. Cambiar el shell a zsh
    ```bash
    chsh -s $(which zsh)
    ```

## 🔰 Actualizar
```bash
dot self update
```

## 🔐 Secrets (Infisical)

Los secretos viven centralizados en una instancia de
[Infisical](https://infisical.com/) (la URL se guarda como
`DOTF_INFISICAL_URL` en GitLab, ver abajo). El repo guarda 3 vars en GitLab
que permiten loguearse al CLI con un service token de solo lectura:

- `DOTF_INFISICAL_PROJECT` — id del proyecto en Infisical
- `DOTF_INFISICAL_URL` — URL de la instancia
- `DOTF_INFISICAL_TOKEN_DEPLOY` — service token readonly

El installer trae una copia local a `$DOTFILES_PATH/secrets/envs.env`
(gitignored, mode 600) que el shell hace source al iniciar — cero latencia
por terminal.

### Bootstrap (una vez por máquina)

Si instalaste con el one-liner, ya quedó hecho. Si querés forzar un
re-bootstrap (token rotado, etc.), exportá el token y corré:

```bash
export DOTF_GITLAB_TOKEN=glpat-xxxxxxxxxxxxxxxxxxxx
dot secrets bootstrap
```

Si preferís prompt interactivo, omití la env var y el script te la pide
(oculta lo tipeado). El CLI de Infisical se instala solo si falta (`brew` en
mac, script oficial en linux).

El bootstrap es **idempotente**: si `$DOTFILES_PATH/secrets/envs.env` ya existe,
lo deja como está y avisa que corras `dot secrets refresh` si querés
actualizar.

### Uso diario

- `dot secrets refresh` — re-trae las envs de Infisical al dump local
  (después de rotar/agregar un secret).
- `source $DOTFILES_PATH/secrets/envs.env` — recargar en la shell actual sin
  reiniciar.
- Las env vars ya están disponibles en cada shell nuevo vía
  `shell/exports.sh`.

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
