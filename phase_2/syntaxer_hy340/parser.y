%{
        #include "SymTable.h"
	#include "parser.h"
	
	/* declaration of yyparse() exists into parser.h, generated when
         * parser.c is generated, too. parser.h is automatically included into
         * parser.c, so there is no need to include it into parser.y (here). */        


	/* Custom lexer function declaration */
        int yylex(void);
	void yyerror(const char*);

	char* SymbolTypeArray[6] = { "GLOBAL", "LOCAL", "FORMAL",
                                     "LIBFUNC", "USERFUNC", "NILL"};

	SymbolTable* mySymTable = NULL;
        SymbolTableElement** mySymList = NULL;
	SyntaxErrors * syntaxErrorsHead = NULL;

        /*
         * ---------- Extern yyin, yyout, yylineno, yytext ----------
         * Proper communication between Bison and the above
         * variable names understood by lex
        */
        extern FILE *yyin, *yyout;
        extern int yylineno;
	extern char* yytext;

	int loopFlag;
	int returnFlag;
    	int scope;
    	int maxScope;
	int NamelessFunctionNumber = 0;
%}

/* grammar declarations */
%start program

/* "union" says that yylval will be a struct 
 * with the fields union{} contains. We need this because 
 * yylval will need to store more than one data type. */
%union{
	int intVal;
	char* strVal;
	float realVal;
	SymbolTableElement* exprNode;		
}

/* simple tokens */
%token IF WHILE ELSE FOR FUNCTION RETURN BREAK CONTINUE AND NOT OR LOCAL
%token TRUE FALSE NIL EQUAL ASSIGN PLUS MINUS MUL DIV MOD NOT_EQUAL 
%token PLUS_PLUS MINUS_MINUS GREATER LESS GREATER_EQUAL LESS_EQUAL
%token LEFT_CURLY_BRACKET RIGHT_CURLY_BRACKET 
%token LEFT_SQUARE_BRACKET RIGHT_SQUARE_BRACKET 
%token LEFT_PARENTHESIS RIGHT_PARENTHESIS SEMICOLON COMMA COLON DOUBLE_COLON
%token DOT DOUBLE_DOT SINGLE_LINE_COMMENT

/* terminal tokens with a value of type <type> */
%token <strVal> IDENTIFIER
%token <intVal> INTEGER
%token <realVal> REAL
%token <strVal> STRING

/* non-terminal tokens with a value of type <type> */
%type <strVal> stmnt stmntStar
%type <intVal> expr
%type <strVal> ifstmnt
%type <strVal> whilestmnt
%type <strVal> forstmnt
%type <strVal> returnstmnt
%type <strVal> block
%type <strVal> funcdef
%type <strVal> assignexpr
%type <strVal> term
%type <exprNode> lvalue	
%type <strVal> primary
%type <strVal> call
%type <strVal> objectdef
%type <strVal> const
%type <strVal> member
%type <strVal> elist elistStar
%type <strVal> callsufix
%type <strVal> normcall
%type <strVal> methodcall
%type <strVal> indexed indexedStar
%type <strVal> indexedelem
%type <strVal> idlist identStar
%type <strVal> slcomment

/* priority definitions (same line --> same priority -/- priority decreases
 * from bottom to the top) */   
%right ASSIGN
%left OR
%left AND
%nonassoc EQUAL NOT_EQUAL
%nonassoc GREATER GREATER_EQUAL LESS LESS_EQUAL
%left PLUS MINUS
%left MUL DIV MOD
%right NOT PLUS_PLUS MINUS_MINUS
%left DOT DOUBLE_DOT
%left LEFT_SQUARE_BRACKET RIGHT_SQUARE_BRACKET
%left LEFT_PARENTHESIS RIGHT_PARENTHESIS  

%define parse.error verbose /* for analytic error-messages in yyerror() call */


%%
/* grammar description */
program: stmnt stmntStar
			{
				fprintf(yyout, "program: stmt stmtstar at line:%d\n", yylineno);
			}
;

stmntStar: stmnt stmntStar
			{
				fprintf(yyout, "stmntStar: stmnt stmntStar at line:%d\n",yylineno);
			} 
		|
			{
				fprintf(yyout, "stmntStar: null at line:%d\n",yylineno);	
			}
;
			
