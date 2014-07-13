script
 = sections:(spaceNL* statementList spaceNL*)+

statementList "a list of statements"
 = first:statement
   rest:(space* controlOperator spaceNL* statement)*
   last:(space* controlOperator)?

statement
 = statement:( command
             / variableAssignment
             / conditionalLoop
             / ifBlock
             )
   next:(space* chainedStatement)?

chainedStatement
 = operator:('&&' / '||') spaceNL* statement:statement

controlOperator
 = op:('&' / ';' / '\n')

command "a single command"
 = pre:((variableAssignment / redirect) space+)*
   name:(commandName / builtinCommandName)
   post:(space+ (redirect / argument))*
   pipe:(space* pipe)?

conditionalLoop
 = kind:("while" / "until") spaceNL+ test:condition spaceNL*
   "do" spaceNL
   body:script
   "done"

ifBlock
 = "if" spaceNL+ test:script
   "then" spaceNL+ body:script
   elifBlocks:elifBlock*
   elseBody:("else" script)?
   "fi"

elifBlock
 = "elif" spaceNL+ test:condition "then" spaceNL+ body:script

condition
 = test:script

variableAssignment
 = name:writableVariableName '=' value:argument

commandName "command name"
 = !redirect
   !keyword
   !variableAssignment
   name:(concatenation / builtinCommandName)

builtinCommandName
 = '['
 / '[['

argument "command argument"
 = commandName
 / processSubstitution

concatenation
 = pieces:( glob
          / bareword
          / environmentVariable
          / variableSubstitution
          / commandSubstitution
          / singleQuote
          / doubleQuote
          )+

bareword
 = cs:barewordChar+

barewordChar
 = '\\' chr:barewordMeta { return chr }
 / !barewordMeta chr:.   { return chr }

barewordMeta = [$"';&<>\n()\[*?|` ]

glob
 = barewordChar* ('*' / '?' / characterRange / braceExpansion)+ barewordChar*

characterRange
 = $('[' !'-' . '-' !'-' . ']')

braceExpansion
 = (.? !'$') '{' barewordChar+ '}'

singleQuote
 = "'" inner:$([^']*) "'"

doubleQuote
 = '"' contents:(expandsInQuotes / doubleQuoteChar+)* '"'

doubleQuoteChar
 = '\\' chr:doubleQuoteMeta { return chr }
 / '\\\\'                   { return '\\' }
 / !doubleQuoteMeta chr:.   { return chr }

doubleQuoteMeta
 = '"' / '$' / '`'

expandsInQuotes
 = commandSubstitution
 / environmentVariable
 / variableSubstitution

environmentVariable = '$' name:readableVariableName

writableVariableName = [a-zA-Z0-9_]+
readableVariableName = writableVariableName / '?'  /* todo, other special vars */

variableSubstitution = '${' expr:[^}]* '}'

commandSubstitution
 = parenCommandSubstitution / backQuote

parenCommandSubstitution
 = '$(' commands:statementList ')'

backQuote
 = '`' input:backQuoteChar+ '`'

backQuoteChar
 = '\\`'      { return '`' }
 / '\\\\'     { return '\\' }
 / !'`' chr:. { return chr }

processSubstitution
 = rw:[<>] '(' commands:statementList ')'

redirect
 = moveFd / duplicateFd / redirectFd

pipe =
 "|" spaceNL* command:command

moveFd
 = fd:fd? op:('<&' / '>&') dest:fd '-'

duplicateFd
 = src:fd? op:('<&' / '>&') space* dest:fd

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
   / "then"
   / "else"
   / "elif"
   / "fi"
   / "[["
   )
   ( spaceNL+ / EOF )

continuationStart
 = &( keyword / '"' / "'" / '`' / "$(" / "${" / "(" ) .*

EOF
 = !.
