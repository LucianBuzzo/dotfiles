const { execSync } = require('child_process')
const fs = require('fs')
const path = require('path')

const zshrcPath = path.join(__dirname, '..', 'zsh', '.zshrc')
const TEST_PATH = '/usr/bin:/bin:/usr/sbin:/sbin'

describe('zshrc', () => {
  it('loads zsh-vi-mode when a plugin path is provided and configures mode-specific cursors', () => {
    const tempHome = fs.mkdtempSync(path.join(process.env.TMPDIR || '/tmp', 'zsh-home-'))
    const pluginDir = fs.mkdtempSync(path.join(process.env.TMPDIR || '/tmp', 'zsh-vi-mode-'))
    const pluginPath = path.join(pluginDir, 'zsh-vi-mode.plugin.zsh')

    try {
      fs.writeFileSync(
        pluginPath,
        [
          'zvm_init() { :; }',
          'zvm_cursor_style() {',
          '  printf "%s" "$1"',
          '}',
          'if typeset -f zvm_config >/dev/null 2>&1; then',
          '  zvm_config',
          'fi',
          'export ZSH_VI_MODE_PLUGIN_SOURCED=1',
          '',
        ].join('\n')
      )

      const result = execSync(
        `env -i HOME="${tempHome}" PATH="${TEST_PATH}" ZSH_VI_MODE_PLUGIN_PATH="${pluginPath}" zsh -c 'source "${zshrcPath}" >/dev/null 2>&1; printf "%s:%s:%s:%s" "\${ZSH_VI_MODE_PLUGIN_SOURCED:-0}" "\${ZVM_CURSOR_STYLE_ENABLED:-unset}" "\${ZVM_NORMAL_MODE_CURSOR}" "\${ZVM_INSERT_MODE_CURSOR}"'`,
        { encoding: 'utf8' }
      ).trim()

      expect(result).toContain('1:true:')
      expect(result).not.toContain('#ff8800')
      expect(result).not.toContain('#00aa00')
    } finally {
      fs.rmSync(tempHome, { recursive: true, force: true })
      fs.rmSync(pluginDir, { recursive: true, force: true })
    }
  })

  it('loads nvm from ~/.nvm so global node binaries are available in zsh', () => {
    const tempHome = fs.mkdtempSync(path.join(process.env.TMPDIR || '/tmp', 'zsh-home-'))
    const nvmDir = path.join(tempHome, '.nvm')
    const binDir = path.join(nvmDir, 'versions', 'node', 'v1.0.0', 'bin')
    const nvmShPath = path.join(nvmDir, 'nvm.sh')
    const codexPath = path.join(binDir, 'codex')

    try {
      fs.mkdirSync(binDir, { recursive: true })
      fs.writeFileSync(codexPath, '#!/bin/sh\nexit 0\n')
      fs.chmodSync(codexPath, 0o755)
      fs.writeFileSync(nvmShPath, `export PATH="${binDir}:$PATH"\n`)

      const result = execSync(
        `env -i HOME="${tempHome}" PATH="${TEST_PATH}" zsh -c 'source "${zshrcPath}" >/dev/null 2>&1; command -v codex'`,
        { encoding: 'utf8' }
      ).trim()

      expect(result).toBe(codexPath)
    } finally {
      fs.rmSync(tempHome, { recursive: true, force: true })
    }
  })

  it('configures atuin with the custom down-arrow widget', () => {
    const tempHome = fs.mkdtempSync(path.join(process.env.TMPDIR || '/tmp', 'zsh-home-'))
    const tempBin = fs.mkdtempSync(path.join(process.env.TMPDIR || '/tmp', 'zsh-bin-'))
    const atuinPath = path.join(tempBin, 'atuin')

    try {
      fs.writeFileSync(
        atuinPath,
        [
          '#!/bin/sh',
          'if [ "$1" = "init" ] && [ "$2" = "zsh" ] && [ "$3" = "--disable-up-arrow" ]; then',
          '  cat <<\'EOF\'',
          'atuin-search() { :; }',
          'atuin-search-viins() { :; }',
          'atuin-search-vicmd() { :; }',
          'EOF',
          'fi',
          '',
        ].join('\n')
      )
      fs.chmodSync(atuinPath, 0o755)

      const result = execSync(
        `env -i HOME="${tempHome}" PATH="${tempBin}:${TEST_PATH}" zsh -c 'source "${zshrcPath}" >/dev/null 2>&1; printf "%s:%s:%s" "$(bindkey "^[[B")" "$(bindkey -M viins "^[[B")" "$(bindkey -M vicmd j)"'`,
        { encoding: 'utf8' }
      ).trim()

      expect(result).toContain('down-line-or-search-but-atuin-if-at-end')
    } finally {
      fs.rmSync(tempHome, { recursive: true, force: true })
      fs.rmSync(tempBin, { recursive: true, force: true })
    }
  })
})
