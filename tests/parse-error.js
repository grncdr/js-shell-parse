var test = require('tape')
var parse = require('../parser')

test('partial input', function (t) {
  // These should all produce syntax errors at the end of the input
  var examples = [
    { input: "echo ( this will fail", position: 5 }
  ]

  examples.forEach(function (example) {
    try {
      parse(example.input)
    } catch (err) {
      t.equal(err.constructor, parse.SyntaxError, 'got a SyntaxError');
      t.equal(example.position, err.offset);
    }
  })

  t.end()
})
