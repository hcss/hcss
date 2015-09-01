fs = require 'fs'
sass = require 'node-sass'
assign = require 'object-assign'

log = (a)->
  console.log a


parser = (str)->

  options = {
    errLogToConsole: true,
    outputStyle: 'nested', #compressed
    indentedSyntax: true
  }
  opts = assign({}, options)
  opts.data = str

  result = sass.renderSync(opts)
  result.css

module.exports =
  parser: parser
