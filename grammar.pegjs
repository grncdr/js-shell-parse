commandList "a list of commands separated by control operators"
 = (command controlOperator)+

command "a single command"
 = tokens:(space* commandToken)+

commandToken "tokens that compose a command"
 = bareword
 / quotation
 / variableSubstitution
 / environmentVariable
 / subShell
 / backticks
 / commandSubstitution
 / redirectOperator

environmentVariable
 = ('$' name:readableVariableName)

writableVariableName = [a-zA-Z0-9_]+
readableVariableName = writableVariableName / '?'  /* todo, other special vars */

bareword
 = cs:(escapedMetaChar / [^$"';&<> \n])+

escapedMetaChar
 = '\\' metaChar

metaChar
 = '$' / '\\' / '"' / '&' / redirectOperator

variableSubstitution
 = '${' expr:[^}]* '}'

quotation
 = pieces:(singleQuote / doubleQuote / bareword)+ {
   return {
     type: 'quotation',
     pieces: pieces
   }
 }

singleQuote = "'" cs:[^']+ "'"

doubleQuote
 = '"' contents:(chars:[^"$`]+ / expandable:expandsInQuotes / '\\"')+ '"'

expandsInQuotes = backticks / environmentVariable / subShell

backticks
 = '`' commands:command+ '`'

subShell
 = '$(' commands:command+ ')'

commandSubstitution
 = rw:[<>] '(' commands:command+ ')'

space
 = cs:" "+ { return cs.join(' ') }

controlOperator
 = '&&' / '&' / '||' / ';' / '\n'

redirectOperator
 = [<>] / '>>'

