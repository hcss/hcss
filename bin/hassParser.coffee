hassTools = require './hassTools.coffee'

log = (a)->
  console.log a

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
    log xs
    [xs, state, code, style] = parse(xs, state, code, style)
  res = parse(xs, state, code, style)
  res

# 缩进解析
exports.indentParser = (code, filename)->
  exports.parser(code, filename, 'indent')

# 大括号解析
exports.braceParser = (code, filename)->
  exports.parser(code, filename, 'brace')

# 解析匹配的正则
regexs =
  stepOne: /[&!:]/g
  stepTwo: /^!/
  stepThree: //
  stepFour: //

# 解析完
_indentEnd = (xs, state, code, style)->
  log "End in indent parse ..."

_braceEnd = (xs, state, code, style)->
  log "End in brace parse ..."

# 跳过不能解析的行
_elseParser = (xs, state, code, style)->
  [xs, state, code[1..], style]

_indentParser = (xs, state, code, style)->

  [xs, state, code[1..], style]

_braceParser = (xs, state, code, style)->
  style = 'brace'

  [xs, state, code[1..], style]

# 解析一行 为 state 并写入 xs
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
  # a = hassTools.appendItem(xs, state)

  # bug 有问题 xs 插入的数据，不是期望的效果
  if xs.push state
  # log xs
    [xs, state, code[1..], style]

# 解析流程
parse = (xs, state, code, style)->
  args = [xs, state, code, style]
  end = code.length is 0
  char = code[0]

  switch style
    when 'indent'
      if end then _indentEnd args...
      # 如果不存在 [&!:]
      else if !regexs.stepOne.test(char)
        # type=hass
        _appendHass args...
      # 如果开头有 [!] 
      # 如果该行没有 ['"] 有 [:]
      else if regexs.stepTwo.test(char)
        _appendSass args...
      # 如果该行开头有 &
      else if regexs.stepThree.test(char)
        switch str:
          case '&extends':
            break
          case '&block':
            break
          case '&include':
            break
          case '&text':
            break
          case '&attr':
            break
      #    如果是 extends block include text attr 
      else
        _elseParser args...
    when 'brace'
      if end then _braceEnd args...
      else
        _braceParser args...
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
