#include "SymTable.h"

/*
 * Calculates a hash value for a symbol name using HASH_MULTIPLIER
 */

extern int NamelessFunctionNumber; /* variable used by createNamelessFunction()
				    * to hold the number of nameless functions
				    * that have been made until now (it is
				    * defined into parser.y) */


unsigned int SymTableHash(const char *name){
    	unsigned int hash = 0;
 
    	for(; *name != '\0'; name++){
        	hash = (hash * HASH_MULTIPLIER) + *name;
    	}
    
    	return hash % MAX_SCOPE_LENGTH;
}

/* 
 *  Initialize the symbolTable for use from parser 
 */

void initializeTable(void){
    	int i;
    
     	/* allocate and initialize the main symbol table */
    	mySymTable = (SymbolTable *)malloc(sizeof(SymbolTable));
    	assert(mySymTable != NULL);
    	mySymTable->numOfBindings = 0;

    	/* initialize hash table buckets */
    	for(i = 0; i < MAX_SCOPE_LENGTH; i++) 
        	mySymTable->hash_t[i].symHead = NULL;
    	

    	/* allocate and initialize the scope list */
    	mySymList = (SymbolTableElement **)malloc(MAX_SCOPE_LENGTH * sizeof(SymbolTableElement *));
    	assert(mySymList != NULL);
    	//scopeLength = MAX_SCOPE_LENGTH;

    	/* initialize all scope list entries to NULL */
    	for(i = 0; i < MAX_SCOPE_LENGTH; i++){
        	mySymList[i] = NULL;
    	}

    	/* initialize syntax errors list */
    	syntaxErrorsHead = NULL;
}

/*
 *  Add Library Functions to the SymbolTable based on the instructions
 */

void initializeLibFunc(void){
    	int i;

	/* initialize library functions (based on instructions) */
	SymbolTableElement* libFuncs[] = {
        	SymbolElementCreate(0, 0, 1, "print", "LIBFUNC"),
        	SymbolElementCreate(0, 0, 1, "input", "LIBFUNC"),
        	SymbolElementCreate(0, 0, 1, "objectmemberkeys", "LIBFUNC"),
        	SymbolElementCreate(0, 0, 1, "objecttotalmembers", "LIBFUNC"),
        	SymbolElementCreate(0, 0, 1, "objectcopy", "LIBFUNC"),
        	SymbolElementCreate(0, 0, 1, "totalarguments", "LIBFUNC"),
        	SymbolElementCreate(0, 0, 1, "argument", "LIBFUNC"),
        	SymbolElementCreate(0, 0, 1, "typeof", "LIBFUNC"),
        	SymbolElementCreate(0, 0, 1, "strtonum", "LIBFUNC"),
       	 	SymbolElementCreate(0, 0, 1, "sqrt", "LIBFUNC"),
        	SymbolElementCreate(0, 0, 1, "cos", "LIBFUNC"),
        	SymbolElementCreate(0, 0, 1, "sin", "LIBFUNC"),
        	NULL
    	};
    
	/* insert the library functions to Symbol Table */
    	for( i = 0; libFuncs[i] != NULL; i++){
        	SymbolTableInsert(libFuncs[i]);
    	}	

	return;
}

/* 
 *  Create the new symbol table element 
 */

SymbolTableElement * SymbolElementCreate(unsigned int lineNum, unsigned int scope, int isActive, char * symName, char * symType){
	
	/* allocates memory for the new node */
	SymbolTableElement* newNode = (SymbolTableElement*)malloc(sizeof(SymbolTableElement));
    	assert(newNode != NULL);

	/* initialize the fields from params */
    	newNode->lineNum = lineNum;
	newNode->scope = scope;
	newNode->isActive = isActive;
    	newNode->symName = strdup(symName);
    	newNode->symType = strdup(symType);
    	newNode->next = NULL;
    	newNode->scopeNext = NULL;

    	return newNode;
}

