var test = require('tape')
var parse = require('../parser')

test('partial input', function (t) {
  // These should all produce syntax errors at the given position
  var examples = [
    { input: "echo ( this will fail", position: 5 }
  ]

  examples.forEach(function (example) {
    t.test('SyntaxError test "' + example.input + '"', function (t) {
      try {
        parse(example.input)
        t.fail("did not throw expected SyntaxError")
      } catch (err) {
      
        t.equal(err.constructor, parse.SyntaxError, 'threw expected SyntaxError')
        t.equal(example.position, err.offset, 'SyntaxError has expected offset')
        try {
          parse(example.input.substr(err.offset), 'continuationStart')
          t.fail('was successfully parsed as a continuationStart')
        } catch (e) {
          t.pass('could not parse continuationStart')
        }
      }
    })
  })

  t.end()
})
