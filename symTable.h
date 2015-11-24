#ifndef SYMTABLE_H
#define SYMTABLE_H

#define CALLER_SAVE 8
#define CALLEE_SAVE -8
#define MAXTOKENLEN 40
#define SIZE 50

#include <stdbool.h>

typedef struct attrNode {
	char sym_name[MAXTOKENLEN];	
	int sym_size;	/* Array size */
	int sym_bytes;
	
	int sym_ref; 
	int sym_ebp;
	char *type;

	int numParam;
	bool isParam;

	bool sym_declared;	
	int sym_depth;
	int sym_number;

	struct attrNode * nextHash;
} * Node;

/* Seek to next ideal sym table position */
Node symTable_seek(char *, int, int);
/* Build symbol entry */
void build_symEntry(Node, int, int, int, bool, char *);
/* Build sym table */
void build_symTable(Node);
/* Free memory allocated */
void free_symTable(void);
/* Print local sym table */
void symDump_local(int);
/* Print global sym table */
void symDump_global(void);

#endif // SYMTABLE_H

#ifndef INT_VAR
#define INT_VAR "Integer Variable"
#endif 

#ifndef INT_ARR
#define INT_ARR "Integer Array"
#endif 

#ifndef FUNC
#define FUNC "Function"
#endif
