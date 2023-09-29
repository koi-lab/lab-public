OBJECTS = language.tab.o lex.yy.o array.o symbol.o error.o instruction.o tree.o main.o 
SOURCES = language.tab.c lex.yy.c array.c symbol.c error.c instruction.c tree.c main.c 
EXE = infix2postfix
CFLAGS += -Wall -g -lm

$(EXE):	$(OBJECTS)
	gcc -o $(EXE) $(OBJECTS) $(CFLAGS)

lex.yy.c: language.l
	flex language.l

language.tab.c language.tab.h: language.y
	bison -d language.y

main.o: main.c
	gcc $(CFLAGS) -c main.c 

tree.o: tree.c symbol.c array.c
	gcc $(CFLAGS) -c tree.c

array.o: array.h
	gcc $(CFLAGS) -c array.c

symbol.o: symbol.c error.c
	gcc $(CFLAGS) -c symbol.c

error.o: error.c
	gcc $(CFLAGS) -c error.c

instruction.o: instruction.c
	gcc $(CFLAGS) -c instruction.c

clean: 
	rm -f $(EXE) $(OBJECTS) 29.tar.gz 29.zip *~ lex.yy.c language.tab.c language.tab.h

archives: clean
	cd ..; rm 29.tar 29.zip 29/29.tar 29/29.zip; tar -cvf 29.tar 29; gzip -9 29.tar; zip -r 29.zip 29; mv 29.zip 29/29.zip; mv 29.tar.gz 29/29.tar.gz