stmnt: expr SEMICOLON 
			{
				fprintf(yyout,"\nstmt: expr; at line:%d\n", yylineno);
			}
		
		| ifstmnt
				{
					fprintf(yyout,"stmnt: IF stmnt\n");
				}
		
		| whilestmnt
				{
					fprintf(yyout,"stmnt: WHILE stmnt\n");
				}
		
		| forstmnt
				{
					fprintf(yyout,"stmnt: FOR stmnt\n");
				}
		
		| returnstmnt
				{
					fprintf(yyout,"stmnt: RETURN stmnt\n");
					if(scope == 0)
						insertSyntaxError("return", "cannot be used while outside of a function", yylineno);
					else if(isActiveFunct(scope) == 0 && returnFlag == 1)
						insertSyntaxError("return", "cannot be used while outside of a function", yylineno);
				}

		| BREAK SEMICOLON
				{
					fprintf(yyout,"\nstmnt: BREAK;\n");
					if(loopFlag == 0)
						insertSyntaxError("break", "cannot be used while outside of a loop", yylineno);
				}
		
		| CONTINUE SEMICOLON
				{
					fprintf(yyout,"\nstmnt: CONTINUE;\n");
					if(loopFlag == 0)
						insertSyntaxError("continue", "cannot be used while outside of a loop", yylineno);
				}

		| block
				{
					fprintf(yyout,"stmt: BLOCK stmnt\n");
				}

		| funcdef
				{
					fprintf(yyout,"stmnt: FUNCTION DEFINITION\n");
				}

		| SEMICOLON	
				{
					fprintf(yyout,"stmnt: SEMICOLON\n\n");
				}
;

expr: assignexpr
				{
					fprintf(yyout,"expr: assignexpr\n");
				}
	| expr PLUS expr
				{
					fprintf(yyout,"\nexpr: expression PLUS expression\n");
					$$ = $1 + $3;
					fprintf(yyout, "%d = %d + %d\n", $$, $1, $3);
				}

	| expr MINUS expr	
				{
					fprintf(yyout,"\nexpr: expression MINUS expression\n", $1, $3);
					$$ = $1 - $3;
					fprintf(yyout, "%d = %d - %d\n", $$, $1, $3);
				}
	
	| expr MUL expr
				{
					fprintf(yyout,"\nexpr: expression MUL expression\n", $1, $3);
					$$ = $1 * $3;
					fprintf(yyout, "%d = %d * %d\n", $$, $1, $3);
				}

	| expr DIV expr
				{
					fprintf(yyout,"\nexpr: expression DIV expression\n", $1, $3);
					$$ = $1 / $3;
					fprintf(yyout, "%d = %d / %d\n", $$, $1, $3);
				}

	| expr MOD expr
				{
					fprintf(yyout,"\nexpr: expression MOD expression \n", $1, $3);
					$$ = $1 % $3;
					fprintf(yyout, "%d = %d % %d\n", $$, $1, $3);
				}

	| expr GREATER expr
				{
					fprintf(yyout,"\nexpr: expression GREATER expression \n", $1, $3);
					$$ = ($1>$3)?1:0;
					fprintf(yyout, "%d > %d\n", $$, $1, $3);
				}

	| expr GREATER_EQUAL expr
				{
					fprintf(yyout,"\nexpr: expression GREATER_EQUAL expression\n", $1, $3);
					$$ = ($1>=$3)?1:0;
					fprintf(yyout, "%d >= %d\n", $$, $1, $3);
				}

	| expr LESS expr
				{
					fprintf(yyout,"\nexpr: expression LESS expression\n", $1, $3);
					$$ = ($1<$3)?1:0;
					fprintf(yyout, "%d < %d\n", $$, $1, $3);
				}

	| expr LESS_EQUAL expr
				{
					fprintf(yyout,"\nexpr: expression LESS_EQUAL expression\n", $1, $3);
					$$ = ($1<=$3)?1:0;
					fprintf(yyout, "%d <= %d\n", $$, $1, $3);
				}

	| expr EQUAL expr
				{
					fprintf(yyout,"\nexpr: expression EQUAL expression\n", $1, $3);
					$$ = ($1==$3)?1:0;
					fprintf(yyout, "%d == %d\n", $$, $1, $3);
				}

	| expr NOT_EQUAL expr
				{
					fprintf(yyout,"\nexpr: expression NOT_EQUAL expression\n", $1, $3);
					$$ = ($1!=$3)?1:0;
					fprintf(yyout, "%d != %d\n", $$, $1, $3);
				}
		
	| expr AND expr
				{
					fprintf(yyout,"\nexpr: expression AND expression\n", $1, $3);
					$$ = ($1&&$3)?1:0;
					fprintf(yyout, "%d && %d\n", $$, $1, $3);
				}

	| expr OR expr
				{
					fprintf(yyout,"\nexpr: expression OR expression\n", $1, $3);
					$$ = ($1||$3)?1:0;
					fprintf(yyout, "%d || %d\n", $$, $1, $3);
				}

	| term
				{
					fprintf(yyout,"expr: term\n");
				}
