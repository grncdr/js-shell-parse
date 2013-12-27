var parse = require('./build')

var input = [
  "blah >(substitute-command --with args)",
  "first | second",
  "echo ${what/hot/not} ok 'single-quoted arg'\"double-quoted $var\" > here",
].join('\n')

console.log(
  JSON.stringify(parse(input + '\n'), null, 2)
)
