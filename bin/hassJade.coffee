jade = require 'jade'

log = (a)->
  console.log a

parser = (str, locals)->
  locals = {}
  options = {
    pretty: true
  }
  fn = jade.compile(str, options);
  html = fn(locals);

module.exports =
  parser: parser
