var parser = require('./build')

var input = [
  'blah >(subshell command)',
  'first | second',
  'echo ${what/hot/not} ok \'single-quoted arg\'"quoted $var" > here',
].join('\n')

console.log(
  JSON.stringify(parser.parse(input + '\n'), null, 2)
)
