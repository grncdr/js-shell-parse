script
 = commands:(conditionalLoop / ifBlock / command)+

commandList "one or more commands"
 = first:command rest:(controlOperator command)* last:controlOperator?

command "a single command"
 = spaceNL*
   pre:((variableAssignment / redirect) space+)*
   name:commandName
   post:(space+ (redirect / argument))*
   space*
   next:(logicalOperator spaceNL* command)?

logicalOperator
 = '&&' / '||'

controlOperator
 = '&' / ';' / '\n'

conditionalLoop
 = kind:("while" / "until") spaceNL+ testCommands:commandList spaceNL*
   "do" spaceNL*
   commands:commandList spaceNL*
   "done" spaceNL*

ifBlock
 = "if" spaceNL+ testCommands:commandList "then" spaceNL*
   commands:commandList spaceNL*
   "fi" spaceNL*

variableAssignment
 = writableVariableName '=' argument

commandName "command name"
 = !redirect !keyword name:concatenation

argument "command argument"
 = commandName
 / commandSubstitution

concatenation
 = pieces:( bareword
          / singleQuote
          / doubleQuote
          / environmentVariable
          / variableSubstitution
          / subshell
          / backticks
          )+

bareword = cs:barewordChar+

barewordChar
 = '\\' chr:barewordMeta { return chr }
 / !barewordMeta chr:.   { return chr }

barewordMeta = [$"';&<>\n()\[\]*?|` ]

singleQuote = "'" inner:$([^']*) "'"

doubleQuote = '"' contents:(expandsInQuotes / doubleQuoteChar+)* '"'

doubleQuoteChar
 = '\\' chr:doubleQuoteMeta { debugger; return chr }
 / '\\\\'                   { debugger; return '\\' }
 / !doubleQuoteMeta chr:.   { debugger; return chr }

doubleQuoteMeta = '"' / '$' / '`'

expandsInQuotes
 = backticks
 / environmentVariable
 / variableSubstitution
 / subshell

environmentVariable = '$' name:readableVariableName

writableVariableName = [a-zA-Z0-9_]+
readableVariableName = writableVariableName / '?'  /* todo, other special vars */

variableSubstitution = '${' expr:[^}]* '}'

backticks
 = '`' commands:(!backticks command)+ '`'

subshell
 = '$(' commands:commandList ')'

commandSubstitution
 = rw:[<>] '(' commands:commandList ')'

redirect
 = moveFd / duplicateFd / redirectFd / pipe

pipe =
 "|" spaceNL* command:command

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

spaceNL
 = space / "\n"

keyword
 = ( "while"
   / "until"
   / "for"
   / "done" // "done" must come before "do"
   / "do"
   / "case"
   / "esac"
   / "if"
   / "fi" )
   ( spaceNL+ / EOF )

EOF
 = !.
