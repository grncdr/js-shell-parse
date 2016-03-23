script
 = spaceNL* statements:statementList?

statementList
 = head:statement
   tail:(controlOperator spaceNL* statement)*
   space* last:controlOperator? spaceNL*

statement
 = statement:(arithmeticStatement
             / subshell
             / bashExtensions
             / command
             / variableAssignment
             / ifBlock
             / conditionalLoop
             / forLoop
             )
   next:(space* chainedStatement)?

chainedStatement
 = operator:('&&' / '||') spaceNL* statement:statement

arithmeticStatement "an arithmetic statement"
 = "((" space* expression:arithmetic space* "))"

subshell "a subshell"
 = "(" space* statements:statementList  space* ")"

command "a single command"
 = pre:((variableAssignment / redirect) space+)*
   name:(commandName / builtinCommandName)
   post:(space+ (redirect / argument))*
   pipe:(space* pipe)?

condition
 = test:script

ifBlock "an if/elif/else statement"
 = "if" spaceNL+ test:condition
   "then" spaceNL+ body:script
   elifBlocks:elifBlock*
   elseBody:("else" script)?
   "fi"

elifBlock
 = "elif" spaceNL+ test:condition "then" spaceNL+ body:script

conditionalLoop "a while/until loop"
 = kind:("while" / "until") spaceNL+ test:condition
   "do" spaceNL+ body:script
   "done"

forLoop "a for loop"
 = "for" space+ loopVar:writableVariableName spaceNL+
   subjects:("in" (space+ argument)*)?
   space* (";" / "\n") spaceNL*
   "do" spaceNL+
   body:statementList spaceNL*
   "done"

bashExtensions
 = time / declare

time "time builtin"
 = "time" space+ flags:("-" [a-z]+ space+)* statements:statementList

declare "declare builtin"
 = ("declare" / "typeset") command:[^\n]+ (";" / "\n")

variableAssignment "a variable assignment"
 = name:writableVariableName '=' value:argument?

commandName "command name"
 = !redirect
   !keyword
   !variableAssignment
   name:(concatenation / builtinCommandName)

builtinCommandName
 = '[[' / '['

argument "command argument"
 = commandName
 / processSubstitution

concatenation "concatenation of strings and/or variables"
 = pieces:( glob
          / bareword
          / environmentVariable
          / variableSubstitution
          / commandSubstitution
          / singleQuote
          / doubleQuote
          )+

bareword "bareword"
 = !'#' cs:barewordChar+

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

arithmeticSubstitution
 = '$((' expression:arithmetic '))'

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

moveFd
 = fd:fd? op:('<&' / '>&') dest:fd '-'

duplicateFd
 = src:fd? op:('<&' / '>&') space* dest:fd

redirectFd
 = fd:fd? op:redirectionOperator space* filename:argument

redirectionOperator
 = '>|' / '>>' / '&>>' / '&>' / '<' / '>'

fd
 = digits:[0-9]+ { return parseInt(join(digits), 10) }

controlOperator
 = space* op:('&' / ';' / '\n')

pipe =
 "|" spaceNL* command:command

space "whitespace"
 = " " / "\t"

spaceNL = space / "\n" / comment

comment "a comment"
  = '#' [^\n]* ("\n" / EOF)

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

// http://www.gnu.org/software/bash/manual/html_node/Shell-Arithmetic.html
arithmetic "an arithmetic expression"
 = expression:aComma

aComma "a sequence of arithmetic expressions"
 = head:aAssign tail:( space* "," space* aComma )*

aAssign "an arithmetic assignment"
 = left:aVariable space* operator:( "=" / "*=" / "/=" / "%=" / "+=" / "-=" / "<<=" / ">>=" / "&=" / "^=" / "|=" ) space* right:aAssign
 / other:aCond

aCond "an arithmetic conditional expression"
 = test:aLogicalOr space* "?" space* consequent:aCond space* ":" space* alternate:aCond
 / other:aLogicalOr

aLogicalOr "an arithmetic logical or"
 = left:aLogicalAnd space* "||" space* right:aLogicalOr
 / other:aLogicalAnd

aLogicalAnd "an arithmetic logical and"
 = left:aBitwiseOr space* "&&" space* right:aLogicalAnd
 / other:aBitwiseOr

aBitwiseOr
 = left:aBitwiseXor space* operator:"|" space* right:aBitwiseOr
 / other:aBitwiseXor

aBitwiseXor
 = left:aBitwiseAnd space* operator:"^" space* right:aBitwiseXor
 / other:aBitwiseAnd

aBitwiseAnd
 = left:aEquality space* operator:"&" space* right:aBitwiseAnd
 / other:aEquality

aEquality
 = left:aComparison space* operator:( "==" / "!=" ) space* right:aEquality
 / other:aComparison

aComparison
 = left:aBitwiseShift space* operator:( "<=" / ">=" / "<" / ">" ) space* right:aComparison
 / other:aBitwiseShift

aBitwiseShift
 = left:aAddSubtract space* operator:( "<<" / ">>" ) space* right:aBitwiseShift
 / other:aAddSubtract

aAddSubtract
 = left:aMultDivModulo space* operator:( "+" / "-" ) space* right:aAddSubtract
 / other:aMultDivModulo

aMultDivModulo
 = left:aExponent space* operator:( "*" / "/" ) space* right:aMultDivModulo
 / other:aExponent

aExponent
 = left:aNegation space* operator:"**" space* right:aExponent
 / other:aNegation

aNegation
 = operator:( "!" / "~" ) space* argument:aNegation
 / other:aUnary

aUnary
 = operator:( "+" !"+" / "-" !"-" ) space* argument:aUnary
 / other:aPreIncDec

aPreIncDec
 = operator:( "++" / "--" ) space* argument:aPreIncDec
 / other:aPostIncDec

aPostIncDec
 // = argument:aPostIncDec space* operator:( "++" / "--" ) // TODO: figure out how to do this
 = argument:aVariable space* operator:( "++" / "--" ) // TODO: figure out how to do this
 / other:aVariable

aVariable
 = name:writableVariableName
 / "$" name:("?")  /* todo, other special vars */
 / other:aNumber

aNumber
 = "0" [xX] digits:[0-9a-fA-Z]+
 / base:[0-9]+ "#" digits:[0-9a-zA-Z]+
 / "0" digits:[0-7]+
 / digits:[0-9]+

continuationStart
 = &( keyword / '"' / "'" / '`' / "$(" / "${" ) .*

EOF
 = !.
