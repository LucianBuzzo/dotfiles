const { execSync } = require('child_process')
const fs = require('fs')
const path = require('path')

const bashProfilePath = path.join(__dirname, '..', 'bash', '.bash_profile')

// Helper to run bash commands with the profile sourced
const runBash = (command) => {
  // Use a temporary file to mock the environment if needed, 
  // but for these functions we can mostly just source and run.
  // We use 'env -i' to start with a clean environment, but we need PATH.
  return execSync(`bash -c 'source ${bashProfilePath} && ${command}'`, {
    env: { ...process.env, HOME: process.env.HOME },
    encoding: 'utf8'
  }).trim()
}

describe('bash_profile functions', () => {
  describe('findfilename', () => {
    it('should find files by name', () => {
      const result = runBash('findfilename package.json')
      expect(result).toContain('./package.json')
    })

    it('should show usage when no argument is provided', () => {
      try {
        runBash('findfilename')
      } catch (error) {
        expect(error.stdout).toContain('Usage: findfilename <pattern>')
      }
    })
  })

  describe('eecho', () => {
    it('should echo to stderr', () => {
      // In bash, 2>&1 redirects stderr to stdout for us to capture
      const result = execSync(`bash -c 'source ${bashProfilePath} && eecho "test message" 2>&1'`, {
        encoding: 'utf8'
      }).trim()
      expect(result).toBe('test message')
    })
  })

  describe('directory stack functions', () => {
    it('pushStack and popStack should manage a stack', () => {
      const result = runBash('pushStack "/tmp" && pushStack "/var" && popStack')
      expect(result).toBe('/var')
    })

    it('popStack should show error when empty', () => {
      try {
        // We need to clear DS or run in subshell where it is empty
        runBash('DS=() && popStack 2>&1')
      } catch (error) {
         expect(error.stdout).toContain('Cannot pop stack')
      }
    })
  })

  describe('npm-which', () => {
    it('should return path to a binary', () => {
      // Assuming 'ls' is in path, npm-which should find it if not in node_modules
      const result = runBash('npm-which ls')
      expect(result).toContain('ls')
    })
  })

  describe('findin', () => {
    it('should find text in files', () => {
      const result = runBash('findin "Lucian" package.json')
      expect(result).toContain('package.json')
    })
  })

  describe('colors functions', () => {
    it('colors_ansi should output color codes', () => {
      const result = runBash('colors_ansi')
      expect(result).toContain('\x1b[')
    })

    it('colors_256 should output color codes', () => {
      const result = runBash('colors_256')
      expect(result).toContain('\x1b[48;5;')
    })

    it('colors_solarized should output solarized color info', () => {
      const result = runBash('colors_solarized')
      expect(result).toContain('SOLARIZED')
    })
  })

  describe('cd_ and pd', () => {
    it('should navigate and update stack', () => {
      const tempDir = fs.mkdtempSync(path.join(process.env.TMPDIR || '/tmp', 'bash-test-'))
      try {
        const result = runBash(`cd_ "${tempDir}" && pwd`)
        expect(result).toBe(tempDir)
      } finally {
        fs.rmdirSync(tempDir)
      }
    })

    it('pd should swap directories on stack', () => {
      const dirA = fs.mkdtempSync(path.join(process.env.TMPDIR || '/tmp', 'dirA-'))
      const dirB = fs.mkdtempSync(path.join(process.env.TMPDIR || '/tmp', 'dirB-'))
      try {
        // Navigate to A, then pd to B. Stack should have A.
        const result = runBash(`cd "${dirA}" && pd "${dirB}" && popStack`)
        expect(result).toBe(dirA)
      } finally {
        fs.rmdirSync(dirA)
        fs.rmdirSync(dirB)
      }
    })
  })

})
