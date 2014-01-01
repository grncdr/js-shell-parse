var test = require('tape')
var parse = require('../parser')

test('globs', function (t) {
  t.deepEqual(parse('thing*/**.whatever', 'argument'), {
    type: 'glob',
    pattern: 'thing*/**.whatever',
  }, "Can parse * globs")
  t.end()

  t.deepEqual(parse('thing-??.txt', 'argument'), {
    type: 'glob',
    pattern: 'thing-??.txt',
  }, "Can parse ? globs")
  t.end()

  t.deepEqual(parse('thing-[1-3][0-9].txt', 'argument'), {
    type: 'glob',
    pattern: 'thing-[1-3][0-9].txt',
  }, "Can parse character range globs")
  t.end()
})
