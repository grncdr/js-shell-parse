var test = require('tape')
var parse = require('../parser')

test('nesting backquotes', function (t) {
  var arg = parse('`outer \\`middle \\\\\\`inner\\\\\\`\\``', 'argument')

  var inner = {
    type: "command-substitution",
    commands: [
      {
        type: 'command',
        command: {
          type: 'literal',
          value: 'inner'
        },
        args: [],
        redirects: [],
        env: {},
        control: ';',
        next: null
      }
    ]
  }

  var middle = {
    type: "command-substitution",
    commands: [
      {
        type: 'command',
        command: {
          type: 'literal',
          value: 'middle'
        },
        args: [inner],
        redirects: [],
        env: {},
        control: ';',
        next: null
      }
    ]
  }

  t.deepEqual(arg, {
    type: 'command-substitution',
    commands: [
      {
        type: 'command',
        command: { type: 'literal', value: 'outer' },
        args: [ middle ],
        redirects: [],
        env: {},
        control: ';',
        next: null
      }
    ],
  }, "Can nest backquotes (but you really shouldn't!)")

  t.end()
})
