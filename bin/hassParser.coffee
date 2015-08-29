hassTools = require './hassTools.coffee'

log = (a)->
  console.log a

exports.parser = (code, filename, style)->
  style = style || 'indent'
  state =
    type: 'hass', # 文本类型: jade sass both
    row: 1, # 第几行
    col: 1, # 第几列
    # level: 1, # 嵌套
    text: '', # 一行的文本(解析后的)
    path: filename # 读取的文件
  xs = []
  while code.length > 0
    [xs, state, code, style] = parse(xs, state, code, style)
  res = parse(xs, state, code, style)


exports.indentParser = (code, filename)->
  exports.parser(code, filename, 'indent')

exports.braceParser = (code, filename)->
  exports.parser(code, filename, 'brace')

regexs =
  stepOne: /[&!:]/g

_indentEnd = (xs, state, code, style)->
  log "End in indent parse ..."

_braceEnd = (xs, state, code, style)->
  log "End in brace parse ..."

_appendHass = (xs, state, code, style)->
  state.type = 'hacc'
  state.row += 1
  state.text = code[0]

  str = code[0].split(' ')
  for val in str
    if val is ''
      state.col += 1
      continue
    else
      break
  # hassTools.appendItem(xs, state)
  log xs
  xs.push state

  [xs, state, code[1..], style]

_indentParser = (xs, state, code, style)->

  [xs, state, code[1..], style]

_braceParser = (xs, state, code, style)->
  style = 'brace'

  [xs, state, code[1..], style]

parse = (xs, state, code, style)->
  args = [xs, state, code, style]
  end = code.length is 0
  char = code[0]

  switch style
    when 'indent'
      if end then _indentEnd args...
      # 如果不存在 [&!:]
      else if !regexs.stepOne.test(char)
        console.log code.length
        # type=hass
        _appendHass args...
      else _indentParser args...
    when 'brace'
      if end then _braceEnd args...
      else _braceParser args...
      return

###
如果没有「&」「!」和「:」，存入 jade 和 sass json对象；

`[^\&\!\:]`
type写入类型 html css hcss
row行，col列一空格即一列
[{
  type: hcss,
   row:  1,
   col: 1,
   text: ".div",//顺便把空格加上
},
如果开头有!， 去掉!，写入sass;
{
  type: css,
   row:  2,
   col: 1,
   text: "div",//顺便把空格加上
}
如果该行没有引号（"或'）有:，写入sass;
{
type: css,
   row:  3,
   col: 3,
   text: "font:24px",//顺便把空格加上
}
如果有&，判断&后面是extends, block, include, text, attr

如果是&extends, 去掉&，找到对应的文件，写入jade;
如果是&block, 去掉&,写入jade;
如果是&include 去掉&,找到对应文件，写入jade;
{type: html,
   row:  1,
   col: 1,
   text: "extends ",//顺便把空格加上}

如果是attr
查找前对象 type 为非sass col 小余 本行的第一个对象，在找到的前对象的文本后空格或者结束符前面加入（attr后面的内容，并给等号后面,逗号前面和行尾加引号），并且此行不生成的对象。

如果是text
查找前对象 type为非sass col 小余 本行的第一个对象，在找到的前对象的文本后面加入（text后面的内容）,并且保持插入内容前有空格，并且此行不生成的对象。

foreach 对象，写入sass和jade文件
###
