CC=gcc

install: ctts.l ctts.y
	flex ctts.l
	yacc -d -v ctts.y
	$(CC) -o ctts y.tab.c

.PHONY: clean

clean:
	rm ctts y.output y.tab.c y.tab.h lex.yy.c
