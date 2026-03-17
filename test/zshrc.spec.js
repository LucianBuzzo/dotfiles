const { execSync } = require('child_process')
const fs = require('fs')
const path = require('path')

const zshrcPath = path.join(__dirname, '..', 'zsh', '.zshrc')
const TEST_PATH = '/usr/bin:/bin:/usr/sbin:/sbin'

describe('zshrc', () => {
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
})
