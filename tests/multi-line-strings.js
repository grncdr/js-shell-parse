var test = require('tape')
var parse = require('../parser')

test('Multi-line strings', function (t) {
  var input = [
    'echo "This',
    'is a',
    'multiline',
    'string"'
  ].join('\n')

  var ast = parse(input)
  t.deepEqual(ast[0].args[0], {
    type: 'literal',
    value: 'This\nis a\nmultiline\nstring'
  }, 'multi-line string literals are one arg')
  t.end()
})
