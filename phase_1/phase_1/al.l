%{
        /* Definitions */
        #include <stdio.h>
        #include <stdlib.h>
        #include <string.h>

	#define RE_STR "<-char*"
	#define RE_ENUM	 "<-enumerated"
	#define YY_DECL int alpha_yylex(void* yylval)

        void printTokens(void);
	
        struct alpha_token_t {
                unsigned int numline;
                unsigned int numToken;
                char *content;
		char *gen_type;
                char *spec_type;
		char *representation;
                struct alpha_token_t *next;
        };
	
	int addNewToken(struct alpha_token_t* ,int, int, char*,char*,char*,char*);
	void str_GCheck(struct alpha_token_t* , char*);	

        struct alpha_token_t *GP = NULL;
        struct alpha_token_t *last = NULL;

        int tokenCounter = 0;
	int commentDepth = 0;
	int originalLine = 0;
	int nestedCommentOriginalLine[256];
%}

%option noyywrap
%option yylineno
%x BLOCK_COMMENT

/* Identifiers */
IDENT           [a-zA-Z][a-zA-Z_0-9]*

/* Numbers */
INTEGER         (0[xX][0-9a-fA-F]+)|([0-9]+)
REAL            [0-9]+\.[0-9]+(e|E)?[0-9]*

/* Strings */
STRING 			\"([^\\\"\n]|\\.)*\"
UNTERMINATED_STRING	\"(\\.|[^\"\n])*

/* Comments */
SINGLE_LINE_COMMENT     "//".*
BLOCK_COMMENT_START	"/*"
BLOCK_COMMENT_END	"*/"

/* Whitespace */
WHITESPACE	"[ \t\r]+"
NEWLINE		"\n"

/* Keywords */
IF	"if"
ELSE	"else"
WHILE	"while"
FOR 	"for"
FUNCTION	"function"
RETURN	"return"
BREAK 	"break"
CONTINUE	"continue"
AND	"and"
NOT	"not"
OR	"or"
LOCAL	"local"
TRUE	"true"
FALSE	"false"
NIL	"nil"

/* Operators */
EQUAL "=="
ASSIGN "="
ADD "+"
SUBTRACT "-"
MULTIPLY "*"
DIVIDE "/"
MODULO "%"
NOT_EQUAL "!="
INCREMENT "++"
DECREMENT "--"
GREATER ">"
LESS "<"
GREATER_EQUAL ">="
LESS_EQUAL "<="

/* Punctuation */
LEFT_CURLY_BRACKET "{"
RIGHT_CURLY_BRACKET "}"
LEFT_SQUARE_BRACKET "["
RIGHT_SQUARE_BRACKET "]"
LEFT_PARENTHESIS "("
RIGHT_PARENTHESIS ")"
SEMICOLON ";"
COMMA ","
COLON ":"
DOUBLE_COLON "::"
DOT "."
DOUBLE_DOT ".."

%%

<<<<<<< HEAD
{SINGLE_LINE_COMMENT}	{ addNewToken(yylval, yylineno, ++tokenCounter, "-", "COMMENT", "SINGLE_LINE_COMMENT", RE_ENUM); }

{IF}            { addNewToken(yylval, yylineno, ++tokenCounter, yytext, "KEYWORD", "IF", RE_ENUM); }
{ELSE}          { addNewToken(yylval, yylineno, ++tokenCounter, yytext, "KEYWORD", "ELSE", RE_ENUM); }
{WHILE}         { addNewToken(yylval, yylineno, ++tokenCounter, yytext, "KEYWORD", "WHILE", RE_ENUM); }
{FOR}           { addNewToken(yylval, yylineno, ++tokenCounter, yytext, "KEYWORD", "FOR", RE_ENUM); }
{FUNCTION}      { addNewToken(yylval, yylineno, ++tokenCounter, yytext, "KEYWORD", "FUNCTION", RE_ENUM); }
{RETURN}        { addNewToken(yylval, yylineno, ++tokenCounter, yytext, "KEYWORD", "RETURN", RE_ENUM); }
{BREAK}         { addNewToken(yylval, yylineno, ++tokenCounter, yytext, "KEYWORD", "BREAK", RE_ENUM); }
{CONTINUE}      { addNewToken(yylval, yylineno, ++tokenCounter, yytext, "KEYWORD", "CONTINUE", RE_ENUM); }
{AND}           { addNewToken(yylval, yylineno, ++tokenCounter, yytext, "KEYWORD", "AND", RE_ENUM); }
{NOT}           { addNewToken(yylval, yylineno, ++tokenCounter, yytext, "KEYWORD", "NOT", RE_ENUM); }
{OR}            { addNewToken(yylval, yylineno, ++tokenCounter, yytext, "KEYWORD", "OR", RE_ENUM); }
{LOCAL}         { addNewToken(yylval, yylineno, ++tokenCounter, yytext, "KEYWORD", "LOCAL", RE_ENUM); }
{TRUE}          { addNewToken(yylval, yylineno, ++tokenCounter, yytext, "KEYWORD", "TRUE", RE_ENUM); }
{FALSE}         { addNewToken(yylval, yylineno, ++tokenCounter, yytext, "KEYWORD", "FALSE", RE_ENUM); }
{NIL}           { addNewToken(yylval, yylineno, ++tokenCounter, yytext, "KEYWORD", "NIL", RE_ENUM); }

