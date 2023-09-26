OBJECTS = language.tab.o lex.yy.o symbol.o error.o main.o 
SOURCES = language.tab.c lex.yy.c symbol.c error.c main.c 
EXE = infix2postfix
CFLAGS += -Wall -g -lm

$(EXE):	$(OBJECTS)
	gcc -o $(EXE) $(OBJECTS) $(CFLAGS)

lex.yy.c: language.l
	flex language.l

language.tab.c language.tab.h: language.y
	bison -d language.y

main.o: 	main.c global.h
	gcc $(CFLAGS) -c main.c 

symbol.o: 	symbol.c global.h
	gcc $(CFLAGS) -c symbol.c

error.o: 	error.c global.h
	gcc $(CFLAGS) -c error.c

clean: 
	rm -f $(EXE) $(OBJECTS) 29.tar.gz 29.zip *~

archives: clean
	cd ..; rm 29.tar 29.zip 29/29.tar 29/29.zip; tar -cvf 29.tar 29; gzip -9 29.tar; zip -r 29.zip 29; mv 29.zip 29/29.zip; mv 29.tar.gz 29/29.tar.gz
