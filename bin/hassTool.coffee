fs = require 'fs'
iconv = require 'iconv-lite'

tools =
log = (a)->
  console.log a

existFile = (files)->
  _.each files (val)->
    fs.exists val, (exists)->
      return exists

deleteFile = (files)->
  _.each files, (val)->
    fs.exists val, (exists)->
      if exists
        fs.unlink val, ()->

createFilePath = (file)->
  log __dirname
  if !fs.existsSync(file)
    fs.mkdir file, '0777', (err)->
      if err
        log err
      else
        log 'Common目录创建成功'
# 异步文件夹创建 递归方法
mkdir_auto_next = (mode, pathlist, pathlistlength, callback, pathlistlengthseed, pathtmp) ->
  callback = callback or ->

  if pathlistlength > 0
    pathlistlengthseed = 0  unless pathlistlengthseed
    if pathlistlengthseed >= pathlistlength
      callback true
    else
      if pathtmp
        pathtmp = path.join(pathtmp, pathlist[pathlistlengthseed])
      else
        pathtmp = pathlist[pathlistlengthseed]
      fs.exists pathtmp, (exists) ->
        unless exists
          fs.mkdir pathtmp, mode, (isok) ->
            unless isok
              mkdir_auto_next mode, pathlist, pathlistlength, ((callresult) ->
                callback callresult
              ), pathlistlengthseed + 1, pathtmp
            else
              callback false

        else
          mkdir_auto_next mode, pathlist, pathlistlength, ((callresult) ->
            callback callresult
          ), pathlistlengthseed + 1, pathtmp

  else
    callback true

mkdirs = (dirpath, mode, callback) ->
  callback = callback or ->

  fs.exists dirpath, (exitsmain) ->
    unless exitsmain

      #目录不存在
      pathtmp = undefined
      pathlist = dirpath.split(path.sep)
      pathlistlength = pathlist.length
      pathlistlengthseed = 0
      mkdir_auto_next mode, pathlist, pathlist.length, (callresult) ->
        if callresult
          callback true
        else
          callback false

    else
      callback true

readFile = (file)->
  fs.readFileSync file, 'utf-8'

writeFile = (file, str, type)->
  ###
  书写文件有问题

  ###
  mkdirs file, (err)->
    $.log err
  arr = iconv.encode(str, 'utf-8')
  # fs.appendFile file, arr+'\n', (err)->
  fs.writeFile file, arr, (err)->
    if err
        log '4.' + type + '写入文件 fail ' + err
    else
        log '4.' + type + '写入文件 ok '

module.exports =
  log: log,
  existFile: existFile,
  deleteFile: deleteFile,
  createFilePath: createFilePath,
  readFile: readFile,
  writeFile: writeFile

