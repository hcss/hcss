#!/usr/local/bin/node

exec = require 'child_process'
path = require 'path'
fs = require 'fs'
iconv = require 'iconv-lite'
async = require 'async'
_ = require 'underscore'

parser = require './hassParser.coffee'
sass = require './hassSass.coffee'
jade = require './hassJade.coffee'


publicDir = path.join(__dirname, '..', '')
hassDir = path.join(publicDir, 'demo/hass', 'layout.hass')

sassDir = path.join(publicDir, 'demo/build/sass', 'layout.sass')
jadeDir = path.join(publicDir, 'demo/build/jade', 'layout.jade')

cssDir = path.join(publicDir, 'demo/build/css', 'layout.css')
htmlDir = path.join(publicDir, 'demo/build/html', 'layout.html')

log = (a)->
  console.log a

_existFile = (files)->
  _.each files (val)->
    fs.exists val, (exists)->
      return exists

_deleteFile = (files)->
  _.each files, (val)->
    fs.exists val, (exists)->
      if exists
        fs.unlink val, ()->

_createFilePath = (filePath)->
  if !fs.existsSync(filePath)
    fs.mkdirSync(filePath)
    log 'Common目录创建成功'

_parseFile2Obj = (hass_file)->
  parseredObj = []
  text = fs.readFileSync hass_file, 'utf-8'
  if text
    str = text.split('\n')
    parsedObj = parser.parser(str, hass_file)

_parseObj2Str = (obj)->
  parsedText =
    jade: '',
    sass: ''
  if obj
    _.each obj, (val, index)->
      log val
      switch val.type
        when 'hass'
          if val.text
            jadeText = val.text + '(' + val.$attr + ')' + ' ' + val.$text + '\n'
            parsedText.jade += jadeText
            parsedText.sass += val.text + '\n'
        when 'jade'
          parsedText.jade += val.text + '\n'
        when 'sass'
          parsedText.sass += val.text + '\n'
    parsedText.jade = 'doctype html\n' + parsedText.jade
  parsedText

_parseFile2Str = (hass_file)->
  readedObj = _parseFile2Obj(hass_file)
  if readedObj[0]
    str = _parseObj2Str(readedObj[0])

_writeFile = (file, str, type)->
    arr = iconv.encode(str, 'utf-8')

    # fs.appendFile file, arr+'\n', (err)->
    fs.writeFile file, arr, (err)->
      if err
          log '4.' + type + '写入文件fail' + err
      else
          log '4.' + type + '写入文件ok'

_writeCss = (file, str, type)->
  str = sass.parser(str)
  _writeFile(file, str, 'css');

_writeHtml = (file, str, type)->
  str = jade.parser(str)
  _writeFile(file, str, 'html');

compile = (hass_file, options)->
  options = {
    type: ['jade', 'sass', 'css', 'html'],
    output_file: ['jade']
  }

compile2SassAndJade = (hass_file, sass_file, jade_file) ->
  # _deleteFile([sass_file, jade_file])
  parsedStr = _parseFile2Str(hass_file)
  _writeFile(sass_file, parsedStr.sass, 'sass')
  _writeFile(jade_file, parsedStr.jade, 'jade')

compileCssAndHtml = (hass_file, css_file, html_file) ->
  # _deleteFile([sass_file, jade_file])

  parsedStr = _parseFile2Str(hass_file)
  _writeCss(css_file, parsedStr.sass, 'css')
  _writeHtml(html_file, parsedStr.jade, 'html')

log '1 compile' + hassDir + ' once...'
# compile2SassAndJade(hassDir, sassDir, jadeDir)

compileCssAndHtml(hassDir, cssDir, htmlDir)
# step(
#   compile2SassAndJade(hassDir, sassDir, jadeDir)
#   compileCssAndHtml(hassDir, cssDir, htmlDir)
#   )
# compileJade2Html(jadeDir, htmlDir)



###
console.log 'watching file ...'

fs.watchFile(hassDir, {
        persistent: true,
        interval: 1000
    },
    (curr, prev) ->
        console.log('the file changed, compile ...')
        compile2SassAndJade(hassDir, sassDir, jadeDir)
    );
###