;

assignexpr: lvalue ASSIGN expr
				{
					fprintf(yyout,"\nassignexpr: lvalue ASSIGN expr\n");
					
					if($1 != NULL)
					{
						printf("$1->symType = %s, $1->symName = %s\n", $1->symType, $1->symName);
						
						if(strcmp($1->symType, "LIBFUNC") == 0)
							insertSyntaxError($1->symName,"cannot assign expr on a library function", $1->lineNum);
						else if(strcmp($1->symType, "USERFUNC") == 0)
							insertSyntaxError($1->symName,"cannot assign expr on a predefined user function", $1->lineNum);
					}
				}
;

term: LEFT_PARENTHESIS expr RIGHT_PARENTHESIS
				{
					fprintf(yyout, "\nterm: LEFT_PARENTHESIS expr RIGHT_PARENTHESIS\n");
				}
	| MINUS expr
				{
					fprintf(yyout,"\nterm: MINUS expr\n");
				}
	| NOT expr
				{
					fprintf(yyout,"\nterm: NOT expr\n");
				}
	| PLUS_PLUS lvalue
				{
					fprintf(yyout,"\nterm: PLUS_PLUS lvalue\n");

					if (strcmp($2->symType, "LIBFUNC") == 0)
						insertSyntaxError($2->symName, "cannot ++lvalue a library function", yylineno);
					else if (strcmp($2->symType, "USERFUNC") == 0)
						insertSyntaxError($2->symName, "cannot ++lvalue a pre-defined user function", yylineno);
				}
	| lvalue PLUS_PLUS
				{
					fprintf(yyout,"\n term: lvalue PLUS_PLUS\n");

                                        if (strcmp($1->symType, "LIBFUNC") == 0)
                                                insertSyntaxError($1->symName, "cannot lvalue++ a library function", yylineno);
                                        else if (strcmp($1->symType, "USERFUNC") == 0)
                                                insertSyntaxError($1->symName, "cannot lvalue++ a pre-defined user function", yylineno);
				}
	| MINUS_MINUS lvalue
				{
					fprintf(yyout,"\nterm: MINUS_MINUS lvalue\n");

                                        if (strcmp($2->symType, "LIBFUNC") == 0)
                                                insertSyntaxError($2->symName, "cannot --lvalue a library function", yylineno);
                                        else if (strcmp($2->symType, "USERFUNC") == 0)
                                                insertSyntaxError($2->symName, "cannot --lvalue a pre-defined user function", yylineno);
				}
	| lvalue MINUS_MINUS
				{
					fprintf(yyout,"\nterm: lvalue MINUS_MINUS\n");

                                        if (strcmp($1->symType, "LIBFUNC") == 0)
                                                insertSyntaxError($1->symName, "cannot lvalue-- a library function", yylineno);
                                        else if (strcmp($1->symType, "USERFUNC") == 0)
                                                insertSyntaxError($1->symName, "cannot lvalue-- a pre-defined user function", yylineno);
				}
	| primary
				{
					fprintf(yyout,"term: primary\n");
				}
;

primary: lvalue
				{
					fprintf(yyout,"primary: lvalue\n");
				}
	| call
				{
					fprintf(yyout,"primary: call\n");
				}
	| objectdef
				{
					fprintf(yyout,"primary: objectdef\n");
				}

	| LEFT_PARENTHESIS funcdef RIGHT_PARENTHESIS
				{
					fprintf(yyout,"primary: LEFT_PARENTHESIS funcdef RIGHT_PARENTHESIS\n");
				}

	| const
				{
					fprintf(yyout,"primary: const %s\n", yytext);
				}
