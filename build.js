var fs = require('fs')
var pegjs = require('pegjs')
var overrideAction = require('pegjs-override-action')
var grammar = fs.readFileSync(__dirname + '/grammar.pegjs', 'utf8')

var parserSource = pegjs.buildParser(grammar, {
  output: "source",
  plugins: [overrideAction],
  overrideActionPlugin: require('./overrides')
})

if (require.main === module) {
  console.log('module.exports=' + parserSource + '.parse')
} else {
  module.exports = eval(parserSource).parse
}
