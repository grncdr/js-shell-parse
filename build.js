var fs = require('fs')
var pegjs = require('pegjs')
var overrideAction = require('pegjs-override-action')

var input     = __dirname + '/grammar.pegjs'
var output    = __dirname + '/peg-parser.js'
var overrides = __dirname + '/overrides.js'

if (require.main === module) {
  if (process.argv[2] == '-w') {
    watch()
  } else {
    console.log(getSource())
  }
}

function getSource () {
  delete require.cache[require.resolve('./overrides')]
  var grammar = fs.readFileSync(input, 'utf8')
  return 'module.exports = ' + pegjs.buildParser(grammar, {
    output: "source",
    allowedStartRules: [
      'script',
      'command',
      'argument'
    ],
    plugins: [overrideAction],
    overrideActionPlugin: require('./overrides')
  })
}

function watch () {
  fs.watchFile(input, onChange)
  fs.watchFile(overrides, onChange)

  function onChange (curr, prev) {
    if (curr.mtime > prev.mtime) {
      try {
        var source = getSource()
        fs.writeFileSync(output, source)
      } catch (err) {
        console.error(err.message)
      }
    }
  }
}

