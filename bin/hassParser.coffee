_ = require 'underscore'
_.str = require 'underscore.string'

hassTools = require './hassTools.coffee'
log = (a)->
  console.log a
xs = []
exports.parser = (code, filename, style)->
  style = style || 'indent'
  state =
    type: 'hass', # 解析成文本的类型: jade sass hass(both jade and sass)
    row: 0, # 第几行
    col: 0, # 前面有几个(空格)
    # level: 1, # 嵌套
    text: '', # 一行的文本(解析后的)
    path: filename # 读取的文件
  xs = []
  ###
  xs 储存解析后的 数组[]
  state 每行解析的结果
  code 传入的解析数据
  style 书写方式 缩进 或者 大括号
  ###
  while code.length > 0
    [xs, state, code, style] = parse(xs, state, code, style)
  [xs, state, code, style]
# 缩进解析
exports.indentParser = (code, filename)->
  exports.parser(code, filename, 'indent')

# 大括号解析
exports.braceParser = (code, filename)->
  exports.parser(code, filename, 'brace')

# 判断解析的语法类型
isHassType = (char)->
  # 如果不存在 [&!:]
  reg = /[&!:]/g
  !reg.test(char)

isJadeType = (char)->
  # 如果该行开头有 &
  str = _.str.trim(char)
  return _.str(str).startsWith('&')

isSassType = (char)->
  # 如果开头有 [!]
  # 如果该行有 [:]， 注：['"] 情况已经被 上一层解析
  str = _.str.trim(char)
  return _.str(str).startsWith('!') || _.str.include(str, ':')

_reverse = (arr) ->
  i = 0
  while i < arr.length / 2
    temp = arr[i]
    arr[i] = arr[arr.length - i - 1]
    arr[arr.length - i - 1] = temp
    i++
  arr

# 解析行前空格（还没有考虑 Tab ）
_preSpaceCount = (str)->
  col = 0
  strObj = str.split(' ')
  for val in strObj
    if val is ''
      col += 1
      continue
    else
      break
  col

# 解析完
_indentEnd = (xs, state, code, style)->
  log "End in indent parse ..."

_braceEnd = (xs, state, code, style)->
  log "End in brace parse ..."

# 跳过不能解析的行
_elseParser = (xs, state, code, style)->
  [xs, state, code[1..], style]

# 解析一行 为 state 并写入 xs
_appendState = (xs, state, code, style, str)->
  sta = {}
  sta.type = state.type
  sta.row = state.row += 1
  sta.text = str
  sta.col = _preSpaceCount(str)
  sta.path = state.path
  if xs.push sta
    [xs, state, code[1..], style]

_appendHass = (xs, state, code, style)->
  state.type = 'hass'
  char = code[0]
  _appendState(xs, state, code, style, char)

_appendSass = (xs, state, code, style)->
  state.type = 'sass'
  char = code[0]
  if _.str(char).startsWith('!')
    char = char.replace('!', '')
  _appendState(xs, state, code, style, char)

_appendJade = (xs, state, code, style)->
  state.type = 'jade'
  char = code[0]
  # 兼容 &text : 嘎嘎:
  str = _.str.clean(char).split(' ')[0]
  if _.str.include(char, ':')
    # bug: text 和 attr 依旧在 xs 中，先用 state.type 忽略
    state.type = 'text&attr'

    textStr = char.split(':')[0]

    switch _.str.clean(textStr)
      when '&text'
        # col 大小
        spaceNum = _preSpaceCount(char)
        # 截取文本
        text = char.slice('textStr'.length + 1)
        log text
        # _.each xs.reverse(), (val, key)->
        #   # 添加到父类
        #   if spaceNum > val.col
        #     xsText = xs[key].text
        #     xs[key].text = xsText + ' ' + text
        [xs.reverse(), state, code[1..], style]
      when '&attr'
        spaceNum = _preSpaceCount(char)
        text = char.slice('textStr'.length + 1)
        log text
        # _.each xs.reverse(), (val, key)->
        #   if spaceNum > val.col
        #     xsText = xs[key].text
        #     strObj = _.str.clean(xsText).split(' ')
        #     strObj[0] += '('+text+')'
        #     xs[key].text = _.reduce strObj, (memo, num)->
        #       return memo + ' ' + num
        _appendState(xs, state, code, style, text)

  else switch str
    when '&extends' then char = char.replace('&', '')
    when '&block' then  char = char.replace('&', '')
    when '&include' then  char = char.replace('&', '')

    else  throw error
  _appendState(xs, state, code, style, char)



_indentParser = (xs, state, code, style)->
  style = 'indent'

  char = code[0]
  args = [xs, state, code, style]
  if isHassType(char)
    _appendHass args...
  else if isJadeType(char)
    _appendJade args...
  else if isSassType(char)
    _appendSass args...
  else
    _elseParser args...
  # [xs, state, code[1..], style]

_braceParser = (xs, state, code, style)->
  style = 'brace'

  [xs, state, code[1..], style]


# 解析流程
parse = (xs, state, code, style)->
  args = [xs, state, code, style]
  end = code.length is 0

  switch style
    when 'indent'
      if end then _indentEnd args...
      else
        _indentParser args...
    when 'brace'
      if end then _braceEnd args...
      else
        _braceParser args...
      return

###
如果是attr
查找前对象 type 为非sass col 小余 本行的第一个对象，在找到的前对象的文本后空格或者结束符前面加入（attr后面的内容，并给等号后面,逗号前面和行尾加引号），并且此行不生成的对象。

如果是text
查找前对象 type为非sass col 小余 本行的第一个对象，在找到的前对象的文本后面加入（text后面的内容）,并且保持插入内容前有空格，并且此行不生成的对象。

foreach 对象，写入sass和jade文件
###
