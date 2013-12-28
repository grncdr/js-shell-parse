commandList "a list of commands"
 = commands:command+

command "a single command"
 = space*
   assignments:(variableAssignment space+)*
   command:commandName
   args:(space+ argument)*
   space* redirects:redirect*
   space* control:controlOperator?

variableAssignment
 = writableVariableName '=' argument

commandName "command name"
 = concatenation

argument "command argument"
 = commandName
 / commandSubstitution


environmentVariable
 = ('$' name:readableVariableName)

writableVariableName = [a-zA-Z0-9_]+
readableVariableName = writableVariableName / '?'  /* todo, other special vars */

bareword
 = cs:(escapedMetaChar / [^$"';&<>\n()\[\]*?|` ])+

escapedMetaChar
 = '\\' character:[$\\"&<> ]

variableSubstitution
 = '${' expr:[^}]* '}'

concatenation
 = pieces:( bareword
          / singleQuote
          / doubleQuote
          / environmentVariable
          / variableSubstitution
          / subshell
          / backticks
          )+

singleQuote = "'" cs:[^']* "'"

doubleQuote = '"' contents:(expandsInQuotes / doubleQuoteChar+)* '"'

doubleQuoteChar
 = !doubleQuoteMeta chr:.      { return chr }
 / '\\' chr:doubleQuoteMeta    { return chr }
 / '\\' !doubleQuoteMeta chr:. { return '\\' + chr }

doubleQuoteMeta
 = '"' / '\\' / '$' / '`'

escapedInQuotes
 = '\\' character:[`$"]

expandsInQuotes
 = backticks
 / environmentVariable
 / variableSubstitution
 / subshell

backticks
 = '`' commands:(!backticks command)+ '`'

subshell
 = '$(' commands:command+ ')'

commandSubstitution
 = rw:[<>] '(' commands:commandList ')'

controlOperator
 = '&&' / '&' / '||' / ';' / '\n'

redirect
 = pipe / fileRedirection

pipe =
 "|" space* command:command

fileRedirection
 = op:([<>] / '>>') space* filename:argument

space
 = " " / "\t"
