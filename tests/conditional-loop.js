var test = require('tape')
var parse = require('../parser')

test('conditional loop', function (t) {
  var commands = parse('while true; do echo 1; done')
  t.plan(3)

  t.deepEqual(commands[0], {
    type: "while-loop",
    testCommands: [{
      type: "command",
      command: {
        type: "literal",
        value: "true"
      },
      args: [],
      redirects: [],
      env: {},
      control: ";",
      next: null
    }],
    body: [{
      type: "command",
      command: {
        type: "literal",
        value: "echo"
      },
      args: [
        {
        type: "literal",
        value: "1"
      }],
      redirects: [],
      env: {},
      control: ";",
      next: null
    }]
  }, "can parse a while loop")

  try {
    var input = "while echo 1 && do blah; done";
    parse(input)
  } catch (err) {
    t.equal(err.found, "&", 'make sure this is a syntax error')
  }

  var ast = parse('while true && false; do blah; done')
  t.ok(ast[0].testCommands[0].next, "Can use chaining in test-commands")
  t.end()
})
