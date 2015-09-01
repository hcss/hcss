hass = require './hass.coffee'
$ = require './hassTool.coffee'

path = require 'path'

publicDir = path.join(__dirname, '..', '')
hassDir = path.join(publicDir, 'demo/hass', 'layout.hass')

sassDir = path.join(publicDir, 'demo/build/sass', 'layout.sass')
jadeDir = path.join(publicDir, 'demo/build/jade', 'layout.jade')

cssDir = path.join(publicDir, 'demo/build/css', 'layout.css')
htmlDir = path.join(publicDir, 'demo/build/html', 'layout.html')


$.log '1 compile' + hassDir + ' once...'
hass.render2SassAndJade(hassDir, sassDir, jadeDir)
hass.render2CssAndHtml(hassDir, cssDir, htmlDir)