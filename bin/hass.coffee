#!/usr/local/bin/node

exec = require 'child_process'
path = require 'path'
fs = require 'fs'
iconv = require 'iconv-lite'
{parse, pare} = require 'cirru-parser'

publicDir = path.join(__dirname, '..', '')
hassDir = path.join(publicDir, 'demo/hass', 'layout.hass')
sassDir = path.join(publicDir, 'demo/sass', 'header.sass')
jadeDir = path.join(publicDir, 'demo/jade', 'header.jade')

log = (a)->
  console.log a

readFile = (hass_file, sass_file, jade_file)->
  fs.readFile hass_file, (err, data)->
    if err
      log '2 读取文件fail' + err
    else
      str = iconv.decode(data, 'utf-8')

      # 解析文本
      syntaxTree = parse str, hass_file
      simplifiedTree = pare str, hass_file

    log str = JSON.stringify(syntaxTree)
    log syntax = JSON.parse(str)
      # writeFile(sass_file, str)


writeFile = (file, str)->
    arr = iconv.encode(str, 'utf-8');
    console.log('3' + arr)

    fs.appendFile file, arr, (err)->
      if err
          log '4 写入文件fail' + err
      else
          log '4 写入文件ok'


compile2SassAndJade = (hass_file, sass_file, jade_file) ->
  readFile(hass_file, sass_file, jade_file)

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