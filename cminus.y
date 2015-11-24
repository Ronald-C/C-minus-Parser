%{
#include <stdio.h>	
#include <stdlib.h>
#include <stdbool.h>
#include "symTable.h"

extern int yyparse();
extern int lineno;		/* line number of variable parsed */
int sym_depth = 0;		/* scope depth off from global scope */
int sym_number = 0;	/* scope number counting from initial scope */

/* Calculated EBP Offset of function arguments */
int arg_ebp = 0;
int next_arg_ebp = 0;
/* Calculate EBP Offset of local variables */
int loc_ebp = 0;
int next_loc_ebp = 0;

Node sym_ptr = NULL;
%}

/* yacc fundamentally works by asking lex to get the next token
 * lex returns this token as an object of type "yystype" But this
 * token can be of arbitrary data type thus we define a union to hold
 * each of these types of tokens that lex can return. Yacc will typedef 
 * "yystype" as the union instead of default (int)
 */
%union {
	int ival;
	//float fval;
	char text[40];
}

/* define the entry point */
%start program

/* define the "terminal symbol" token types used */
%token ELSE IF INT RETURN VOID WHILE
%token LTE GTE EQUAL NOTEQUAL

%token <text> ID 		//variable name
%token <ival> NUM 			//int value

%type <text> var_declaration var call
%type <ival> array type_specifier params param_list
%%

/* this is the CFG yacc will parse */
program : declaration_list ;

declaration_list : declaration_list declaration | declaration ;

declaration : var_declaration | fun_declaration ;

var_declaration : type_specifier ID ';'
	{	
		sym_ptr = symTable_seek($2, sym_depth, sym_number);
		build_symEntry(sym_ptr, 0, 0, 0, false, INT_VAR);
	}
    | type_specifier ID array ';' 
    {	
    	sym_ptr = symTable_seek($2, sym_depth, sym_number);
    	build_symEntry(sym_ptr, $3, 0, 0, false, INT_VAR);
	};

array: '[' NUM ']'
	{
		$$ = $2;
	};

type_specifier : INT 
	{
		$$ = 10;
	}
	| VOID 
	{
		$$ = 11;
	};

fun_declaration : type_specifier ID LPAREN params RPAREN compound_stmt 
	{	
		sym_ptr = symTable_seek($2, sym_depth, sym_number);
		build_symEntry(sym_ptr, 0, 0, $4, false, FUNC);
	};

LPAREN: '('
	{
		arg_ebp = CALLER_SAVE;
		next_arg_ebp = arg_ebp;
	};

RPAREN: ')' ;

params : param_list 
	{
		$$ = $1;
	}
	| VOID 
	{
		$$ = 0;
	};

param_list : param_list ',' param
	{
		$$ = $1 + 1;
	}
	| param 
	{
		$$ = 1;
	};

param : type_specifier ID 
	{	
		sym_ptr = symTable_seek($2, sym_depth, sym_number);
		build_symEntry(sym_ptr, 0, 0, 0, true, INT_VAR);
	}	
	| type_specifier ID '[' ']' 
	{	
		sym_ptr = symTable_seek($2, sym_depth, sym_number);
		build_symEntry(sym_ptr, 0, 0, 0, true, INT_ARR);
	};

compound_stmt : openBrace local_declarations statement_list endBrace ;

openBrace: '{' 
	{
		sym_depth++;
		sym_number++;
		if (sym_depth == 1) {		
			printf("--- Local Symbol Table --- \n");
			loc_ebp = CALLEE_SAVE;	/* save esi, edi */
			next_loc_ebp = loc_ebp;
		}
	};

endBrace: '}' 
	{		
		sym_depth--;
		if (sym_depth == 0) {		/* Dump sym table on endBrace */
			symDump_local(sym_number);	
		} else {	/* Pair endBraces to correct scope */
			symDump_local(sym_number - 1);
		}	
	};

local_declarations : local_declarations var_declaration
                   | /* empty */ ;

statement_list : statement_list statement
            	| /* empty */ ;

statement : expression_stmt
  	| compound_stmt
  	| selection_stmt
  	| iteration_stmt
  	| return_stmt ;

expression_stmt : expression ';'
    | ';' ;

selection_stmt : IF '(' expression ')' statement
   	| IF '(' expression ')' statement ELSE statement ;

iteration_stmt : WHILE '(' expression ')' statement ;

return_stmt : RETURN ';' | RETURN expression ';' ;

expression : var '=' expression | simple_expression ;

var : ID 
	{
		//printf("%d, %s\n", $1->sym_declared, $1->sym_name);
	}
	| ID '[' expression ']' 
	{
		//$1->sym_ref++;
	};
	
simple_expression : additive_expression relop additive_expression
	| additive_expression ;

relop : LTE | '<' | '>' | GTE | EQUAL | NOTEQUAL ;

additive_expression : additive_expression addop term | term ;

addop : '+' | '-' ;

term : term mulop factor | factor ;

mulop : '*' | '/' ;

factor : '(' expression ')' | var | call | NUM ;

call : ID '(' args ')' 
	{
		//$1->sym_ref++;
	};

args : arg_list | /* empty */ ;

arg_list : arg_list ',' expression | expression ;

%% 

// C code from lex that yacc needs to know about
int main() {
	printf("\n");
	yyparse();

	printf("\n*** Global Symbol Table ***\n");
	symDump_global();

	free_symTable();
	printf("\n");
	
	return 0;
}

int yyerror(char *msg) {
	fprintf(stderr, "%s: line %d\n", msg, lineno);
	return 0;
}

yywrap() {
	return 1;
}
