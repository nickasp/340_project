###################################################
#
# file: Makefile
#
# @Author:   Christos Polimatidis
# @Version:  28-02-2024
# @email:    csd5209@csd.uoc.gr
#
# Makefile
#
####################################################

# Compiler and flags
LEX=lex
CC=gcc
CFLAGS=-ll   # Link with Lex library

# Files
LEX_FILE=al.l
C_FILE=al.c
EXECUTABLE=al

# Default rule: build everything
all: $(EXECUTABLE)

# Generate the lexer source file
$(C_FILE): $(LEX_FILE)
	$(LEX) -o $(C_FILE) $(LEX_FILE)

# Compile the lexer
$(EXECUTABLE): $(C_FILE)
	$(CC) $(C_FILE) -o $(EXECUTABLE) $(CFLAGS)

# Run the lexer with an optional input file
run: $(EXECUTABLE)
	./$(EXECUTABLE)

# Clean generated files
clean:
	rm -f $(C_FILE) $(EXECUTABLE) output.txt

