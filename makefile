yacc: lex.yy.c y.tab.c
	gcc -o sintatico lex.yy.c y.tab.c -lfl

lex.yy.c:
	flex lexico.l

y.tab.c:
	yacc -d sintatico.y

clean:
	rm -rf lex.yy.c y.tab.c y.tab.h sintatico
