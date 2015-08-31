#!/usr/local/bin/node

exec = require 'child_process'
path = require 'path'
fs = require 'fs'
iconv = require 'iconv-lite'

_ = require 'underscore'

parser = require './hassParser.coffee'

publicDir = path.join(__dirname, '..', '')
hassDir = path.join(publicDir, 'demo/hass', 'layout.hass')
sassDir = path.join(publicDir, 'demo/sass', 'layout.sass')
jadeDir = path.join(publicDir, 'demo/jade', 'layout.jade')


log = (a)->
  console.log a

_deleteFile = (files)->
  _.each files, (val)->
    fs.exists val, (exists)->
      if exists
        fs.unlink val, ()->

_readFile = (hass_file, sass_file, jade_file)->
  readedObj = []
  _deleteFile([sass_file, jade_file])
  fs.readFile hass_file, (err, data)->
    if err
      log '2 读取文件fail' + err
    else
      str = iconv.decode(data, 'utf-8')
      str = str.split('\n')
      readedObj = parser.parser(str, hass_file)[0]

      parseredText = {
        jade: '',
        sass: ''
      }
      _.each readedObj, (val, index)->
        switch val.type
          when 'hass'
            parseredText.jade += val.text + '\n'
            parseredText.sass += val.text + '\n'
          when 'jade'
            parseredText.jade += val.text + '\n'
          when 'sass'
            parseredText.sass += val.text + '\n'
      parseredText.jade = 'doctype html\n' + parseredText.jade
      _writeFile(sass_file, parseredText.sass, 'sass')
      _writeFile(jade_file, parseredText.jade, 'jade')

_writeFile = (file, str, type)->
    arr = iconv.encode(str, 'utf-8')

    fs.appendFile file, arr+'\n', (err)->
    # fs.writeFile file, arr, (err)->
      if err
          log '4.' + type + '写入文件fail' + err
      else
          log '4.' + type + '写入文件ok'


compile2SassAndJade = (hass_file, sass_file, jade_file) ->
  _readFile(hass_file, sass_file, jade_file)

log '1 compile' + hassDir + ' once...'
compile2SassAndJade(hassDir, sassDir, jadeDir)



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