var test = require('tape')
var parse = require('../build')

test('escaping in quotes', function (t) {
  var ast = parse('echo "An escaped double-quote: \\""')
  t.deepEqual(ast[0].args, [{
    type:"literal",
    value:"An escaped double-quote: \""
  }], "Can escape double-quotes inside double-quotes")

  var ast = parse('echo "An escaped \\$dollar sign"')
  t.deepEqual(ast[0].args, [{
    type:"literal",
    value:"An escaped $dollar sign"
  }], "Can escape dollar signs")

  t.end()
})
