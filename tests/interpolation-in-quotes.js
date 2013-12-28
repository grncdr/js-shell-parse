var test = require('tape')
var parse = require('../parser')

test('interpolation in quotes', function (t) {

  var arg = parse('"interpolated $variable"', 'argument')
  t.deepEqual(arg, {
    type: 'concatenation',
    pieces: [
      { type: "literal", value: "interpolated " },
      { type: "variable", name: "variable" }
    ]
  }, "Can interpolate environment variables")

  var arg = parse('"interpolated ${variable/sub/rep}"', 'argument')
  t.deepEqual(arg, {
    type: 'concatenation',
    pieces: [
      { type: "literal", value: "interpolated " },
      { type: "variable-substitution", expression: "variable/sub/rep" }
    ]
  }, "Can interpolate variables substitutions")

  var arg = parse('"interpolated `backtick command`"', 'argument')
  t.deepEqual(arg, {
    type: 'concatenation',
    pieces: [
      { type: "literal", value:"interpolated " },
      { type: "backticks",
        commands: [
          { type: 'command',
            command: { type: 'literal', value: 'backtick' },
            args: [
              {type: 'literal', value: 'command'}
            ],
            redirects: [],
            env: {},
            control: ';' }
        ]
      }]
    }, "Can interpolate back-ticks (but you really shouldn't!)")


  var arg = parse('"interpolated $(command1; command2)"', 'argument')
  t.deepEqual(arg, {
    type: 'concatenation',
    pieces: [
      { type: "literal", value:"interpolated " },
      { type: "subshell",
        commands: [
          { type: 'command',
            command: { type: 'literal', value: 'command1' },
            args: [],
            redirects: [],
            env: {},
            control: ';' },
          { type: 'command',
            command: { type: 'literal', value: 'command2' },
            args: [],
            redirects: [],
            env: {},
            control: ';' }
        ]
      }]
    }, "Can interpolate subshells (better idea!)")

  t.end()
})
