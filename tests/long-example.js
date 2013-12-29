var test = require('tape')
var parse = require('../parser')

test('long example', function (t) {
  var input = [
    "blah >(substitute-command --with args)",
    "first | second",
    "echo ${what/hot/not} ok 'single-quoted arg'\"double-quoted $var\" > here",
  ].join('\n')

  t.deepEqual(parse(input), [
    {
    "type": "command",
    "command": {
      "type": "literal",
      "value": "blah"
    },
    "args": [
      {
      "type": "command-substitution",
      "readWrite": ">",
      "commands": [
        {
        "type": "command",
        "command": {
          "type": "literal",
          "value": "substitute-command"
        },
        "args": [
          {
          "type": "literal",
          "value": "--with"
        },
        {
          "type": "literal",
          "value": "args"
        }
        ],
        "redirects": [],
        "env": {},
        "control": ";",
        "next": null
      }
      ]
    }
    ],
    "redirects": [],
    "env": {},
    "control": ";",
    "next": null
  },
  {
    "type": "command",
    "command": {
      "type": "literal",
      "value": "first"
    },
    "args": [
      {
      "type": "pipe",
      "command": {
        "type": "command",
        "command": {
          "type": "literal",
          "value": "second"
        },
        "args": [],
        "redirects": [],
        "env": {},
        "control": ";",
        "next": null
      }
    }
    ],
    "redirects": [],
    "env": {},
    "control": ";",
    "next": null
  },
  {
    "type": "command",
    "command": {
      "type": "literal",
      "value": "echo"
    },
    "args": [
      {
      "type": "variable-substitution",
      "expression": "what/hot/not"
    },
    {
      "type": "literal",
      "value": "ok"
    },
    {
      "type": "concatenation",
      "pieces": [
        {
        "type": "literal",
        "value": "single-quoted arg"
      },
      {
        "type": "literal",
        "value": "double-quoted "
      },
      {
        "type": "variable",
        "name": "var"
      }
      ]
    }
    ],
    "redirects": [
      {
      "type": "redirect-fd",
      "fd": 1,
      "op": ">",
      "filename": {
        "type": "literal",
        "value": "here"
      }
    }
    ],
    "env": {},
    "control": ";",
    "next": null
  }
  ])

  t.end()
})