/*
 *  Inserts a symbol into the symbol table 
 */

int SymbolTableInsert(SymbolTableElement * sym){
    	/* checking that the sym if its null */
	assert(sym != NULL);

    	/* calculate hash bucket */
    	unsigned int hash = SymTableHash(sym->symName);

    	/* insert into hash table (hash tble) */
    	sym->next = mySymTable->hash_t[hash].symHead;
    	mySymTable->hash_t[hash].symHead = sym;
    	mySymTable->numOfBindings++;

    	/*
    	if (sym->scope >= scopeLength) {
        	unsigned int newLength = scopeLength * 2;
        	mySymList = (SymbolTableElement **)realloc(mySymList,newLength * sizeof(SymbolTableElement *));
        	assert(mySymList != NULL);

        	for (unsigned int i = scopeLength; i < newLength; i++) {
            		mySymList[i] = NULL;
        	}
        	scopeLength = newLength;
    	}*/
	
	/* insert into scope field */
    	sym->scopeNext = mySymList[sym->scope];
    	mySymList[sym->scope] = sym;

    	return 1;
}

/*
 *  Print the symbols of the sym
 */

void SymbolTablePrint(void){
    	int i;
	for(i = 0; i < MAX_SCOPE_LENGTH; i++){
        	if (mySymList[i] == NULL) continue;
        
        	printf("\n--------- Scope #%u ---------\n", i);
        
        	SymbolTableElement * current = mySymList[i];
        	while(current != NULL){
            		const char* typeDesc;
            
            		/* convert type to descriptive string based on faq */
            		if(strcmp(current->symType, "LIBFUNC") == 0){
                		typeDesc = "library function";
            		} 
            		else if(strcmp(current->symType, "GLOBAL") == 0){
                		typeDesc = "global variable";
            		}
            		else if(strcmp(current->symType, "USERFUNC") == 0){
                		typeDesc = "user function";
            		}
            		else if(strcmp(current->symType, "FORMAL") == 0){
                		typeDesc = "formal argument";
            		}
            		else if(strcmp(current->symType, "LOCAL") == 0){
                		typeDesc = "local variable";
            		}
            		else {
                		typeDesc = current->symType; /* something else */
            		}
            
            		printf("\"%s\" [%s] (line %u) (scope %u)\n",current->symName, typeDesc, current->lineNum, i);
                  
            		current = current->scopeNext;
        	}
    	}
	return;
}

/*
 *  Activates a symbol table element by incrementing its isActive counter
 */

int activateSymbol(SymbolTableElement *element){
	if(!element->isActive)
	{
		element->isActive++;
		return 0;
	}
	else
	{
		fprintf(stderr, "\033[5:91mFatal Error:\033[0m Symbols is already active");
		return 1;
	}
}

/*
 *  Deactivates a symbol table element by decrementing its isActive counter
 */

int deactivateSymbol(SymbolTableElement *element){
	if(element->isActive){
		element->isActive--;
		return 0;
	}else{
		fprintf(stderr, "\033[5:91mFatal Error:\033[0m Symbols is already deactivated");
		return 1;
	}
}

/* 
 * Looking for a symbol by a specific name and scope
 */

SymbolTableElement * SymbolSearching(unsigned int scope, const char* name){
    	if(scope >= MAX_SCOPE_LENGTH) return NULL;

    	/* check in the specified scope */
    	SymbolTableElement * current = mySymList[scope];
    	while(current != NULL){
        	if(strcmp(current->symName, name) == 0){
            		return current;
        	}
        	current = current->scopeNext;
    	}

    	return NULL;
}

/*
 *  Deactivate all symbols in a given scope (mark as inactive)
 */

void SymbolTableDeactiveScope(unsigned int scope){
    	if(scope >= MAX_SCOPE_LENGTH) return;

    	SymbolTableElement* current = mySymList[scope];
    	while(current != NULL){
        	current->isActive = 0;
        	current = current->scopeNext;
    	}
}

