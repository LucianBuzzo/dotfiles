const { execSync } = require('child_process')
const fs = require('fs')
const path = require('path')

const CWD = process.cwd()
const TEST_PATH = '/usr/bin:/bin:/usr/sbin:/sbin'
let TEST_HOME
let TEST_VSCODE_USER_DIR

describe('setup.sh', () => {
  beforeAll(() => {
    TEST_HOME = fs.mkdtempSync(path.join(process.env.TMPDIR || '/tmp', 'dotfiles-home-'))
    TEST_VSCODE_USER_DIR = path.join(TEST_HOME, 'vscode-user')

    execSync('./setup.sh --yes', {
      cwd: CWD,
      env: {
        ...process.env,
        HOME: TEST_HOME,
        PATH: TEST_PATH,
        SKIP_HOMEBREW_CLI_TOOLS: '1',
        SKIP_VSCODE_EXTENSIONS: '1',
        VSCODE_USER_DIR: TEST_VSCODE_USER_DIR,
      },
      stdio: 'ignore',
    })
  })

  afterAll(() => {
    fs.rmSync(TEST_HOME, { recursive: true, force: true })
  })

  it('should create a symlink for .vimrc in the home directory', () => {
    const linkPath = path.join(TEST_HOME, '.vimrc')
    const stats = fs.lstatSync(linkPath)
    expect(!!stats && stats.isSymbolicLink()).toBe(true)

    const linkTargetPath = fs.readlinkSync(linkPath)
    expect(linkTargetPath).toBe(path.join(CWD, 'vim', '.vimrc'))
  })

  it('should create the .vimbackups/ directory in the home directory', () => {
    const dirPath = path.join(TEST_HOME, '.vimbackups')
    const stats = fs.lstatSync(dirPath)
    expect(stats.isDirectory()).toBe(true)
  })

  it('should create a symlink for vim/ in the home directory', () => {
    const linkPath = path.join(TEST_HOME, '.config', 'nvim')
    const stats = fs.lstatSync(linkPath)
    expect(!!stats && stats.isSymbolicLink()).toBe(true)

    const linkTargetPath = fs.readlinkSync(linkPath)
    expect(linkTargetPath).toBe(path.join(CWD, 'vim'))
  })

  it('should create a symlink for .zshrc in the home directory', () => {
    const linkPath = path.join(TEST_HOME, '.zshrc')
    const stats = fs.lstatSync(linkPath)
    expect(!!stats && stats.isSymbolicLink()).toBe(true)

    const linkTargetPath = fs.readlinkSync(linkPath)
    expect(linkTargetPath).toBe(path.join(CWD, 'zsh', '.zshrc'))
  })

  it('should create a symlink for the starship config in the config directory', () => {
    const linkPath = path.join(TEST_HOME, '.config', 'starship.toml')
    const stats = fs.lstatSync(linkPath)
    expect(!!stats && stats.isSymbolicLink()).toBe(true)

    const linkTargetPath = fs.readlinkSync(linkPath)
    expect(linkTargetPath).toBe(path.join(CWD, 'starship.toml'))
  })

  it('should create a symlink for the Ghostty config in the app support directory on macOS', () => {
    const linkPath = path.join(TEST_HOME, 'Library', 'Application Support', 'com.mitchellh.ghostty', 'config')
    const stats = fs.lstatSync(linkPath)
    expect(!!stats && stats.isSymbolicLink()).toBe(true)

    const linkTargetPath = fs.readlinkSync(linkPath)
    expect(linkTargetPath).toBe(path.join(CWD, 'ghostty', 'config'))
  })

  it('should create a symlink for the Ghostty config in .config on Linux', () => {
    const linuxHome = fs.mkdtempSync(path.join(process.env.TMPDIR || '/tmp', 'dotfiles-linux-home-'))
    const linuxVscodeDir = path.join(linuxHome, 'vscode-user')

    try {
      execSync('./setup.sh --yes', {
        cwd: CWD,
        env: {
          ...process.env,
          HOME: linuxHome,
          PATH: TEST_PATH,
          SKIP_HOMEBREW_CLI_TOOLS: '1',
          SKIP_VSCODE_EXTENSIONS: '1',
          VSCODE_USER_DIR: linuxVscodeDir,
          UNAME_S: 'Linux',
        },
        stdio: 'ignore',
      })

      const linkPath = path.join(linuxHome, '.config', 'ghostty', 'config')
      const stats = fs.lstatSync(linkPath)
      expect(!!stats && stats.isSymbolicLink()).toBe(true)

      const linkTargetPath = fs.readlinkSync(linkPath)
      expect(linkTargetPath).toBe(path.join(CWD, 'ghostty', 'config'))
    } finally {
      fs.rmSync(linuxHome, { recursive: true, force: true })
    }
  })

})
