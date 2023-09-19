OBJECTS = language.tab.o stack.o lexer.o parser.o symbol.o init.o error.o main.o 
SOURCES = language.tab.cpp stack.cpp lexer.cpp parser.cpp symbol.cpp init.cpp error.cpp main.cpp 
EXE = infix2postfix
CFLAGS += -Wall -g -lm

$(EXE):	$(OBJECTS)
	gcc -o $(EXE) $(OBJECTS) $(CFLAGS)

language.tab.cpp language.tab.hpp: language.ypp
	bison -d language.ypp

main.o: 	main.cpp global.h
	gcc $(CFLAGS) -c main.cpp 

lexer.o: 	lexer.cpp global.h
	gcc $(CFLAGS) -c lexer.cpp

parser.o: 	parser.cpp global.h
	gcc $(CFLAGS) -c parser.cpp

symbol.o: 	symbol.cpp global.h
	gcc $(CFLAGS) -c symbol.cpp

init.o: 	init.cpp global.h
	gcc $(CFLAGS) -c init.cpp

error.o: 	error.cpp global.h
	gcc $(CFLAGS) -c error.cpp

stack.o: 	stack.cpp global.h
	gcc $(CFLAGS) -c stack.cpp

clean: 
	rm -f $(EXE) $(OBJECTS) 29.tar.gz 29.zip *~

archives: clean
	cd ..; rm 29.tar 29.zip 29/29.tar 29/29.zip; tar -cvf 29.tar 29; gzip -9 29.tar; zip -r 29.zip 29; mv 29.zip 29/29.zip; mv 29.tar.gz 29/29.tar.gz
