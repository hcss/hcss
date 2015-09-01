#!/usr/local/bin/node

$ = require './hassTool.coffee'

exec = require 'child_process'
path = require 'path'
async = require 'async'
_ = require 'underscore'

parser = require './hassParser.coffee'
sass = require './hassSass.coffee'
jade = require './hassJade.coffee'

_parseFile2Obj = (hass_file)->
  parseredObj = []
  text = $.readFile hass_file
  if text
    str = text.split('\n')
    parsedObj = parser.parser(str, hass_file)

_parseObj2Str = (obj)->
  parsedText =
    jade: '',
    sass: ''
  if obj
    _.each obj, (val, index)->
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

_writeCss = (file, str, type)->
  str = sass.parser(str)
  $.writeFile(file, str, 'css')

_writeHtml = (file, str, type)->
  str = jade.parser(str)
  $.writeFile(file, str, 'html')

compile = (options, callback)->
  options = {
    style: 'indent',
    input: 'input.js',
    output: 'path/to/bin'
  }
  # 依据文件后缀 选择 编译方法
  style = 'indent'
  switch style
    when 'hass'
      options.style = 'indent'
    when 'hcss'
      options.style = 'brace'
  #




render2SassAndJade = (hass_file, sass_file, jade_file) ->
  # _deleteFile([sass_file, jade_file])
  parsedStr = _parseFile2Str(hass_file)
  $.writeFile(sass_file, parsedStr.sass, 'sass')
  $.writeFile(jade_file, parsedStr.jade, 'jade')

render2CssAndHtml = (hass_file, css_file, html_file) ->
  # _deleteFile([sass_file, jade_file])
  parsedStr = _parseFile2Str(hass_file)
  _writeCss(css_file, parsedStr.sass, 'css')
  _writeHtml(html_file, parsedStr.jade, 'html')

module.exports =
  render2SassAndJade: render2SassAndJade,
  render2CssAndHtml: render2CssAndHtml
