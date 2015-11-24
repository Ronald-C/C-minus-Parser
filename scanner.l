%{
#include "y.tab.h"		// to get the token types that we return
#include "symTable.h"		

// yyparse() calls yylex() which return integer value representing token type; 
// optionally may have a value placed in the variable yylval. 
extern YYSTYPE yylval;

int lineno = 1;
%}

comment     	[/][*]([^*]|[*]*[^*/])*[*]+[/]
ichar			[a-z_A-Z]
identifier		{ichar}([0-9]|{ichar})*
digit			[0-9]+

%%

"else" 			return ELSE;
"if" 			return IF;
"int"		 	return INT; 
"return" 		return RETURN;
"void"			return VOID;
"while"			return WHILE;

{identifier}	{
					strcpy(yylval.text, yytext);
					return ID; 
				}
{digit}			{
					yylval.ival = atoi(yytext);
					return NUM;
				}
{comment}		/* ignore comments */

"<"				return '<';
">"				return '>';
"<=" 			return LTE;
">="			return GTE;
"="				return EQUAL;
"!="			return NOTEQUAL;
"+"				return '+';
"-"				return '-';
"*"				return '*';
"/"				return '/';

";"				return ';';
","				return ',';
"["				return '[';
"]"				return ']';
"("				return '(';
")"				return ')';
"{"				return '{'; 
"}"				return '}';

"\n"			{ ++lineno; }
[ \t]+			/* ignore whitespace */
%%