commandList "a list of commands"
 = commands:command+

command "a single command"
 = space*
   assignments:(variableAssignment space+)*
   command:commandToken
   args:(space+ argToken)*
   space* redirects:redirect*
   space* control:controlOperator?

variableAssignment
 = writableVariableName '=' argToken

commandToken "command name"
 = bareword
 / concatenation
 / doubleQuote
 / variableSubstitution
 / environmentVariable
 / subShell
 / backticks

argToken "command argument"
 = commandToken
 / commandSubstitution


environmentVariable
 = ('$' name:readableVariableName)

writableVariableName = [a-zA-Z0-9_]+
readableVariableName = writableVariableName / '?'  /* todo, other special vars */

bareword
 = cs:(escapedMetaChar / [^$"';&<>\n()\[\]*?| ])+

escapedMetaChar
 = '\\' character:[$\\"&<> ]

variableSubstitution
 = '${' expr:[^}]* '}'

concatenation
 = pieces:( bareword
          / doubleQuote
          / environmentVariable
          / variableSubstitution
          / subShell
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
 / subShell

backticks
 = '`' commands:commandList+ '`'

subShell
 = '$(' commands:commandList+ ')'

commandSubstitution
 = rw:[<>] '(' commands:commandList ')'

controlOperator
 = '&&' / '&' / '||' / ';' / '\n'

redirect
 = pipe / fileRedirection

pipe =
 "|" space* command:command

fileRedirection
 = op:([<>] / '>>') space* filename:argToken

space
 = " " / "\t"
