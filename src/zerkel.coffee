parser = require './zerkel-parser'
zlib   = require 'zlib'

module.exports.match = match = (val, pattern) ->
  if val.indexOf('*') >= 0
    x = pattern
    pattern = val
    val = pattern
  if pattern == '*' then return true
  if pattern[0] == '*' and pattern[pattern.length - 1] == '*'
    pattern = pattern[1..-2]
    return (val.indexOf(pattern) >= 0) and val.length > pattern.length + 1
  if pattern[0] == '*'
    pattern = pattern[1..-1]
    return (val.indexOf(pattern) == val.length - pattern.length) and val.length > pattern.length
  if pattern[pattern.length - 1] == '*'
    return (val.indexOf(pattern[0..-2]) == 0) and val.length > pattern.length

module.exports.getIn = getIn = (env, varName) ->
  levels = varName.split(".")
  out = env
  for level in levels
    unless out? and typeof out is 'object'
      out = undefined
      break

    out = out[level]
  return out

module.exports.helpers = helpers = {match: match, getIn: getIn}

module.exports.makePredicate = makePredicate = (body) ->
  if body.substr(0, 3) is "GZ:"
    body = zlib.unzipSync(new Buffer(body.substr(3), 'base64')).toString()
  fn = new Function('_helpers', '_env', "return " + body)
  return (env) -> Boolean fn helpers, env

module.exports.compile = (query) ->
  return makePredicate(parser.parse(query))
