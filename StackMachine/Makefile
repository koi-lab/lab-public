OFILES = test.o StackMachine.o
CPPFLAGS = -g -Wall

test: $(OFILES)
	g++ $(CPPFLAGS) -o test $(OFILES)

StackMachine.o: StackMachine.h
test.o: StackMachine.h

clean:
	$(RM) $(OFILES) test

archives: clean
	cd ..; \
	$(RM) StackMachine.tar StackMachine.tar.gz StackMachine.zip StackMachine-2018/StackMachine.tar StackMachine-2018/StackMachine.tar.gz StackMachine-2018/StackMachine.zip; \
	tar -cvf StackMachine.tar StackMachine-2018; \
	gzip -9 StackMachine.tar; \
	zip -r StackMachine.zip StackMachine-2018; \
	mv StackMachine.zip StackMachine-2018/StackMachine.zip; \
	mv StackMachine.tar.gz StackMachine-2018/StackMachine.tar.gz
