const { execSync } = require('child_process')
const fs = require('fs')
const { homedir } = require('os')
const path = require('path')

const HOME = homedir()
const CWD = process.cwd()

describe('setup.sh', () => {
  execSync('./setup.sh',  { stdio: [0, 1, 2] })

  it('should create a symlink for .vimrc in the home directory', () => {
    const linkPath = path.join(HOME, '.vimrc')
    const stats = fs.lstatSync(linkPath)
    expect(!!stats && stats.isSymbolicLink()).toBe(true)

    const linkTargetPath = fs.readlinkSync(linkPath)
    expect(linkTargetPath).toBe(path.join(CWD, 'vim', '.vimrc'))
  })

  it('should create the .vimbackups/ directory in the home directory', () => {
    const dirPath = path.join(HOME, '.vimbackups')
    const stats = fs.lstatSync(dirPath)
    expect(stats.isDirectory()).toBe(true)
  })

  it('should create a symlink for vim/ in the home directory', () => {
    const linkPath = path.join(HOME, '.config', 'nvim')
    const stats = fs.lstatSync(linkPath)
    expect(!!stats && stats.isSymbolicLink()).toBe(true)

    const linkTargetPath = fs.readlinkSync(linkPath)
    expect(linkTargetPath).toBe(path.join(CWD, 'vim'))
  })

  it('should create a symlink for .inputrc in the home directory', () => {
    const linkPath = path.join(HOME, '.inputrc')
    const stats = fs.lstatSync(linkPath)
    expect(!!stats && stats.isSymbolicLink()).toBe(true)

    const linkTargetPath = fs.readlinkSync(linkPath)
    expect(linkTargetPath).toBe(path.join(CWD, '.inputrc'))
  })

  it('should create a symlink for .bash_profile in the home directory', () => {
    const linkPath = path.join(HOME, '.bash_profile')
    const stats = fs.lstatSync(linkPath)
    expect(!!stats && stats.isSymbolicLink()).toBe(true)

    const linkTargetPath = fs.readlinkSync(linkPath)
    expect(linkTargetPath).toBe(path.join(CWD, 'bash', '.bash_profile'))
  })

})
