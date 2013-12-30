var test = require('tape')
var xtend = require('xtend')
var parse = require('../parser')
var difflet = require('difflet')({indent: 2})

test('if statements', function (t) {
  var input = 'if true; then echo 1; fi'
  var statement = parse(input)[0]
  var expected = {
    type: "if-else",
    test: [{
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
    }],
    elifBlocks: null,
    elseBody: null,
    next: null,
    control: ';'
  }
  t.deepEqual(parse(input)[0], expected, input)

  input = 'if true; then echo 1; else echo 2; fi'
  expected = clone(expected)
  expected.elseBody = [
    { type: 'command',
      command: { type: 'literal', value: 'echo' },
      args: [ {type: 'literal', value: '2'} ],
      redirects: [],
      env: {},
      control: ';',
      next: null }
  ]

  t.deepEqual(parse(input)[0], expected, input)

  input = 'if true; then echo 1; elif false; then echo 3; else echo 2; fi'
  expected = clone(expected)
  expected.elifBlocks = [
    {
      type: 'if-else',
      test: [{
        type: "command",
        command: {
          type: "literal",
          value: "false"
        },
        args: [],
        redirects: [],
        env: {},
        control: ";",
        next: null
      }],
      body: [{
        type: 'command',
        command: { type: 'literal', value: 'echo' },
        args: [ {type: 'literal', value: '3'} ],
        redirects: [],
        env: {},
        control: ';',
        next: null
      }]
    }
  ]

  t.deepEqual(parse(input)[0], expected, input)
  t.end()
})

function clone (obj) {
  // yep
  return JSON.parse(JSON.stringify(obj))
}
