hass = require './hass.coffee'
$ = require './hassTool.coffee'

path = require 'path'
glob = require 'glob'
_ = require 'underscore'

publicDir = path.join(__dirname, '..', '')

outDir = path.join(publicDir, 'demo/hass')
hassFileDir = path.join(publicDir, 'demo/hass', '*.hass')

sassDir = path.join(publicDir, 'demo/build/sass')
jadeDir = path.join(publicDir, 'demo/build/jade')

sassFileDir = path.join(sassDir, '*.sass')
jadeFileDir = path.join(jadeDir, '*.jade')

sassFileDir = path.join(sassFileDir, '*.sass')
jadeFileDir = path.join(jadeFileDir, '*.jade')

cssDir = path.join(publicDir, 'demo/build/css')
htmlDir = path.join(publicDir, 'demo/build/html')

options = {
  fileInputDir: hassFileDir,
  outputDir: outDir
}

glob hassFileDir, options, (er, files)->

  if er
    $.log 'ERROR: can\'t find file' + er
  else
    _.each files, (val, index)->
      fileSplit = val.split('/')
      fileName = fileSplit[fileSplit.length - 1].split('.')[0]

      sassFileDir = path.join(options.outputDir, 'sass', fileName + '.sass')
      jadeFileDir = path.join(options.outputDir, 'jade', fileName + '.jade')
      cssFileDir = path.join(options.outputDir, 'css', fileName + '.css')
      htmlFileDir = path.join(options.outputDir, 'html', fileName + '.html')

      # $.log 'compile ' + fileName + ' start'

      hass.render2SassAndJade(val, sassFileDir, jadeFileDir)
      hass.render2CssAndHtml(val, cssFileDir, htmlFileDir)
