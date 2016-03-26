#!/usr/bin/env node

const util = require('util')
var parser = require("./" + process.argv[2])
var parse = parser.parse || parser;
process.stdout.write(util.inspect(parse(process.argv[3]), {depth: null}))