;

lvalue: IDENTIFIER
                                {
                                        fprintf(yyout,"\nlvalue: IDENTIFIER %s\n", yytext);
                                        
					int tScope = scope;
                                        SymbolTableElement* sym = NULL;

                                        while (tScope >= 0 && sym == NULL) 
					{
                                                sym = SymbolSearching(tScope, yytext);
                                                tScope--;
                                        }

                                        if (sym == NULL) 
					{
                                                if (scope == 0) 
						{
                                                        sym = SymbolElementCreate(yylineno, 0, 1, yytext, "GLOBAL");
                                                        SymbolTableInsert(sym);
                                                        $$=sym;
                                                        printf("$$->symType = %s, $$->symName = %s\n", sym->symType, sym->symName);
                                                }
                                                else 
						{
                                                        sym = SymbolElementCreate(yylineno, tScope, 1, yytext, "LOCAL");
                                                        SymbolTableInsert(sym);
                                                        $$=sym;
                                                }
                                        }
                                        else 
					{
                                                if (!strcmp(sym->symType, "GLOBAL")) {}
                                                else if (isActiveFunct(scope-1) && scope > 0) 
						{
                                                        if( (strcmp(sym->symType, "FORMAL") || !(sym->scope == scope) ) 
											   && strcmp(sym->symType,"USERFUNC")) 
							{
                                                        	if (!isLibFunct(yytext))
                                                                        insertSyntaxError(yytext, "cannot be accessed due to an active function being interposed.", yylineno);
                                                	}

                                                }
                                        	$$ = sym;
                                	}
				}

        | LOCAL IDENTIFIER
                                {
                                        fprintf(yyout, "\nlvalue: LOCAL IDENTIFIER\n");
                                        SymbolTableElement* sym = SymbolSearching(scope, yytext);
                                        if (sym != NULL)
                                                $$=sym;
                                        else 
					{
                                                if (isLibFunct(yytext)) 
						{
                                                        insertSyntaxError(yytext, "Name of variable is a reserved keyword for a library function", yylineno);
                                                        $$=NULL;
                                                }
                                                else 
						{
                                                        if (scope == 0)
                                                                sym = SymbolElementCreate(yylineno, 0, 1, yytext, "GLOBAL");
                                                        else
                                                                sym = SymbolElementCreate(yylineno, scope, 1, yytext, "LOCAL");
                                                        
							SymbolTableInsert(sym);
                                                        $$=sym;
                                                }
                                        }
                                }

        | DOUBLE_COLON IDENTIFIER
                                {
                                        fprintf(yyout,"\nlvalue: ::IDENTIFIER\n");

                                        SymbolTableElement* sym = SymbolSearching(0, yytext);
                                        if (sym != NULL) 
                                                $$=sym;
                                        else 
					{
                                                $$=NULL;
                                                insertSyntaxError(yytext, "is referencing to an undefined global variable", yylineno);
                                        }
                                }

	| member
				{
					fprintf(yyout,"lvalue: member\n");
				}
;

call: call LEFT_PARENTHESIS elist RIGHT_PARENTHESIS
				{
					fprintf(yyout,"call: call LEFT_PARENTHESIS elist RIGHT_PARENTHESIS\n");
				}
	
	| lvalue callsufix
				{
					fprintf(yyout,"call: lvalue callsuffix\n");
				}

	| LEFT_PARENTHESIS funcdef RIGHT_PARENTHESIS LEFT_PARENTHESIS elist
RIGHT_PARENTHESIS
				{
					fprintf(yyout,"call: LEFT_PAR funcdef RIGHT_PAR LEFT_PAR elist RIGHT_PAR\n");
				}
;

member: lvalue DOT IDENTIFIER
				{
					fprintf(yyout,"member: lvalue DOT ID\n");
				}
	| lvalue LEFT_SQUARE_BRACKET expr RIGHT_SQUARE_BRACKET
				{
					fprintf(yyout,"member: lvalue LEFT_SQUARE_BRACKET expr RIGHT_SQUARE_BRACKET\n");
				}
	| call DOT IDENTIFIER
				{
					fprintf(yyout,"member: call DOT ID\n");
				}
	| call LEFT_SQUARE_BRACKET expr RIGHT_SQUARE_BRACKET
				{
					fprintf(yyout,"member: call LEFT_SQUARE_BRACKET expr RIGHT_SQUARE_BRACKET\n");
				}
