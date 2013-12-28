var test = require('tape')
var parse = require('../parser')

test('redirecting stdio', function (t) {
  var cmd = parse('transform < fromfile > tofile', 'command')

  t.deepEqual(cmd, {
    type: 'command',
    command: { type: 'literal', value: 'transform' },
    args: [],
    redirects: [
      { type: 'redirect-fd',
        fd: 0,
        op: '<',
        filename: { type: 'literal', value: 'fromfile' } },
      { type: 'redirect-fd',
        fd: 1,
        op: '>',
        filename: { type: 'literal', value: 'tofile' } }
    ],
    env: {},
    control: ';'
  }, "can redirect stdin and stdout in same command")

  t.deepEqual(parse('cmd 6> /dev/null', 'command'), {
    type: 'command',
    command: { type: 'literal', value: 'cmd' },
    args: [],
    redirects: [
      { type: 'redirect-fd',
        fd: 6,
        op: '>',
        filename: { type: 'literal', value: '/dev/null' } }
    ],
    env: {},
    control: ';'
  }, "can redirect arbitrary fd's")

  t.deepEqual(parse("> /dev/null cmd", 'command'), {
    type: 'command',
    command: { type: 'literal', value: 'cmd' },
    args: [],
    redirects: [
      { type: 'redirect-fd',
        fd: 1,
        op: '>',
        filename: { type: 'literal', value: '/dev/null' } }
    ],
    env: {},
    control: ';'
  }, 'Can start commands with redirects')


  t.deepEqual(parse('cmd 2>&1 >/dev/null', 'command'), {
    type: 'command',
    command: { type: 'literal', value: 'cmd' },
    args: [],
    redirects: [
      { type: 'duplicate-fd',
        fd: 2,
        op: '>&',
        filename: { type: 'literal', value: '1' } },
      { type: 'redirect-fd',
        fd: 1,
        op: '>',
        filename: { type: 'literal', value: '/dev/null' } }
    ],
    env: {},
    control: ';'
  })
  t.end()
})
