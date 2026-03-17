const { execSync } = require('child_process')
const fs = require('fs')
const path = require('path')

const zshrcPath = path.join(__dirname, '..', 'zsh', '.zshrc')
const TEST_PATH = '/usr/bin:/bin:/usr/sbin:/sbin'

const runZsh = (command) => {
  const tempHome = fs.mkdtempSync(path.join(process.env.TMPDIR || '/tmp', 'zsh-home-'))

  try {
    return execSync(`env -i HOME="${tempHome}" PATH="${TEST_PATH}" zsh -c 'source "${zshrcPath}" >/dev/null 2>&1; ${command}'`, {
      cwd: path.join(__dirname, '..'),
      encoding: 'utf8',
    }).trim()
  } finally {
    fs.rmSync(tempHome, { recursive: true, force: true })
  }
}

describe('zsh helper commands', () => {
  describe('findfilename', () => {
    it('should find files by name', () => {
      const result = runZsh('findfilename package.json')
      expect(result).toContain('./package.json')
    })

    it('should show usage when no argument is provided', () => {
      try {
        runZsh('findfilename')
      } catch (error) {
        expect(error.stdout).toContain('Usage: findfilename <pattern>')
      }
    })
  })

  describe('eecho', () => {
    it('should echo to stderr', () => {
      const tempHome = fs.mkdtempSync(path.join(process.env.TMPDIR || '/tmp', 'zsh-home-'))

      try {
        const result = execSync(`env -i HOME="${tempHome}" PATH="${TEST_PATH}" zsh -c 'source "${zshrcPath}" >/dev/null 2>&1; eecho "test message" 2>&1'`, {
          cwd: path.join(__dirname, '..'),
          encoding: 'utf8'
        }).trim()
        expect(result).toBe('test message')
      } finally {
        fs.rmSync(tempHome, { recursive: true, force: true })
      }
    })
  })

  describe('directory stack functions', () => {
    it('pushStack and popStack should manage a stack', () => {
      const result = runZsh('pushStack "/tmp" && pushStack "/var" && popStack')
      expect(result).toBe('/var')
    })

    it('popStack should show error when empty', () => {
      try {
        runZsh('DS=(); popStack 2>&1')
      } catch (error) {
         expect(error.stdout).toContain('Cannot pop stack')
      }
    })
  })

  describe('npm-which', () => {
    it('should return path to a binary', () => {
      const result = runZsh('npm-which ls')
      expect(result).toContain('ls')
    })
  })

  describe('findin', () => {
    it('should find text in files', () => {
      const result = runZsh('findin "Lucian" package.json')
      expect(result).toContain('package.json')
    })
  })

  describe('colors functions', () => {
    it('colors_ansi should output color codes', () => {
      const result = runZsh('colors_ansi')
      expect(result).toContain('\x1b[')
    })

    it('colors_256 should output color codes', () => {
      const result = runZsh('colors_256')
      expect(result).toContain('\x1b[48;5;')
    })

    it('colors_solarized should output solarized color info', () => {
      const result = runZsh('colors_solarized')
      expect(result).toContain('SOLARIZED')
    })
  })

  describe('cd_ and pd', () => {
    it('should navigate and update stack', () => {
      const tempDir = fs.mkdtempSync(path.join(process.env.TMPDIR || '/tmp', 'zsh-test-'))
      try {
        const result = runZsh(`cd_ "${tempDir}" && pwd`)
        expect(result).toBe(tempDir)
      } finally {
        fs.rmSync(tempDir, { recursive: true, force: true })
      }
    })

    it('pd should swap directories on stack', () => {
      const dirA = fs.mkdtempSync(path.join(process.env.TMPDIR || '/tmp', 'dirA-'))
      const dirB = fs.mkdtempSync(path.join(process.env.TMPDIR || '/tmp', 'dirB-'))
      try {
        const result = runZsh(`builtin cd "${dirA}" && pd "${dirB}" && popStack`)
        expect(result).toBe(dirA)
      } finally {
        fs.rmSync(dirA, { recursive: true, force: true })
        fs.rmSync(dirB, { recursive: true, force: true })
      }
    })
  })
})
