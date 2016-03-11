# shell-parse

Parse bash scripts into AST's

## Synopsis

```js
var parse = require('shell-parse')
parse('echo $PATH') //=> an ugly AST object
```

_(better synopsis will come after real tests)_

## Description

This thing parses strings containing bash scripts into an AST that you might execute using an interpreter or something. The AST structure is still in flux, so you probably don't want to build on this just yet!

If you want to help, there's a whole bunch of [failing test fixtures](https://travis-ci.org/grncdr/js-shell-parse) (borrowed from the lovely [shellcheck](https://github.com/koalaman/shellcheck project)). You can start with reading the [grammar](grammar.pegjs). The grammar defines how text will be matched, while the corresponding rule callbacks in [overrides.js](overrides.js) defines the way those matches will be processed into AST nodes. Be sure to read the comments as there's a tiny bit of magic going on.

If you get stuck trying to fix a test case, **email me**. GitHub issue notifications almost never get my attention.

## Examples

See [the tests](tests) for all the things that can be parsed.

## License

MIT
