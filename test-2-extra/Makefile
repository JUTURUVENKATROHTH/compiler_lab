all:
	yacc -d src/compiler.y
	lex src/compiler.l
	mkdir -p bin
	gcc -I./include lex.yy.c y.tab.c src/AST.c -o bin/compiler -lm -w

clean:
	rm -rf *.tab.c *.yy.c *.tab.[hc] bin/*