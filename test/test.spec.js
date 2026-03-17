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
        SKIP_BLE_SH_INSTALL: '1',
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

  it('should link git completion into the home directory when a source is provided', () => {
    const tempSourceDir = fs.mkdtempSync(path.join(process.env.TMPDIR || '/tmp', 'git-completion-'))
    const completionSource = path.join(tempSourceDir, 'git-completion.bash')

    fs.writeFileSync(completionSource, '# fake git completion\n')

    try {
      execSync('./setup.sh --yes', {
        cwd: CWD,
        env: {
          ...process.env,
          HOME: TEST_HOME,
          PATH: TEST_PATH,
          SKIP_BLE_SH_INSTALL: '1',
          SKIP_HOMEBREW_CLI_TOOLS: '1',
          SKIP_VSCODE_EXTENSIONS: '1',
          VSCODE_USER_DIR: TEST_VSCODE_USER_DIR,
          GIT_COMPLETION_SOURCE: completionSource,
        },
        stdio: 'ignore',
      })

      const linkPath = path.join(TEST_HOME, '.git-completion.bash')
      const stats = fs.lstatSync(linkPath)
      expect(stats.isSymbolicLink()).toBe(true)

      const linkTargetPath = fs.readlinkSync(linkPath)
      expect(linkTargetPath).toBe(completionSource)
    } finally {
      fs.rmSync(tempSourceDir, { recursive: true, force: true })
    }
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

  it('should create a symlink for .inputrc in the home directory', () => {
    const linkPath = path.join(TEST_HOME, '.inputrc')
    const stats = fs.lstatSync(linkPath)
    expect(!!stats && stats.isSymbolicLink()).toBe(true)

    const linkTargetPath = fs.readlinkSync(linkPath)
    expect(linkTargetPath).toBe(path.join(CWD, '.inputrc'))
  })

  it('should create a symlink for .bash_profile in the home directory', () => {
    const linkPath = path.join(TEST_HOME, '.bash_profile')
    const stats = fs.lstatSync(linkPath)
    expect(!!stats && stats.isSymbolicLink()).toBe(true)

    const linkTargetPath = fs.readlinkSync(linkPath)
    expect(linkTargetPath).toBe(path.join(CWD, 'bash', '.bash_profile'))
  })

})
