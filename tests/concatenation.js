var test = require('tape')
var parse = require('../parser')

test('concatenation', function (t) {
  var ast = parse('echo "two "\' strings\'')
  t.deepEqual(ast[0].args, [
    { type: 'literal', value: 'two  strings' }
  ], 'concatenated literals are flattened') 

  var ast = parse('echo $var"and a string"')
  t.deepEqual(ast[0].args, [
    { type: 'concatenation',
      pieces: [
        { type: 'variable',
          name: 'var' },
        { type: 'literal',
          value: 'and a string' }
      ]
    }
  ], 'can concatenate $var and strings') 

  var ast = parse('echo "it\'s easy to switch "\'"back"\'" and "\'"forth"\'')
  t.deepEqual(ast[0].args, [
    { type: 'literal',
      value: 'it\'s easy to switch "back" and "forth"' }
  ], 'can concatenate alternating quote contexts') 

  t.end()
})
