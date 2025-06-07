%{
        /* Definitions */
	#include "SymTable.h"
	#include "parser.h"

	#define RE_STR "<-char*"
	#define RE_ENUM	 "<-enumerated"
	
	char* str_GCheck(char*);	

	int commentDepth = 0;
	int originalLine = 0;
	int nestedCommentOriginalLine[256];
%}

%option noyywrap
%option yylineno
%x BLOCK_COMMENT

/* Identifiers */
IDENTIFIER      [a-zA-Z][a-zA-Z_0-9]*

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
PLUS "+"
MINUS "-"
MUL "*"
DIV "/"
MOD "%"
NOT_EQUAL "!="
PLUS_PLUS "++"
MINUS_MINUS "--"
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

{IF}            {return IF;}
{ELSE}          {return ELSE;}
{WHILE}         {return WHILE;}
{FOR}           {return FOR;}
{FUNCTION}      {return FUNCTION;}
{RETURN}        {return RETURN;}
{BREAK}         {return BREAK;}
{CONTINUE}      {return CONTINUE;}
{AND}           {return AND;}
{NOT}           {return NOT;}
{OR}            {return OR;}
{LOCAL}         {return LOCAL;}
{TRUE}          {return TRUE;}
{FALSE}         {return FALSE;}
{NIL}           {return NIL;}

{EQUAL}         {return EQUAL;}
{ASSIGN}        {return ASSIGN;}
{PLUS}          {return PLUS;}
{MINUS}         {return MINUS;}
{MUL}           {return MUL;}

{DIV}           { 
			if(!(getc(yyin) == '/'))
				return DIV;
			else SINGLE_LINE_COMMENT;
		}

{MOD}        	{return MOD;}
{NOT_EQUAL}     {return NOT_EQUAL;}
{PLUS_PLUS}     {return PLUS_PLUS;}
{MINUS_MINUS}   {return MINUS_MINUS;}
{GREATER}       {return GREATER;}
{LESS}          {return LESS;}
{GREATER_EQUAL} {return GREATER_EQUAL;}
{LESS_EQUAL}    {return LESS_EQUAL;}   


{BLOCK_COMMENT_START}   {
                                commentDepth = 1;
                                BEGIN(BLOCK_COMMENT);
                                originalLine = yylineno;
                        }

{BLOCK_COMMENT_END}     {
                                fprintf(stderr, "\033[5:91mLexical Error:\033[0m Comment ended before it started at line %d\n", yylineno);
                        	exit(1);
			}

<BLOCK_COMMENT>{BLOCK_COMMENT_START}    {
                                                nestedCommentOriginalLine[commentDepth] = yylineno;
                                                if(commentDepth > 256)
						{
                                                        fprintf(stderr, "\033[5:91mLexical Error:\033[0m Nested comment limit exceeded\n");
                                             		exit(1);
						}
						commentDepth++;
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

{LEFT_CURLY_BRACKET}    {return LEFT_CURLY_BRACKET;}
{RIGHT_CURLY_BRACKET}   {return RIGHT_CURLY_BRACKET;}
{LEFT_SQUARE_BRACKET}   {return LEFT_SQUARE_BRACKET;}
{RIGHT_SQUARE_BRACKET}  {return RIGHT_SQUARE_BRACKET;}
{LEFT_PARENTHESIS}      {return LEFT_PARENTHESIS;}
{RIGHT_PARENTHESIS}     {return RIGHT_PARENTHESIS;}
{SEMICOLON}             {return SEMICOLON;}
{COMMA}                 {return COMMA;}
{COLON}                 {return COLON;}
{DOUBLE_COLON}          {return DOUBLE_COLON;}
{DOT}                   {return DOT;}
{DOUBLE_DOT}            {return DOUBLE_DOT;}

{IDENTIFIER}       	{ yylval.strVal = strdup(yytext); return IDENTIFIER;}
{INTEGER}     		{ yylval.intVal = atoi(yytext); return INTEGER;}
{REAL}        		{ yylval.realVal = atof(yytext); return REAL;}
{STRING}      		{ yylval.strVal = str_GCheck(yytext); return STRING;}
{UNTERMINATED_STRING}   { fprintf(stderr, "\033[5;91mLexical Error:\033[0m Unterminated string at line %d\n", yylineno); exit(1);}
{WHITESPACE}		{ /* Ignores the whitespaces */  }
{NEWLINE}		{ /* Ignores the newlines */     }
.			{ /* Ingnores everything else */ }
<<EOF>>                 { return -1;}

%%

char* str_GCheck(char *str)
{
	if(!str)
	{
		fprintf(stderr, "\033[5:91mFatal Error:\033[0m Lexer could pass yytext correctly\n");
		exit(1);
	}

	int len = strlen(str), j = 0;
	
	char* newStr = (char *)malloc((len+1) * sizeof(char));
	if(!newStr)
	{
		fprintf(stderr, "Error: Memory allocation (malloc) for char* newStr failed!\nProgram terminated with exit code -1\n\n");
		exit(-1);
	}


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
	
	return newStr; 
}
