#
#	Makefile to build symbol table generator
#	- Parses C-- input 
#

LEX_FILE := scanner.l
YACC_FILE := cminus.y

SOURCES := ${wildcard ./*.c}

a.out: lex.yy.c y.tab.c
	gcc $^ -I.\*.h ${SOURCES} -o $@

# Flex file
lex.yy.c: ${LEX_FILE} 
	flex ${LEX_FILE}

# Yacc file
y.tab.c: ${YACC_FILE}
	yacc -d ${YACC_FILE}

.PHONY: clean
clean:
	rm -f lex.yy.c a.out y.tab.*
