var test = require('tape')
var _parse = require('../parser')
var parse = function (input) {
  return _parse(input, 'commandList')
}

test('command sequencing', function (t) {
  var expect = [
    {
      type: 'command',
      command: { type: 'literal', value: 'echo' },
      args: [
        { type: 'literal', value: 'ok' }
      ],
      redirects: [],
      env: {},
      control: ';',
      next: null
    },
    {
      type: 'command',
      command: { type: 'literal', value: 'echo' },
      args: [
        { type: 'literal', value: 'ok2' }
      ],
      redirects: [],
      env: {},
      control: ';',
      next: null
    },
  ];

  t.deepEqual(parse('echo ok\necho ok2\n'), expect,
              'can separate commands with "\\n"')

  t.deepEqual(parse('echo ok;echo ok2;'), expect,
              'can separate commands with ";"')

  expect[0].control = '&'
  t.deepEqual(parse('echo ok & echo ok2;'), expect,
              'can separate commands with "&"')

  t.end()
})

test('command chaining', function (t) {
  var expect = [
    {
      type: 'command',
      command: { type: 'literal', value: 'echo' },
      args: [
        { type: 'literal', value: 'ok' }
      ],
      redirects: [],
      env: {},
      control: '&&',
      next: {
        type: 'command',
        command: { type: 'literal', value: 'echo' },
        args: [
          { type: 'literal', value: 'ok2' }
        ],
        redirects: [],
        env: {},
        control: ';',
        next: null
      }
    }
  ];

  ['&&', '||'].forEach(function (operator) {
    expect[0].control = operator
    var ast = parse('echo ok ' + operator + ' echo ok2\n')
    t.deepEqual(ast, expect, 'can chain commands with ' + operator)
  })

  t.end()
})

