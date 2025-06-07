#ifndef __SYMTABLE_H__

	#include <stdio.h>
	#include <stdlib.h>
	#include <unistd.h>
	#include <string.h>
	#include <assert.h>	

	#define HASH_MULTIPLIER 5381
	#define MAX_SCOPE_LENGTH 512

	/*
	 * ---------- SymbolTypeArray ----------
	 *
	 * Each element is a string that contains 1 of the 6 
	 * possible types that a symbol can be
	*/
	extern char* SymbolTypeArray[6];
	
	/*
	 * ---------- SymbolTableElement ----------
	 *
	 * An struct that represents each element of our
	 * symbol list
	 *
	 *   - lineNum: Source line where the symbol appears.
 	 *   - symName: Name of the symbol (e.g., variable name).
 	 *   - symType: Type from SymbolTypeArray.
 	 *   - next: Next symbol in the hash bucket (collision resolution).
 	 *   - scopeNext: Next symbol in the same scope.
	 *   - isActive: 1 if active, 0 if hidden (e.g., due to scope).
	*/
	typedef struct SymbolTableElement
	{
		unsigned int lineNum;
		unsigned int scope;
		char* symName;
		char* symType;
		struct SymbolTableElement* next;
		struct SymbolTableElement* scopeNext;

		int isActive;

	}SymbolTableElement;

	/*
	 * ---------- HashTableElement ----------
	 *
	 * A "wrapper" struct that represents each element of the 
	 * hash bucket. Each element of our hash bucket is the head
	 * of each symbol list. Basically "wraps" the head of 
	 * each of our symbol lists.
	*/
	typedef struct HashTableElement
	{
		SymbolTableElement* symHead;

	}HashTableElement;

	/*
	 * ---------- SymbolTable ----------
	 *
	 * This struct consists a hash table (array) implementation of the symbol table.
	 * Each element of this array is a header of a single-linked Symbol List.
	 * It also contains the number of Bindings we have in our hashtable.
 	 *   - numOfBindings: Total number of symbols stored.
	 *   - hash_t: Array of hash buckets (each is a linked list).
	*/
	typedef struct SymbolTable
	{
		unsigned int numOfBindings;
		HashTableElement hash_t[MAX_SCOPE_LENGTH];
	}SymbolTable;

	/*
 	 * ---------- SyntaxErrors ----------
	 *
 	 *   Linked list for tracking syntax errors during parsing.
	 *
 	 *   - lineNum: Line number where the error occurred.
  	 *   - errMessage: Description of the error.
 	 *   - next: Pointer to the next error in the list.
 	*/
	typedef struct SyntaxErrors
	{
		unsigned int lineNum;
		char* errMessage;
		char* varName;
		struct SyntaxErrors* next;
	}SyntaxErrors;

	extern SymbolTable* mySymTable;
	extern SymbolTableElement** mySymList;
	extern SyntaxErrors * syntaxErrorsHead;

	extern int scope;		// (parser)
	
	extern int maxScope; 		// (parser)

	unsigned int SymTableHash(const char *);

	void initializeTable(void);

	void initializeLibFunc(void);

	SymbolTableElement * SymbolElementCreate(unsigned int, unsigned int, int, char *, char *);

	char* createNamelessFunction(void);

	int SymbolTableInsert(SymbolTableElement *);
	
	void SymbolTablePrint(void);

	int activateSymbol(SymbolTableElement *);

	int deactivateSymbol(SymbolTableElement *);

	SymbolTableElement * SymbolSearching(unsigned int, const char *);

	void SymbolTableDeactiveScope(unsigned int);	

	void insertSyntaxError(const char *, const char *, unsigned int);

	void SyntaxErrorsPrint(void);
	
	int isActiveFunct(int);

	int isLibFunct(const char *);

	#define __SYMTABLE_H_
#endif