{EQUAL}         { addNewToken(yylval, yylineno, ++tokenCounter, yytext, "OPERATOR", "EQUAL", RE_ENUM); }
{ASSIGN}        { addNewToken(yylval, yylineno, ++tokenCounter, yytext, "OPERATOR", "ASSIGN", RE_ENUM); }
{ADD}           { addNewToken(yylval, yylineno, ++tokenCounter, yytext, "OPERATOR", "PLUS", RE_ENUM); }
{SUBTRACT}      { addNewToken(yylval, yylineno, ++tokenCounter, yytext, "OPERATOR", "SUBTRACT", RE_ENUM); }
{MULTIPLY}      { addNewToken(yylval, yylineno, ++tokenCounter, yytext, "OPERATOR", "MULTIPLY", RE_ENUM); }
{DIVIDE}        { addNewToken(yylval, yylineno, ++tokenCounter, yytext, "OPERATOR", "DIVIDE", RE_ENUM); }
{MODULO}        { addNewToken(yylval, yylineno, ++tokenCounter, yytext, "OPERATOR", "MODULO", RE_ENUM); }
{NOT_EQUAL}     { addNewToken(yylval, yylineno, ++tokenCounter, yytext, "OPERATOR", "NOT_EQUAL", RE_ENUM); }
{INCREMENT}     { addNewToken(yylval, yylineno, ++tokenCounter, yytext, "OPERATOR", "INCREMENT", RE_ENUM); }
{DECREMENT}     { addNewToken(yylval, yylineno, ++tokenCounter, yytext, "OPERATOR", "DECREMENT", RE_ENUM); }
{GREATER}       { addNewToken(yylval, yylineno, ++tokenCounter, yytext, "OPERATOR", "GREATER", RE_ENUM); }
{LESS}          { addNewToken(yylval, yylineno, ++tokenCounter, yytext, "OPERATOR", "LESS", RE_ENUM); }
{GREATER_EQUAL} { addNewToken(yylval, yylineno, ++tokenCounter, yytext, "OPERATOR", "GREATER_EQUAL", RE_ENUM); }
{LESS_EQUAL}    { addNewToken(yylval, yylineno, ++tokenCounter, yytext, "OPERATOR", "LESS_EQUAL", RE_ENUM); }   
=======
{SINGLE_LINE_COMMENT}	{ addNewToken(yylineno, ++tokenCounter, "-", "COMMENT", "SINGLE_LINE_COMMENT", RE_ENUM); }

{IF}            { addNewToken(yylineno, ++tokenCounter, yytext, "KEYWORD", "IF", RE_ENUM); }
{ELSE}          { addNewToken(yylineno, ++tokenCounter, yytext, "KEYWORD", "ELSE", RE_ENUM); }
{WHILE}         { addNewToken(yylineno, ++tokenCounter, yytext, "KEYWORD", "WHILE", RE_ENUM); }
{FOR}           { addNewToken(yylineno, ++tokenCounter, yytext, "KEYWORD", "FOR", RE_ENUM); }
{FUNCTION}      { addNewToken(yylineno, ++tokenCounter, yytext, "KEYWORD", "FUNCTION", RE_ENUM); }
{RETURN}        { addNewToken(yylineno, ++tokenCounter, yytext, "KEYWORD", "RETURN", RE_ENUM); }
{BREAK}         { addNewToken(yylineno, ++tokenCounter, yytext, "KEYWORD", "BREAK", RE_ENUM); }
{CONTINUE}      { addNewToken(yylineno, ++tokenCounter, yytext, "KEYWORD", "CONTINUE", RE_ENUM); }
{AND}           { addNewToken(yylineno, ++tokenCounter, yytext, "KEYWORD", "AND", RE_ENUM); }
{NOT}           { addNewToken(yylineno, ++tokenCounter, yytext, "KEYWORD", "NOT", RE_ENUM); }
{OR}            { addNewToken(yylineno, ++tokenCounter, yytext, "KEYWORD", "OR", RE_ENUM); }
{LOCAL}         { addNewToken(yylineno, ++tokenCounter, yytext, "KEYWORD", "LOCAL", RE_ENUM); }
{TRUE}          { addNewToken(yylineno, ++tokenCounter, yytext, "KEYWORD", "TRUE", RE_ENUM); }
{FALSE}         { addNewToken(yylineno, ++tokenCounter, yytext, "KEYWORD", "FALSE", RE_ENUM); }
{NIL}           { addNewToken(yylineno, ++tokenCounter, yytext, "KEYWORD", "NIL", RE_ENUM); }

