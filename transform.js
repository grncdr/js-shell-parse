var through = require('through2')
var duplexer = require('duplexer')
var map = require('array-map')
var split = require('split')
var pegParser = require('./peg-parser')

module.exports = createStreamingParser

function createStreamingParser () {
  var input = ""
  var splitter = split()
  var parser = through({objectMode: true},
                       parseLine,
                       errIfUnparsed)
  splitter.pipe(parser)

  var stream = duplexer(splitter, parser)
  return stream

  function parseLine (line, _, cb) {
    input = input + line
    try {
      var commands = pegParser.parse(input)
      stream.emit('input', input)
      input = ""
      this.push(commands)
    } catch (err) {
      if (err.offset == input.length) {
        stream.emit('continue')
      }
      else if (err instanceof pegParser.SyntaxError) {
        stream.emit('parse-error', err, input)
        input = ""
      }
      else return cb(err)
    }
    cb()
  }

  function errIfUnparsed (cb) {
    cb(input ? new Error("Unparsed input: " + input) : null)
  }
}
