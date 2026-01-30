## Lucian's dotfiles

[![CI](https://github.com/LucianBuzzo/dotfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/LucianBuzzo/dotfiles/actions/workflows/ci.yml)

Personal development environment setup for macOS and Linux, centered on Vim and
CLI tooling. What started as a Vim config is now the source of truth for my
editor, shell, and common tooling.

### Contents

- Vim configuration and plugins
- Shell scripts and command-line utilities
- VS Code settings and extensions

### Requirements

- Git
- Node.js + npm (for the install step below)
- Vim 7.3+ (newer is better)

### Installation

```bash
git clone --recursive git@github.com:LucianBuzzo/dotfiles.git .dotfiles
cd .dotfiles
./setup.sh
```

Dry run (no writes):

```bash
./setup.sh --dry-run
```

### VS Code

```bash
./vscode/install.sh
```

### Optional: Node tools

`npm install -g` will install the Node dependencies and also run `./setup.sh`
via `postinstall`.

### Bash

Main config lives in `bash/.bash_profile`. It includes aliases, functions, and a
directory-stack powered `cd` replacement.

| Command | Description |
| --- | --- |
| `reloadbash` | Reload the current Bash profile. |
| `ll` | List files with details (human readable, classify, show hidden). |
| `gs` | `git status`. |
| `mp` | Run `markdown-preview`. |
| `generatepass` | Generate a 16‑char password using `md5` on the current date. |
| `uistart` | Start `resin-ui` with staging API host. |
| `diary` | Open today’s journal file in `~/journal` with Vim. |
| `stagingCommit` | Fetch and print the current staging commit from resinstaging. |
| `dcup` | `docker-compose up --build`. |
| `assignment-start` | Build and run `smart-lighting-dashboard` on port 8000. |
| `assignment-stop` | Remove the `smart-lighting-dashboard` image. |
| `grep` | Use GNU `ggrep` if installed. |
| `vim` | Wrapper that preserves terminal settings for `<C-s>` mappings. |
| `findin` | Recursive text search using `grep -Rl`. |
| `findfilename` | Recursive filename search by pattern. |
| `update_aws_env_vars` | Write AWS profile keys into a local `.env` file. |
| `colors_ansi` | Print ANSI 16‑color reference table. |
| `colors_256` | Print ANSI 256‑color reference table. |
| `colors_solarized` | Print Solarized color reference table. |
| `eecho` | Echo to stderr. |
| `shiftStackUp` | Directory stack helper (internal). |
| `shiftStackDown` | Directory stack helper (internal). |
| `popStack` | Pop the top of the directory stack. |
| `pushStack` | Push a directory onto the stack (deduped). |
| `cd_` | `cd` replacement with stack + smart substitution. |
| `pd` | Push/pop directory stack and change directory. |
| `ss` | Show the directory stack (optionally filter). |
| `csd` | Change to a directory from the stack. |
| `cd` | Alias to `cd_` (directory stack aware). |
| `npm-which` | Resolve a binary from local `node_modules/.bin` if present. |
| `sops_decrypt` | Decrypt a `sops.*.yml` file to plaintext. |
| `sops_encrypt` | Encrypt a YAML file into `sops.*.yml`. |
| `rununtilfail` | Run a command in a loop until it fails. |
| `enterdockercontainer` | `docker exec -it ... bash`. |
| `ports` | List listening TCP ports; pass ports to filter (sudo). |
| `ecr_docker_login` | Login to ECR (us-east-1, fixed registry). |
| `mfa_aws_login` | MFA login and AWS profile setup for cerebrum token. |
| `merge_renovate_branches` | Merge all renovate/dependabot branches and push. |
| `gcm` | AI‑assisted git commit message workflow. |
| `docker_publish_ecr` | Build, tag, and push a Docker image to ECR. |
| `python` | Alias to `python3`. |

### Repo layout

```text
.
├── bash/        Bash config and helpers
├── vim/         Vim configuration
├── vscode/      VS Code settings and install script
├── setup.sh     Bootstrap/install entrypoint
└── README.md
```

### Updating

```bash
git pull --rebase
git submodule update --init --recursive
```
