#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "symTable.h"

static Node hashTable[SIZE];

extern int arg_ebp, next_arg_ebp;
extern int loc_ebp, next_loc_ebp;

/* Allocate memory for new entry parsed
 * If entry exists, return reference/ptr to such 
 */
Node symTable_seek(char *text, int sym_depth, int scope_num) {

	if (scope_num > SIZE) {
		yyerror("Array out of bounds");
	} 

	Node ptr = NULL;
	ptr = hashTable[scope_num];	/* Index 0 holds global declarations */

	/* Check if local may be referencing global variable/function argument else, insert */
	while (ptr != NULL) {
		if (!strcmp(ptr->sym_name, text)) {
			return ptr;
		}
		ptr = ptr->nextHash;
	}

	if (ptr == NULL) {	/* If entry does not exist */
		ptr = malloc(sizeof(struct attrNode));
		strcpy(ptr->sym_name, text);
		ptr->sym_number = scope_num;
		ptr->sym_depth = sym_depth;
		
		return ptr;
	}
}

void build_symEntry(Node entry, int size, int sym_ref, int numParam, bool isParam, char *type) {

	if (!entry->sym_declared) {
		
		entry->sym_size = size; 
		if (size) {		/* Array */
			entry->sym_bytes = 4 * size;
		} else {
			entry->sym_bytes = 4;
		}
		entry->sym_ref = sym_ref;
		entry->numParam = numParam;

		entry->isParam = isParam;
		if (isParam) {
			entry->sym_number++;
		}
		entry->type = type;

		if (entry->sym_depth == 0) {
			if (isParam) {
				arg_ebp = next_arg_ebp;
				entry->sym_ebp = arg_ebp;
				next_arg_ebp = arg_ebp + entry->sym_bytes;

			} else {
				entry->sym_ebp = 0;
			}
		} else if(!strcmp(type, INT_VAR) ||  !strcmp(type, INT_ARR)) {
			loc_ebp = next_loc_ebp;
			entry->sym_ebp = loc_ebp;
			next_loc_ebp = loc_ebp - entry->sym_bytes;
		}

		entry->sym_declared = true;
		entry->nextHash = NULL;
		build_symTable(entry);

	} else {
		if (entry->sym_depth == 0){
			printf("Symbol %s already sym_declared in global name space\n",
				entry->sym_name);
		} else {
			printf("Symbol %s already defined in this name space (Scope %d)\n",
				entry->sym_name, entry->sym_number);
		}
	}
}

/* Construct hashTable (symbol table) based on grammar
 */
void build_symTable(Node ptr) {

	if (ptr->sym_number > SIZE) {
		yyerror("Array out of bounds");
	}

	Node recent = NULL;
	if (ptr->sym_depth == 0) {
		recent = hashTable[0];
	} else {
		recent = hashTable[ptr->sym_number];
	}

	if (recent == NULL) {
		ptr->nextHash = NULL;
		hashTable[ptr->sym_number] = ptr;
	} else {
		/* Increment to last filled node */
		while (1) {
			if (recent->nextHash == NULL) {
				break;
			}
			recent = recent->nextHash;
		}
		ptr->nextHash = NULL;
		recent->nextHash = ptr;
	}
}

/* Deallocate symbol table memory */
void free_symTable(void) {

	int i;
	Node tmp, next_tmp;

	for (i = 0; i < SIZE; i++) {
		next_tmp = hashTable[i];

		while ((tmp = next_tmp) != NULL) {
			next_tmp = next_tmp->nextHash;
			free(tmp);
		}
	}
}

/* Print local symbol table hashTable[index > 0] */
void symDump_local(int scope_num) {
	
	Node ptr = hashTable[scope_num];
	while (ptr != NULL) {
		printf("Symbol= %4s; SType= %16s; ArrSize= %2d; Bytes= %3d; ScopeDepth: %2d; ScopeNum: %2d; Offset: %4d\n", 
			ptr->sym_name, ptr->type, ptr->sym_size, ptr->sym_bytes, ptr->sym_depth, ptr->sym_number, ptr->sym_ebp);

		ptr = ptr->nextHash;
	}
}

/* Print global symbol table hashTable[0] */
void symDump_global(void) {
	
	Node ptr = hashTable[0];
	while (ptr != NULL) {
		printf("Symbol= %4s; IsParam= %1d; SType= %16s; ArrSize= %2d; Bytes= %3d; Offset: %4d;\n", 
			ptr->sym_name, ptr->isParam, ptr->type, ptr->sym_size, ptr->sym_bytes, ptr->sym_ebp);

		ptr = ptr->nextHash;
	}
}
