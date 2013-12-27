commandList "a list of commands"
 = commands:command+

command "a single command"
 = space* command:commandToken
   args:(space+ argToken)*
   space* redirects:redirect*
   space* control:controlOperator?

commandToken "command name"
 = bareword
 / quotation
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
 = cs:(escapedMetaChar / [^$"';&<> \n()\[\]*?|])+

escapedMetaChar
 = '\\' char:[$\\"&<>]

variableSubstitution
 = '${' expr:[^}]* '}'

quotation
 = pieces:(singleQuote / doubleQuote / bareword)+ {
   return {
     type: 'quotation',
     pieces: pieces
   }
 }

singleQuote = "'" cs:[^']* "'"

doubleQuote
 = '"' contents:([^"$`]+ / expandable:expandsInQuotes / '\\"')* '"'

expandsInQuotes = backticks / environmentVariable / subShell

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
