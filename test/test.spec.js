const { expect } = require('chai')
const { execSync } = require('child_process')
const fs = require('fs')
const { homedir } = require('os')
const path = require('path')

const HOME = homedir()
const CWD = process.cwd()

describe('setup.sh', () => {
  execSync('sh setup.sh -y',  { stdio: [0, 1, 2] })

  it('should create a symlink for .vimrc in the home directory', () => {
    const linkPath = path.join(HOME, '.vimrc')
    const stats = fs.lstatSync(linkPath)
    expect(!!stats && stats.isSymbolicLink()).to.be.true

    const linkTargetPath = fs.readlinkSync(linkPath)
    expect(linkTargetPath).to.equal(path.join(CWD, 'vim', '.vimrc'))
  })

  it('should create a symlink for .vimbackups/ in the home directory', () => {
    const linkPath = path.join(HOME, '.vimbackups')
    const stats = fs.lstatSync(linkPath)
    expect(!!stats && stats.isSymbolicLink()).to.be.true

    const linkTargetPath = fs.readlinkSync(linkPath)
    expect(linkTargetPath).to.equal(path.join(CWD, 'vim', '.vimbackups/'))
  })

  it('should create a symlink for vim/ in the home directory', () => {
    const linkPath = path.join(HOME, '.config', 'nvim')
    const stats = fs.lstatSync(linkPath)
    expect(!!stats && stats.isSymbolicLink()).to.be.true

    const linkTargetPath = fs.readlinkSync(linkPath)
    expect(linkTargetPath).to.equal(path.join(CWD, 'vim/'))
  })

  it('should create a symlink for .inputrc in the home directory', () => {
    const linkPath = path.join(HOME, '.inputrc')
    const stats = fs.lstatSync(linkPath)
    expect(!!stats && stats.isSymbolicLink()).to.be.true

    const linkTargetPath = fs.readlinkSync(linkPath)
    expect(linkTargetPath).to.equal(path.join(CWD, '.inputrc'))
  })

  it('should create a symlink for .bash_profile in the home directory', () => {
    const linkPath = path.join(HOME, '.bash_profile')
    const stats = fs.lstatSync(linkPath)
    expect(!!stats && stats.isSymbolicLink()).to.be.true

    const linkTargetPath = fs.readlinkSync(linkPath)
    expect(linkTargetPath).to.equal(path.join(CWD, 'bash', '.bash_profile'))
  })

  it('should create a symlink for oni config in the home directory', () => {
    const linkPath = path.join(HOME, '.oni', 'config.js')
    const stats = fs.lstatSync(linkPath)
    expect(!!stats && stats.isSymbolicLink()).to.be.true

    const linkTargetPath = fs.readlinkSync(linkPath)
    expect(linkTargetPath).to.equal(path.join(CWD, 'oni.config.js'))
  })
})