{EQUAL}         { addNewToken(yylineno, ++tokenCounter, yytext, "OPERATOR", "EQUAL", RE_ENUM); }
{ASSIGN}        { addNewToken(yylineno, ++tokenCounter, yytext, "OPERATOR", "ASSIGN", RE_ENUM); }
{ADD}           { addNewToken(yylineno, ++tokenCounter, yytext, "OPERATOR", "PLUS", RE_ENUM); }
{SUBTRACT}      { addNewToken(yylineno, ++tokenCounter, yytext, "OPERATOR", "SUBTRACT", RE_ENUM); }
{MULTIPLY}      { addNewToken(yylineno, ++tokenCounter, yytext, "OPERATOR", "MULTIPLY", RE_ENUM); }
{DIVIDE}        { addNewToken(yylineno, ++tokenCounter, yytext, "OPERATOR", "DIVIDE", RE_ENUM); }
{MODULO}        { addNewToken(yylineno, ++tokenCounter, yytext, "OPERATOR", "MODULO", RE_ENUM); }
{NOT_EQUAL}     { addNewToken(yylineno, ++tokenCounter, yytext, "OPERATOR", "NOT_EQUAL", RE_ENUM); }
{INCREMENT}     { addNewToken(yylineno, ++tokenCounter, yytext, "OPERATOR", "INCREMENT", RE_ENUM); }
{DECREMENT}     { addNewToken(yylineno, ++tokenCounter, yytext, "OPERATOR", "DECREMENT", RE_ENUM); }
{GREATER}       { addNewToken(yylineno, ++tokenCounter, yytext, "OPERATOR", "GREATER", RE_ENUM); }
{LESS}          { addNewToken(yylineno, ++tokenCounter, yytext, "OPERATOR", "LESS", RE_ENUM); }
{GREATER_EQUAL} { addNewToken(yylineno, ++tokenCounter, yytext, "OPERATOR", "GREATER_EQUAL", RE_ENUM); }
{LESS_EQUAL}    { addNewToken(yylineno, ++tokenCounter, yytext, "OPERATOR", "LESS_EQUAL", RE_ENUM); }   
>>>>>>> 7794fd8817fd669b763f5a6ecfe7ee6ef543d163

{BLOCK_COMMENT_START}   {
                                commentDepth = 1;
                                BEGIN(BLOCK_COMMENT);
                                originalLine = yylineno;
                        }

/* if "BLOCK_COMMENT_END" regex is encountered and program is at the default
 * (<INITIAL>) state, the following action code (starting at line 188) will be executed. 
 * Instead, if program is at <BLOCK_COMMENT> state and a "BLOCK_COMMENT_END" regex is
 * encountered, action code starting at line 203 will be executed. */

{BLOCK_COMMENT_END}     {
                                fprintf(stderr, "\033[5:91mLexical Error:\033[0m Comment ended before it started at line %d\n", yylineno);
                                exit(1);
                        }

/* nested /*...*\/ comments are supported */  

<BLOCK_COMMENT>{BLOCK_COMMENT_START}    {
						
						/* lineno for the first nested comment will be stored at index 1 					    						     * position of nestedCommentOriginalLine array */
						if(commentDepth >= 256)
						{
							fprintf(stderr, "\033[5:91mLexical Error:\033[0m Nested comment limit exceeded\n");
							exit(1);
						}

						nestedCommentOriginalLine[commentDepth] = yylineno;
						commentDepth++;

						
						
					/*	nestedCommentOriginalLine[commentDepth] = yylineno; 
                                                if(commentDepth > 256)
                                                {
                                                        fprintf(stderr, "\033[5:91mLexical Error:\033[0m Nested comment limit exceeded\n");
                                                        exit(1);
                                                }
                                                commentDepth++;
					*/					

                                        }

