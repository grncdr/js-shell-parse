var test = require('tape')
var parse = require('../parser')

test('variable substitutions', function (t) {
  var expect = [
    {
      type: 'command',
      command: { type: 'literal', value: 'echo' },
      args: [
        { type: 'literal', value: 'ok' }
      ],
      redirects: [],
      env: {},
      control: '&&'
    },
    {
      type: 'command',
      command: { type: 'literal', value: 'echo' },
      args: [
        { type: 'literal', value: 'ok2' }
      ],
      redirects: [],
      env: {},
      control: ';'
    },
  ];

  ['&&', '||', '&', ';'].forEach(function (operator) {
    var ast = parse('echo ok ' + operator + ' echo ok2')
    expect[0].control = operator
    t.deepEqual(ast, expect, 'can chain commands with ' + operator)
  })

  t.end()
})

