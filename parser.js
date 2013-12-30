var pegParser = require('./peg-parser')
var transform = require('./transform')

module.exports = parse

function parse (input, opts) {
  if (typeof opts == 'string') {
    opts = { startRule: opts }
  }
  else if (!opts) {
    opts = {}
  }
  return pegParser.parse(input, opts)
}

parse.SyntaxError = pegParser.SyntaxError
exports.createStreamingParser = require('./transform')
exports.parse = pegParser.parse