<BLOCK_COMMENT>{BLOCK_COMMENT_END}      {
                                                if (commentDepth == 1)
                                                {
                                                        commentDepth--;
                                                        char start_line[32], end_line[32], lines[32];
                                                        lines[0] = '\0';
                                                        snprintf(start_line, 32, "%d", originalLine);
                                                        snprintf(end_line, 32, "%d", yylineno);
                                                        strcat(lines, start_line);
                                                        strcat(lines, " - ");
                                                        strcat(lines, end_line);
                                                        addNewToken(yylval, yylineno, ++tokenCounter, lines, "COMMENT", "BLOCK_COMMENT", RE_ENUM);
                                                        BEGIN(INITIAL);
                                                }
                                                if(commentDepth > 1)
                                                {
                                                        commentDepth--;
                                                        char start_line[32], end_line[32], lines[32];
                                                        lines[0] = '\0';
                                                        snprintf(start_line, 32, "%d", nestedCommentOriginalLine[commentDepth]);
                                                        snprintf(end_line, 32, "%d", yylineno);
                                                        strcat(lines, start_line);
                                                        strcat(lines, " - ");
                                                        strcat(lines, end_line);
                                                        nestedCommentOriginalLine[commentDepth] = 0;
                                                        addNewToken(yylval, yylineno, ++tokenCounter, lines, "COMMENT", "NESTED_BLOCK_COMMENT", RE_ENUM);
                                                }
                                        }

<BLOCK_COMMENT>.|\n     { /* Ignore such characters */ }

<BLOCK_COMMENT><<EOF>>  {
				if (commentDepth == 1)
				{ 
                                	fprintf(stderr, "\033[5;91mLexical Error:\033[0m Unterminated block comment starting at line %d\n", originalLine);
                                	exit(1);		
				}
				else
				{
					fprintf(stderr, "\033[5;91mLexical Error:\033[0m Unterminated nested block comment starting at line %d\n", nestedCommentOriginalLine[commentDepth - 1]);
					exit(1);
				}
                        }

{LEFT_CURLY_BRACKET}    { addNewToken(yylval, yylineno, ++tokenCounter, yytext, "PUNCTUATION", "LEFT_CURLY_BRACKET", RE_ENUM); }
{RIGHT_CURLY_BRACKET}   { addNewToken(yylval, yylineno, ++tokenCounter, yytext, "PUNCTUATION", "RIGHT_CURLY_BRACKET", RE_ENUM); }
{LEFT_SQUARE_BRACKET}   { addNewToken(yylval, yylineno, ++tokenCounter, yytext, "PUNCTUATION", "LEFT_SQUARE_BRACKET", RE_ENUM); }
{RIGHT_SQUARE_BRACKET}  { addNewToken(yylval, yylineno, ++tokenCounter, yytext, "PUNCTUATION", "RIGHT_SQUARE_BRACKET", RE_ENUM); }
{LEFT_PARENTHESIS}      { addNewToken(yylval, yylineno, ++tokenCounter, yytext, "PUNCTUATION", "LEFT_PARENTHESIS", RE_ENUM); }
{RIGHT_PARENTHESIS}     { addNewToken(yylval, yylineno, ++tokenCounter, yytext, "PUNCTUATION", "RIGHT_PARENTHESIS", RE_ENUM); }
{SEMICOLON}             { addNewToken(yylval, yylineno, ++tokenCounter, yytext, "PUNCTUATION", "SEMICOLON", RE_ENUM); }
{COMMA}                 { addNewToken(yylval, yylineno, ++tokenCounter, yytext, "PUNCTUATION", "COMMA", RE_ENUM); }
{COLON}                 { addNewToken(yylval, yylineno, ++tokenCounter, yytext, "PUNCTUATION", "COLON", RE_ENUM); }
{DOUBLE_COLON}          { addNewToken(yylval, yylineno, ++tokenCounter, yytext, "PUNCTUATION", "DOUBLE_COLON", RE_ENUM); }
{DOT}                   { addNewToken(yylval, yylineno, ++tokenCounter, yytext, "PUNCTUATION", "DOT", RE_ENUM); }
{DOUBLE_DOT}            { addNewToken(yylval, yylineno, ++tokenCounter, yytext, "PUNCTUATION", "DOUBLE_DOT", RE_ENUM); }

