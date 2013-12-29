var test = require('tape')
var parse = require('../parser')

test('big example', function (t) {
  var input = [
    "blah >(substitute-command --with args)",
    "first | second",
    "echo ${what/hot/not} ok 'single-quoted arg'\"double-quoted $var\" > here",
  ].join('\n')

  var commands = parse(input)
  t.pass('parsed')
  t.end()
})