;

callsufix: normcall
				{
					fprintf(yyout,"\ncallsuffix: normcall\n");
				}
	
	| methodcall
				{
					fprintf(yyout,"\ncallsuffix: methodcall\n");
				}
;

normcall: LEFT_PARENTHESIS elist RIGHT_PARENTHESIS
				{
					fprintf(yyout,"normcall: LEFT_PARENTHESIS elist RIGHT_PARENTHESIS\n");
				}
;

methodcall: DOUBLE_DOT IDENTIFIER LEFT_PARENTHESIS elist RIGHT_PARENTHESIS
				{
					fprintf(yyout,"methodcall: DOBLE_DOT ID LEFT_PAR elist RIGHT_PARENTHESIS\n");
				}
;

elist: expr elistStar
				{
					fprintf(yyout,"\nelist: expr elistStar\n");
				}
	|
				{
					fprintf(yyout,"\nelist: NULL\n");
				}
;

elistStar: COMMA expr elistStar
				{
					fprintf(yyout,"\neliststar: COMMA expr elistStar\n");
				}
	| 
				{
					fprintf(yyout,"\neliststar, NULL\n");
				}
;

objectdef: LEFT_SQUARE_BRACKET elist RIGHT_SQUARE_BRACKET
				{
					fprintf(yyout,"\nobjectdef: LEFT_SQUARE_BRACKET elist RIGHT_SQUARE_BRACKET\n");
				}
	
	| LEFT_SQUARE_BRACKET indexed RIGHT_SQUARE_BRACKET
				{
					fprintf(yyout,"\nobjectdef: LEFT_SQUARE_BRACKET indexed RIGHT_SQUARE_BRACKET\n");
				}
;

indexed: indexedelem indexedStar 
				{
					fprintf(yyout,"indexed: indexedelem indexedStar\n");
				}
;

indexedStar: COMMA indexedelem indexedStar
				{
					fprintf(yyout,"indexedstar: COMMA indexedelem indexedStar\n");
				}
	|  
				{
					fprintf(yyout,"indexedstar: NULL\n");
				}
;

indexedelem: LEFT_CURLY_BRACKET expr COLON expr RIGHT_CURLY_BRACKET
				{
					fprintf(yyout, "\nindexedelem: LEFT_CURLY_BRACKET expr COLON expr RIGHT_CURLY_BRACKET\n");
				}
;

block: LEFT_CURLY_BRACKET{scope++;} stmnt stmntStar RIGHT_CURLY_BRACKET{SymbolTableDeactiveScope(scope); scope--;}
				{
					fprintf(yyout, "\nblock: LEFT_CURLY_BRACKET stmnt stmntStar RIGHT_CURLY_BRACKET\n");
				}
	
	| LEFT_CURLY_BRACKET{} RIGHT_CURLY_BRACKET{} 
				{
					fprintf(yyout, "\nblock: LEFT_CURLY_BRACKET RIGHT_CURLY_BRACKET\n");
				}
;

funcdef: FUNCTION IDENTIFIER 
				{
					SymbolTableElement* sym = SymbolSearching(scope, yytext);
					if (sym == NULL) {
						/* Nothing like this exists in this scope. */
						if (isLibFunct(yytext)==1) {
							/* checks if it is a library function */
							insertSyntaxError(strdup(yytext), strdup("is a library function and cannot be overshadowed."), yylineno);
						}
						else {
							/* it is not a librayr function, either */
							sym = SymbolElementCreate(yylineno, scope, 1, yytext, "USERFUNC");
							SymbolTableInsert(sym);
						}
					}
					else {
						/* there is smth like this in given scope */
						if (!strcmp(sym->symType, "USERFUNC")) {
							insertSyntaxError(strdup(yytext), strdup("is a previously defined user function and cannot be redefined."), yylineno);
						}
						else if(!strcmp(sym->symType, "LOCAL_VAR")) {
							insertSyntaxError(strdup(yytext), strdup("is a previously defined local variable and cannot be redefined as a function."), yylineno);
						}
						else if (!strcmp(sym->symType, "GLOBAL")) {
							insertSyntaxError(strdup(yytext), strdup("is a previously defined global variable and cannot be redefined as a function."), yylineno);
						}
						else if (!strcmp(sym->symType, "FORMAL")) {
							insertSyntaxError(strdup(yytext), strdup("is a previously defined formal variable and cannot be redefined as a function."), yylineno);
						}
						else if (isLibFunct(sym->symName)==1) {

							insertSyntaxError(strdup(yytext), strdup("is a library function and cannot be overshadowed."), yylineno);
						}
					}
				}
	 LEFT_PARENTHESIS
				{
					scope++;
				}
	idlist
	RIGHT_PARENTHESIS
				{
					scope--;
				}
	block
				{
					fprintf(yyout,"funcdef: function id {}\n");
				}

