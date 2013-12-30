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
  'var map = require("array-map")',
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
  function flattenConcatenation (pieces) {
    // TODO - this algo sucks, it's probably on the order of n^4
    var result = [pieces[0]]
      , len = pieces.length
      , prev = pieces[0]
      , current

    for (var i = 1; i < len; i++) {
      current = pieces[i]
      if (current.type == 'concatenation') {
        current = flattenConcatenation(current.pieces)
      }
      if (current.type == 'concatenation') {
        // it's still a concatenation, append it's pieces to ours
        result = result.concat(current.pieces)
      }
      else if (current.type == 'literal' && prev.type == 'literal') {
        // merge two literals
        prev.value += current.value
      }
      else {
        result.push(current)
        prev = current
      }
    }
    return result.length == 1 ? result[0] : {
      type: 'concatenation',
      pieces: result
    }
  }
].join('\n')

rules.conditionalLoop = function (kind, testCommands, commands) {
  return {
    type: kind + '-loop',
    testCommands: testCommands,
    body: commands
  }
}

rules.script = function (first, rest, last) {
  var statements = [first]
  var prev = first
  map(rest, function (oc, i, cmds) {
    setOperator(oc[0], prev)
    statements.push(prev = oc[1])
  })
  return statements

  function setOperator(operator, command) {
    while (command.next) {
      command = command.next
    }
    command.control = operator
  }
}

rules.statement = function (statement, next) {
  if (next) {
    statement.control = next[0]
    statement.next = next[1]
  } else {
    statement.control = ';'
    statement.next = null
  }
  return statement
}

rules.command = function (pre, name, post) {
  var command = {
    type: 'command',
    command: name,
    args: [],
    redirects: [],
    env: {},
    next: null,
    control: ';'
  }
  map(pre, first).concat(map(post, second)).forEach(function (token) {
    if (!token || !token.type) return
    switch (token.type) {
      case 'move-fd':
      case 'duplicate-fd':
      case 'redirect-fd':
        return command.redirects.push(token)
      case 'assignment':
        return command.env[token.name] = token.value
      default:
        command.args.push(token)
    }
  })

  return command
}

rules.chainedStatement = function (operator, statement) {
  return [operator, statement]
}

rules.commandName = function (name) {
  return name
}

rules.controlOperator = function (op) {
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
    type:        'variable-substitution',
    expression:  join(expr), // TODO sub-parser
  }
}

rules.writableVariableName = function () { return text() }

rules.bareword = function (cs) { return literal(cs) }

rules.escapedMetaChar = function (character) { return character }

rules.concatenation = function (pieces) {
  return flattenConcatenation(pieces)
}

rules.singleQuote = function (inner) { return literal(inner) }

rules.doubleQuote = function (contents) {
  var pieces = contents.map(function (it) {
    return isArray(it) ? literal(it) : it
  })
  return flattenConcatenation(pieces)
}

rules.escapedQuote = function (character) {
  return character
}
rules.backticks = function (commands) {
  return {type: 'backticks', commands: commands.map(second)}
}

rules.subshell = function (commands) {
  return {type: 'subshell', commands: commands}
}

/** stdio redirection */
rules.pipe = function (command) {
  return {type: 'pipe', command: command}
}

rules.moveFd = function (fd, op, dest) {
  if (fd == null) fd = op[0] == '<' ? 0 : 1;
  return {
    type: 'move-fd',
    fd: fd,
    op: op,
    dest: dest
  }
}

rules.duplicateFd = function (fd, op, filename) {
  if (fd == null) fd = op[0] == '<' ? 0 : 1;
  return {
    type: 'duplicate-fd',
    fd: fd,
    op: op,
    filename: filename
  }
}

rules.redirectFd = function (fd, op, filename) {
  if (fd == null) fd = op[0] == '<' ? 0 : 1;
  return {
    type: 'redirect-fd',
    fd: fd,
    op: op,
    filename: filename
  }
}
