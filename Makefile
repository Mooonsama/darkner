CC      = gcc
CFLAGS  = -Wall -std=gnu99
ALVO    = darkner

all: $(ALVO)

parser.tab.c parser.tab.h: parser.y
	bison -d -Wall parser.y

lex.yy.c: lexer.l parser.tab.h
	flex lexer.l

$(ALVO): parser.tab.c lex.yy.c
	$(CC) $(CFLAGS) -o $(ALVO) parser.tab.c lex.yy.c

test: $(ALVO)
	./run_tests.sh

clean:
	rm -f $(ALVO) parser.tab.c parser.tab.h lex.yy.c parser.output

.PHONY: all test clean
