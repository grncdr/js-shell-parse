var parser = require('./build')

var input = [
  'echo ${what/hot/not} ok \'single-quoted arg\'"quoted $var" > here',
  'blah >(subshell command)'
].join('\n')

console.log(
  JSON.stringify(parser.parse(input + '\n'), null, 2)
)
