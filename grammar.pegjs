commandList "a list of commands"
 = commands:command+

command "a single command"
 = space*
   pre:((variableAssignment / redirect) space+)*
   name:commandName
   post:(space+ (redirect / argument))*
   space* control:controlOperator?

variableAssignment
 = writableVariableName '=' argument

commandName "command name"
 = !redirect name:concatenation

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
 = moveFd / duplicateFd / redirectFd / pipe

pipe =
 "|" space* command:command

moveFd
 = fd:fd? op:('<&' / '>&') dest:fd '-'

duplicateFd
 = fd:fd? op:('<&' / '>&') space* filename:argument

redirectFd
 = fd:fd? op:redirectionOperator space* filename:argument

redirectionOperator
 = '<' / '>' / '>|' / '&>' / '>>' / '&>>'

fd
 = digits:[0-9]+ { return parseInt(join(digits), 10) }

space
 = " " / "\t"
