var test = require('tape')
var parse = require('../parser')

test('Multiple commands', function (t) {
  var input = [
    'echo ok',
    'other-command --arg 3',
  ]

  var expected = [
    { type: 'command',
      command: { type: 'literal', value: 'echo' },
      args: [
        { type: 'literal', value: 'ok' }
      ],
      redirects: [],
      control: ';',
      env: {}
    },
    { type: 'command',
      command: { type: 'literal', value: 'other-command' },
      args: [
        { type: 'literal', value: '--arg' },
        { type: 'literal', value: '3' }
      ],
      redirects: [],
      control: ';',
      env: {}
    }
  ]
  t.deepEqual(parse(input.join('\n')), expected, "new-line separated commands")
  t.deepEqual(parse(input.join(';')), expected, "semicolon separated commands")
  t.end()
})
