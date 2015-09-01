_ = require 'underscore'
_.str = require 'underscore.string'

log = (a)->
  console.log a

parser = (code, filename, style)->
  style = style || 'indent'
  state =
    type: 'hass', # 解析成文本的类型: jade sass hass(both jade and sass)
    row: 0, # 第几行
    col: 0, # 前面有几个(空格)
    # level: 1, # 嵌套
    text: '', # 一行的文本(解析后的)
    $text: '',
    $attr: '',
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
indentParser = (code, filename)->
  exports.parser(code, filename, 'indent')

# 大括号解析
braceParser = (code, filename)->
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
  reverserArr = arr
  i = 0
  while i < reverserArr.length / 2
    temp = reverserArr[i]
    reverserArr[i] = reverserArr[reverserArr.length - i - 1]
    reverserArr[reverserArr.length - i - 1] = temp
    i++
  reverserArr

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
  sta.$text = state.$text
  sta.$attr = state.$attr
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
    # col 大小
    spaceNum = _preSpaceCount(char)
    # 截取文本
    text = char.slice(textStr.length + 1)
    # 反转数据 插入 xs
    xsReverse = _reverse(xs)

    fatherState = _.find xsReverse, (val)->
      return spaceNum > val.col
    fatherIndex = _.indexOf(xsReverse, fatherState)

    xsText = xsReverse[fatherIndex].text

    switch _.str.clean(textStr)
      when '&text'
        # jade 写入 father
        # xsReverse[fatherIndex].text = xsText + ' ' + text
        xsReverse[fatherIndex].$text = text
        [_reverse(xsReverse), state, code[1..], style, text]

      when '&attr'
        # jade 写入 father
        # strObj = _.str.clean(xsText).split(' ')
        # strObj[0] = xsText.split(strObj[0])[0] + strObj[0] + '('+text+')'
        # xsReverse[fatherIndex].text = _.reduce strObj, (memo, num)->
        #   return memo + ' ' + num
        xsReverse[fatherIndex].$attr = text
        [_reverse(xsReverse), state, code[1..], style, text]

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

module.exports =
  parser: parser,
  indentParser: indentParser,
  braceParser: braceParser
