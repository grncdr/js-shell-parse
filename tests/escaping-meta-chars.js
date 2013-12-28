var test = require('tape')
var parse = require('../parser')

test('escaping meta characters in barewords', function (t) {
  var ast = parse('echo I\\ am\\ one\\ arg')[0]
  t.deepEqual(ast.args, [{
    type: 'literal',
    value: 'I am one arg'
  }], "Can escape spaces")

  var ast = parse('echo \\$dollar_dollar_bill')[0]
  t.deepEqual(ast.args, [{
    type: 'literal',
    value: '$dollar_dollar_bill'
  }], "Can escape $")

  var ast = parse('echo \\>\\ no\\ redirect')[0]
  t.deepEqual(ast.args, [{
    type: 'literal',
    value: '> no redirect'
  }], "Can escape >")

  var ast = parse('echo dollar_\\$dollar_bill')[0]
  t.deepEqual(ast.args, [{
    type: 'literal',
    value: 'dollar_$dollar_bill'
  }], "Can escape mid-word")

  t.end()
})
