#!/usr/bin/env node

const util = require('util')
var parser = require("./" + process.argv[2])
var parse = parser.parse || parser;
process.stdout.write(JSON.stringify(parse(process.argv[3]), null, '  '))
