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
  if !fs.existsSync(file)
    fs.mkdirSync(file)
    log 'Common目录创建成功'

readFile = (file)->
  fs.readFileSync file, 'utf-8'

writeFile = (file, str, type)->
    arr = iconv.encode(str, 'utf-8')
    # fs.appendFile file, arr+'\n', (err)->
    fs.writeFile file, arr, (err)->
      if err
          log '4.' + type + '写入文件fail' + err
      else
          log '4.' + type + '写入文件ok'

module.exports =
  log: log,
  existFile: existFile,
  deleteFile: deleteFile,
  createFilePath: createFilePath,
  readFile: readFile,
  writeFile: writeFile

