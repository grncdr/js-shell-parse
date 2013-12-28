var test = require('tape')
var parse = require('../parser')

test('interpolating in quotes', function (t) {

  var ast = parse('echo "interpolated `backtick command`"')
  t.deepEqual(ast[0].args, [{
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
    }], "Can interpolate back-ticks (but you really shouldn't!)")


  var ast = parse('echo "interpolated $(command1; command2)"')
  t.deepEqual(ast[0].args, [{
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
    }], "Can interpolate subshells (better idea!)")
  t.end()
})
