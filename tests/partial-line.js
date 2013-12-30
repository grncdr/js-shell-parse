var test = require('tape')
var parse = require('../parser')

test('partial input', function (t) {
  // These should all produce syntax errors at the end of the input
  var inputs = [
    "echo 'start ",
    'echo "start ',
    'echo `start ',
    'echo $(start ',
    'echo ${start ',
    'if',
    'while',
    'until',
  ];
  t.plan(inputs.length)
  inputs.forEach(function (input) {
    try {
      parse(input)
    } catch (err) {
      t.equal(err.offset, input.length, err)
    }
  })
})
