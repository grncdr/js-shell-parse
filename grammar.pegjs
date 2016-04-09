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
          / arithmeticSubstitution
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
 = arithmeticSubstitution
 / commandSubstitution
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
 = expression:aComma { return expression }

aComma "a sequence of arithmetic expressions"
 = head:aAssign tail:( spaceNL* "," spaceNL* expr:aAssign { return expr } )*

aAssign "an arithmetic assignment"
 = left:aCond spaceNL* operator:( "=" !"=" / "*=" / "/=" / "%=" / "+=" / "-=" / "<<=" / ">>=" / "&=" / "^=" / "|=" ) spaceNL* right:aAssign
 / other:aCond

aCond "an arithmetic conditional expression"
 = test:aLogicalOr spaceNL* "?" spaceNL* consequent:aAssign spaceNL* ":" spaceNL* alternate:aAssign
 / other:aLogicalOr

aLogicalOr "an arithmetic logical or"
 = head:aLogicalAnd tail:(spaceNL* op:"||" spaceNL* node:aLogicalAnd { return {op: op, node: node} })*

aLogicalAnd "an arithmetic logical and"
 = head:aBitwiseOr tail:(spaceNL* op:"&&" spaceNL* node:aBitwiseOr { return {op: op, node: node} })*

aBitwiseOr
 = head:aBitwiseXor tail:(spaceNL* op:"|" ![|=] spaceNL* node:aBitwiseXor { return {op: op, node: node} })*

aBitwiseXor
 = head:aBitwiseAnd tail:(spaceNL* op:"^" !"=" spaceNL* node:aBitwiseAnd { return {op: op, node: node} })*

aBitwiseAnd
 = head:aEquality tail:(spaceNL* op:"&" ![&=] spaceNL* node:aEquality { return {op: op, node: node} })*

aEquality
 = head:aComparison tail:(spaceNL* op:( "==" / "!=" ) spaceNL* node:aComparison { return {op: op, node: node} })*

aComparison
 = head:aBitwiseShift tail:(spaceNL* op:( "<=" / ">=" / (v:"<" !"<" { return v }) / (v:">" !">" { return v }) ) spaceNL* node:aBitwiseShift { return {op: op, node: node} })*

aBitwiseShift
 = head:aAddSubtract tail:(spaceNL* op:( "<<" / ">>" ) !"=" spaceNL* node:aAddSubtract { return {op: op, node: node} })*

aAddSubtract
 = head:aMultDivModulo tail:(spaceNL* op:( "+" / "-" ) !"=" spaceNL* node:aMultDivModulo { return {op: op, node: node} })*

aMultDivModulo
 = head:aExponent tail:(spaceNL* op:( (v:"*" !"*" { return v }) / "/" / "%") !"=" spaceNL* node:aExponent { return {op: op, node: node} })*

aExponent
 = head:aNegation tail:(spaceNL* op:"**" spaceNL* node:aNegation { return {op: op, node: node} })*

aNegation
 = operator:( "!" / "~" ) spaceNL* argument:aNegation
 / other:aUnary

aUnary
 = operator:( (op:"+" ![+=]) { return op } / (op:"-" ![-=]) { return op } ) spaceNL* argument:aUnary
 / other:aPreIncDec

aPreIncDec
 = operator:( "++" / "--" ) spaceNL* argument:aPreIncDec
 / other:aPostIncDec

aPostIncDec
 = argument:aParenExpr operators:(spaceNL* op:( "++" / "--" ) { return op })+
 / other:aParenExpr

aParenExpr
 = '(' spaceNL* value:arithmetic spaceNL* ')' { return value }
 / other:aLiteral { return other }

aBareword "arithmetic variable"
  = !'#' name:aBarewordChar+

aBarewordChar
  = '\\' chr:aBarewordMeta { return chr }
  / !aBarewordMeta chr:.   { return chr }

aBarewordMeta = [$"';&<>\n()\[*?|`:+ ]

aConcatenation "concatenation of strings and/or variables"
  = pieces:( aBareword
           / environmentVariable
           / variableSubstitution
           / arithmeticSubstitution
           / commandSubstitution
           / singleQuote
           / doubleQuote
           )+

aLiteral
 = val:aNumber   { return val }
 / val:aConcatenation { return val }

aNumber
 = "0" [xX] digits:[0-9a-fA-Z]+
 / base:[0-9]+ "#" digits:[0-9a-zA-Z]+
 / "0" digits:[0-7]+
 / digits:[0-9]+

continuationStart
 = &( keyword / '"' / "'" / '`' / "$(" / "$((" / "${" ) .*

EOF
 = !.