| 	FUNCTION	
				{
					SymbolTableElement* sym = SymbolElementCreate(yylineno, scope, 1, createNamelessFunction(),"USERFUNC");
					SymbolTableInsert(sym);
				}
	LEFT_PARENTHESIS
				{
					scope++;
				}
	idlist
	RIGHT_PARENTHESIS
				{
					// deactivate scope (?)
					scope--;
				}
	block
				{
					fprintf(yyout,"\nfuncdef: function(){}\n");
				}
;

const: INTEGER
				{
					fprintf(yyout, "\nconst: INTEGER with value %d\n", atoi (yytext));
				}
	
	| REAL
				{
					fprintf(yyout, "\nconst: REAL with value %f\n", atof(yytext));
				}
	
	| STRING 
				{
					fprintf(yyout, "\nconst: STRING with value %s\n", yytext);
				}

	| NIL
				{
					fprintf(yyout, "\nconst: NIL\n");
				}

	| TRUE 
				{
					fprintf(yyout, "\nconst: TRUE\n");
				}
	
	| FALSE
				{
					fprintf(yyout, "\nconst: FALSE\n");
				}
;

idlist: IDENTIFIER		
      				{
      					fprintf(yyout, "idlist: IDENTIFIER\n");
					SymbolTableElement * sym = SymbolSearching(scope, yytext);
					if(sym == NULL){
						if(isLibFunct(yytext)==1)
							insertSyntaxError(yytext,"tries to pass a library function name as a parameter",yylineno);
						else{
							sym=SymbolElementCreate(yylineno, scope, 1, yytext, "FORMAL");
							SymbolTableInsert(sym);
						}
					}else{
						if(strcmp(sym->symType,"FORMAL")==0){
							if(isActiveFunct(scope)==0){
								sym=SymbolElementCreate(yylineno, scope, 1, yytext, "FORMAL");
								SymbolTableInsert(sym);
							}
						}
					}	
				}
	identStar
				{
					fprintf(yyout,"idlist: IDENTIFIER identStar\n");
				}
	
	| 
				{
					fprintf(yyout,"idlist: VOID\n");
				}
;

identStar: COMMA IDENTIFIER
				{
					fprintf(yyout,"identStar: COMMA IDENTIFIER\n");
					SymbolTableElement * sym=SymbolSearching(scope, yytext);
					if(sym == NULL){
						if(isLibFunct(yytext)==1) insertSyntaxError(yytext,"formal argument can not be library function",yylineno);
						else{
							sym=SymbolElementCreate(yylineno, scope, 1, yytext, "FORMAL");
							SymbolTableInsert(sym);
						}
					}else{
						if(strcmp(sym->symType,"FORMAL")==0) insertSyntaxError(yytext, "double declaration for a formal type", yylineno);
					}
				}
	|
				{
					fprintf(yyout,"identStar: VOID\n");
				}
;

ifstmnt: IF LEFT_PARENTHESIS expr RIGHT_PARENTHESIS stmnt ELSE stmnt
				{
					fprintf(yyout,"\nifstmt:  if(expr)stmnt[else stmt]\n");
				}
	
	| IF LEFT_PARENTHESIS expr RIGHT_PARENTHESIS stmnt
				{
					fprintf(yyout,"\nifstmt: if(expr)stmnt\n");
				}
;

whilestmnt: WHILE LEFT_PARENTHESIS expr RIGHT_PARENTHESIS {loopFlag=1;} stmnt {loopFlag=0;}
				{
					fprintf(yyout,"\nwhilestmnt: while(expr)stmnt\n");
				}
;

