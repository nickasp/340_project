###################################################
#
# file: Makefile
#
# @Version:  01-04-2025
# 
# Makefile
#
####################################################

# Compiler and flags
LEX=lex
YACC=bison
CC=gcc

# LEX Files
LEX_FILE=al.l
LEX_C=al.c

# YACC Files
YACC_FILE=parser.y
YACC_C=parser.c
YACC_H=parser.h	# .h library automatically generated when yacc .c file is generated
YACC_EXEC=parser
BSFLAGS=-d -Wno-conflicts-sr # flags for bison

# Default rule: build everything
all: $(YACC_EXEC)

# Generate final executable (our parser)
$(YACC_EXEC): $(LEX_C) $(YACC_C)
	$(CC) -o $(YACC_EXEC) $(LEX_C) $(YACC_C) SymTable.c

# Generate the parser .c source file
$(YACC_C): $(YACC_FILE)
	$(YACC) $(BSFLAGS) -o $(YACC_C) $(YACC_FILE)

# Generate the lexer .c source file
$(LEX_C): $(LEX_FILE)
	$(LEX) -o $(LEX_C) $(LEX_FILE)

# Run the lexer with an optional input file
run: $(YACC_EXEC)
	./$(YACC_EXEC)

# Clean generated files
clean:
	rm -f $(YACC_EXEC) $(YACC_C) $(YACC_H) $(LEX_C) output.txt 

