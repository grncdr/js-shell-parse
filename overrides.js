/**
 * Functions defined here are stringified and injected into grammar actions, so
 * they are run in a *different* scope. The argument names *must match* the
 * named expressions of the grammar rule they match, and certain globals are
 * that the argument
 */

var isArray = require('isarray')

exports.initializer = [
  'var isArray = require("' + require.resolve('isarray') + '")',
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
  }
].join('\n')

var rules = exports.rules = {}

rules.command = function (tokens) {
  return {
    type: 'command',
    command: tokens.shift()[0],
    args: tokens.map(first)
  }
}

rules.commandSubstitution = function ()  {
  return {
    type: 'command-substitution',
    commands: commands,
    readWrite: rw
  }
}

rules.redirectOperator = function () {
  return { type: 'redirect', op: text() }
}

rules.controlOperator = function () {
  var op = text()
  if (op == '\n') op = ';'
  return { type: 'flow-control', op: ';' }
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
rules.writableVariableName = function () { return text() }

rules.bareword = function (cs) { return literal(cs) }
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
