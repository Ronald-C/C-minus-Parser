#
#	Makefile to build symbol table generator
#	- Parses C-- input 
#

LEX_FILE := scanner.l
YACC_FILE := cminus.y

A.OUT := lex.yy.c y.tab.c symTable.c

a.out: lex.yy.c y.tab.c symTable.c symTable.h
	gcc ${A.OUT} -o $@

# Flex file
lex.yy.c: ${LEX_FILE} symTable.h
	flex ${LEX_FILE}

# Yacc file
y.tab.c: ${YACC_FILE} symTable.h
	yacc -d ${YACC_FILE}

.PHONY: clean
clean:
	rm -f lex.yy.c a.out y.tab.*