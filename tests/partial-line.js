var test = require('tape')
var parse = require('../parser')

test('partial input', function (t) {
  // These should all produce syntax errors at the end of the input
  var inputs = [
    "echo '",
    'echo "',
    'echo `start',
    'echo $(',
    'echo ${',
    'if',
    'while',
    'until',
  ];
  t.plan(inputs.length * 2)
  inputs.forEach(function (input) {
    try {
      parse(input)
    } catch (err) {
      t.equal(err.constructor, parse.SyntaxError, 'got a SyntaxError')
      try {
        input = input.slice(err.offset)
        parse(input, 'continuationStart')
        t.pass(input + ' is a continuationStart')
      } catch (err) {
        t.fail(input + ' is not a continuationStart ' + err)
      }
    }
  })
})