/*
 *  Adds a syntax error to the error list
 */

void insertSyntaxError(const char* varName, const char* errMessage, unsigned int lineNum){
	SyntaxErrors* newError = (SyntaxErrors*)malloc(sizeof(SyntaxErrors));
    	assert(newError != NULL);
    
	newError->varName = strdup(varName);
    	newError->lineNum = lineNum;
    	newError->errMessage = strdup(errMessage);
    	newError->next = NULL;
    
    	if(syntaxErrorsHead == NULL){
        	syntaxErrorsHead = newError;
    	}else{
        	SyntaxErrors* current = syntaxErrorsHead;
        	while(current->next != NULL){
            		current = current->next;
        	}
        	current->next = newError;
    	}
	return;
}

/*
 *  Prints all the errors from the error list
 */

void SyntaxErrorsPrint(void){
	if (syntaxErrorsHead == NULL) {
        	printf("No syntax errors found.\n");
        	return;
   	}
    
    	printf("\nSyntax Errors:\n");
    	printf("==============\n");
    
    	SyntaxErrors* current = syntaxErrorsHead;
    	while (current != NULL) {
        	fprintf(stderr, "\033[5:91mSyntax Error\033[0m with Variable: \"%s\" at the line %u, %s\n", current->varName, current->lineNum, current->errMessage);
        	current = current->next;
   	}
}

/*
 * Checking if there is an active function (user or library) in current or parent scopes
 * if it does returns 1 (active function exists) or 0 otherwise
 */

int isActiveFunct(int scope){
    	/* if the scope is out of bounds or the scope list has not been initialized then returns 0 */
	if(scope >= MAX_SCOPE_LENGTH || mySymList == NULL || scope<0) return 0;
    	

    	SymbolTableElement * current;

    	/* we start from the current scope and go up to the global scope -> scope 0  */
   	while(scope >= 0){
        	current = mySymList[scope];

        	/* we access over all symbols belonging to the current scope */
        	while(current != NULL){
            		if(current->isActive == 1 && (strcmp(current->symType, "USERFUNC") == 0 || strcmp(current->symType, "LIBFUNC") == 0))
                		return 1;
            		
            		current = current->scopeNext;
        	}
        	scope--;
    	}

   	return 0;
}

/* 
 *   The name we are checking , returns 1 if 'name' is a library function, 0 otherwise
 */

int isLibFunct(const char * functName){
	int i;
	
	/* checking for input to not be null */
    	if(functName == NULL) return 0;

    	/* init the list with all library function names */
    	const char * libraryFunctions[] = {
        	"print", "input", "objectmemberkeys", "objecttotalmembers",
        	"objectcopy", "totalarguments", "argument", "typeof",
        	"strtonum", "sqrt", "cos", "sin", NULL
    	};

    	/* checking against each library function */
    	for(i = 0; libraryFunctions[i] != NULL; i++){
        	if(strcmp(functName, libraryFunctions[i]) == 0)	return 1;
    	}

    	return 0;
}

/*
 *   createNamelessFunction() is responsible for creating another "nameless"
 *   function, meaning that there is a function definition into the program
 *   without the function to be given a particular name.
 */
char* createNamelessFunction()
{
	char *buffer1 = (char *)malloc(20 * sizeof(char));
	if(!buffer1)
	{
		fprintf(stderr, "Error: Malloc failed (buffer1) in createNamelessFunction()\nExits with exit code -1\n\n");
		exit(-1);
	}

	char *buffer2 = (char *)malloc(20 * sizeof(char));
	if(!buffer2)
	{
		fprintf(stderr, "Error: Malloc failed (buffer2) in createNamelessFunction()\nExits with exit code -1\n\n");
		exit(-1);
	}
	
	strcpy(buffer1, "_f_");
	sprintf(buffer2, "%d", ++NamelessFunctionNumber);
	strcat(buffer1, buffer2);
	
	return buffer1;
}



