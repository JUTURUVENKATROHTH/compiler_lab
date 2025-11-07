CC = gcc

Lex_file = calculator.l
Yacc_file = hoc.y
Yacc_c_file = y.tab.c
Yacc_header_file = y.tab.h
Lex_c_file = lex.yy.c
Executable = result

all: $(Executable)

$(Executable):$(Yacc_c_file) $(Lex_c_file)
	$(CC) -g -o $(Executable) $(Yacc_c_file) $(Lex_c_file) -w
$(Yacc_c_file):
	yacc -d $(Yacc_file)
$(Lex_c_file):
	lex $(Lex_file)

run:$(Executable)
	./$(Executable)

clean:
	rm -f $(Executable) $(Yacc_c_file) $(Lex_c_file) $(Yacc_header_file)