forstmnt: FOR LEFT_PARENTHESIS elist SEMICOLON expr SEMICOLON elist
RIGHT_PARENTHESIS {loopFlag=1;} stmnt {loopFlag=0;}
				{
					fprintf(yyout,"\nforstmnt: for(elist;expr;elist)stmnt\n");
				}
;

returnstmnt: RETURN expr SEMICOLON
				{
					fprintf(yyout,"return expression;\n");
				}
	
	| RETURN SEMICOLON
				{
					fprintf(yyout,"return;\n");
				}
;

slcomment: SINGLE_LINE_COMMENT
				{
					fprintf(yyout, "single_line_comment\n");
					while(getc(yyin)!='\n');			
				}
;


%%


void yyerror(const char* message)
{
        insertSyntaxError("yyerror",message, yylineno);
        return;
}


/* 
 * Function responsible for defining where the parser's input is going to come
 * from (a file or stdin) and where the parser's output is going to be printed
 * at (a file or stdin). It returns -1 on error, 0 when no
 * output file to be used as output , 1 when an input file is to be used as
 * yyin and 2 when both an input file and an output file are to be used as
 * yyin and yyout correspondingly.
 *
 */
int input_handler(int argc, char** argv)
{
        /* Pointer to the output file (We don't know if it exists yet) */
        FILE *outputFile = NULL;

	/* variable that is either 0 (neither input file, nor output file)
 	 * either 1 (an input file to be used as yyin), or 2 (both input and
 	 * output files) */
	int flag = 0;

        /* Checks if the user gave command line arguments */
        if (argc > 1)
        {
                /* Switch statement to check if the user gave 1 or 2 command line arguments */
                switch (argc)
                {
                        /* ONE C.L.A given, means that the user only gave the input file (output: stdout) */
                        case 2:
                                if (!(yyin = fopen(argv[1], "r")))
                                {
                                        /* error opening input file */
                                        fprintf(stderr, "\033[5:91mInput Error:\033[0m Cannot read file: %s\n", argv[1]);
                                        return -1;
                                }
				flag = 1;
                                break;
                        /* TWO C.L.As given, means that the user gave both input and output files */
                        case 3:

                                if (!(yyin = fopen(argv[1], "r")))
                                {
                                        /* error opening input file */
                                        fprintf(stderr, "\033[5:91mInput Error:\033[0m Cannot read file: %s\n", argv[1]);
                                        return -1;
                                }
                                if (!(outputFile = fopen(argv[2], "w")))
                                {
                                        /* error opening output file */
                                        fprintf(stderr, "\033[5:91mOutput Error:\033[0m Cannot write to file: %s\n", argv[2]);
                                        return -1;
                                }
				flag = 2;
                                yyout = outputFile;     // Redirect output to file
                                break;

                        /* INVALID number of C.L.As given (Error)*/
                        default:
                                fprintf(stderr, "\033[5:91mInput Error:\033[0m Unacceptable number of command-line arguments!\n");
                                return -1;
                }
        }
        /* If the user didn't give any, main reads the input directly from the command line*/
        else
        {
                yyin = stdin;
                yyout = stdout;
        }

	if(flag == 0)
	{
		return 0;
	}
	else if(flag == 1)
	{
		return 1;
	}
	else
	{
		return 2;
	}
}


/*
 * ---------- MAIN FUNCTION ----------
 * This is the main function of the program
 *  - First main handdles the command line arguments
 *    given by the user.
 *  - Then it calles 2 functions
 *      a) The first initializes the hash table
 *      b) The second fills up scope 0 with the Library functions
 *  - Then yyparse is called for the parsing
 *  - If the parsing happens correctly assuming that there is no error
 *    main checks if we are in score 0
 *  - If we still aren't in scope 0, it means that the user didn't close
 *    the function block properly so i add one more error on the
 *    syntax error single linked list
 *  - After that, i print the entire Syntax error list
 *  - Finally, i print the hash table and return 0
*/
int main(int argc, char* argv[])
{
        if(input_handler(argc, argv) == -1)
                return -1;

        initializeTable();
        initializeLibFunc();

        yyparse();

        if (scope != 0)
                insertSyntaxError("-", "Missing }", yylineno);

        printf("\n");
        SyntaxErrorsPrint();
        printf("\n");
        SymbolTablePrint();
        printf("\n");

        return 0;
}
