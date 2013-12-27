/**
 * Functions defined here are stringified and injected into grammar actions, so
 * their bodies are actually run in a *different* scope.
 *
 * This means that function arguments are meaningless, and the function bodies
 * actually operate on variable names defined in the grammar file. We still
 * define them as arguments for readability and so that these functions could
 * potentially be used outside of the generated parser.
 *
 * This also explains the "global" functions used here (such as `text()`)...
 * they are defined by the generated parser.
 */

var isArray = require('isarray') // not actually used, just for readability

var rules = exports.rules = {}

exports.initializer = [
  'var isArray = require("isarray")',
  function join (arr) {
    return arr.join("")
  },
  function literal (string) {
    return {
      type: 'literal',
      value: isArray(string) ? string.join('') : string
    }
  },
  function first (arr) {
    return arr[0]
  },
  function second (arr) {
    return arr[1]
  },
].join('\n')

rules.command = function (command, args, redirects, control) {
  if (typeof redirects == 'undefined') redirects = []
  return {
    type: 'command',
    command: command,
    args: args.map(second),
    redirects: redirects,
    control: control
  }
}

rules.controlOperator = function () {
  var op = text()
  return op == '\n' ? ';' : op
}

rules.commandSubstitution = function (rw)  {
  return {
    type: 'command-substitution',
    readWrite: rw,
    commands: commands,
  }
}

rules.environmentVariable  = function () {
  return {type: 'variable', name: name}
}

rules.variableSubstitution = function () {
  return {
    type:        'substitution',
    expression:  join(expr), // TODO sub-parser
  }
}

rules.writableVariableName = function () { return text() }

rules.bareword = function (cs) { return literal(cs) }

rules.escapedMetaChar = function (character) { return character }

rules.singleQuote = function (cs) { return literal(cs) }
rules.doubleQuote = function (contents) {
  contents = contents.map(function (it) {
    return isArray(it) ?  literal(it) : it
  })
  return {
    type: 'double-quote',
    contents: contents
  }
}

rules.backticks = function (commands) {
  return {type: 'backticks', commands: commands}
}

rules.subshell = function (commands) {
  return {type: 'subshell', commands: commands}
}

/** stdio redirection */
rules.pipe = function (command) {
  return {type: 'pipe', command: command}
}

rules.fileRedirection = function (filename) {
  return {
    type: 'redirect',
    op: op,
    filename: filename
  }
}