{IDENT}       		{ addNewToken(yylval, yylineno, ++tokenCounter, yytext, "IDENT", yytext, RE_STR); }
{INTEGER}     		{ addNewToken(yylval, yylineno, ++tokenCounter, yytext, "INTCONST", yytext, "<-integer"); }
{REAL}        		{ addNewToken(yylval, yylineno, ++tokenCounter, yytext, "REALCONST", yytext, "<-real"); }
{STRING}      		{ str_GCheck(yylval, yytext); }
{UNTERMINATED_STRING}   { fprintf(stderr, "\033[5;91mLexical Error:\033[0m Unterminated string at line %d\n", yylineno); exit(1); }
{WHITESPACE}		{ addNewToken(yylval, yylineno, ++tokenCounter, yytext, "WHITESPACE", yytext, "<-space"); }
{NEWLINE}		{ /* Ignores the newlines */ }
.			{ /* Ingnores everything else */ }
<<EOF>>                 { return 1;}

%%

void str_GCheck(struct alpha_token_t *yylval, char *str)
{
	if(!str)
	{
		fprintf(stderr, "\033[5:91mFatal Error:\033[0m Lexer could not pass yytext correctly\n");
		exit(1);
	}

	int len = strlen(str), j = 0;
	char newStr[len+1];

	for(int i=0; i <= len; i++)
	{
		if(str[i] != '\\')
			newStr[j] = str[i];
		else
		{
			i++;
			switch(str[i])
			{
				case 'n':
					newStr[j] = '\n';
					break;
				case 't':
					newStr[j] = '\t';
					break;
				case 'b':
					newStr[j] = '\b';
					break;
				case '\\':
					newStr[j] = '\\';
					break;
				case '\'':
					newStr[j] = '\'';
					break;
				case '\"': 
					newStr[j] = '\"';
					break;
				default:
                    			fprintf(stderr, "\033[5;94mLexical Warning:\033[0m Unknown escape sequence \\%c at line %d\n", str[i], yylineno);
					newStr[j++] = '\\';
					newStr[j++] = str[i];
					j--;
                    			break;
			}
		}
		j++;
	}

	newStr[j] = '\0';	// Null terminates the string

	addNewToken(yylval, yylineno, ++tokenCounter, newStr, "STRING", newStr, RE_STR);	// Adds the token to the string
}

/* Function to Add a New Token */
int addNewToken(struct alpha_token_t *newToken, int numline, int numToken, char content[], char gen_type[], char spec_type[], char representation[]) 
{
       	newToken=malloc(sizeof(struct alpha_token_t)); 
        if (!newToken) 
	{
                fprintf(stderr, "\033[5:91mFatal Error:\033[5:91mLexer couldn't allocate memory for the token at line %d\n",yylineno);
                return 1;
        }

        newToken->numline = numline;
        newToken->numToken = numToken;
        newToken->content = strdup(content);
        newToken->gen_type = strdup(gen_type);
	newToken->spec_type = strdup(spec_type);
	newToken->representation = strdup(representation);
        newToken->next = NULL;

        if (GP == NULL) {
                GP = newToken;
                last = newToken;
        } else {
                last->next = newToken;
                last = newToken;
        }

        return 0;
}

/* Function to Print All Tokens */
void printTokens() 
{
        struct alpha_token_t *current = GP;
        while (current != NULL) {
		printf("%-8d #%-8d %-12s %-15s %-18s %s\n",
       			current->numline, current->numToken, current->content,
       			current->gen_type, current->spec_type, current->representation);        	
                current = current->next;
        }
}

/* Main function and additional C code */
int main(int argc, char* argv[]) 
{
    	// Pointer to the output file (We don't know if it exists yet)
    	FILE *outputFile = NULL;

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
                		yyout = outputFile;	// Redirect output to file
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
    	}

    	/* Execute the lexer */
    	while (1)
    	{
        	struct alpha_token_t *curr = malloc(sizeof(struct alpha_token_t));
        	if (!curr)
        	{
            		fprintf(stderr, "\033[5:91mFatal Error:\033[0m Lexer couldn't allocate memory for the token at line %d\n",yylineno);
            		break;
        	}

        	int token = alpha_yylex(NULL);
        	if (token == 1)  /* CTRL + D = EOF */
        	{
            		free(curr);
            		break;
        	}
    	}
   
    	printTokens();

    	if (outputFile) 
        	fclose(outputFile);

    	return 0;
}
