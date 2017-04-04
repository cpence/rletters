// Common configuration for webpacker loaded from config/webpack/paths.yml

const { join, resolve } = require('path')
const { env } = require('process')
const { safeLoad } = require('js-yaml')
const { readFileSync } = require('fs')

const configPath = resolve('config', 'webpack')
const loadersDir = join(__dirname, 'loaders')
const paths = safeLoad(readFileSync(join(configPath, 'paths.yml'), 'utf8'))
const publicPath = `/${paths.entry}/`

module.exports = {
  env,
  paths,
  loadersDir,
  publicPath
}
