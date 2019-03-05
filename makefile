all: assembly test1 test2 test3 test4 test5 

assembly: a.out
	./a.out 1 > ass6_16CS30033_quads1.out
	./a.out 2 > ass6_16CS30033_quads2.out
	./a.out 3 > ass6_16CS30033_quads3.out
	./a.out 4 > ass6_16CS30033_quads4.out
	./a.out 5 > ass6_16CS30033_quads5.out
	

a.out: lex.yy.o y.tab.o ass6_16CS30033_translator.o ass6_16CS30033_target_translator.o
	g++ lex.yy.o y.tab.o ass6_16CS30033_translator.o \
	ass6_16CS30033_target_translator.o -lfl -o a.out


ass6_16CS30033_target_translator.o: ass6_16CS30033_target_translator.cxx
	g++ -c ass6_16CS30033_target_translator.cxx

ass6_16CS30033_translator.o: ass6_16CS30033_translator.cxx ass6_16CS30033_translator.h
	g++ -c -std=c++0x  ass6_16CS30033_translator.h
	g++ -c -std=c++0x  ass6_16CS30033_translator.cxx


lex.yy.o: lex.yy.c
	g++ -c lex.yy.c

y.tab.o: y.tab.c
	g++ -c y.tab.c

lex.yy.c: ass6_16CS30033.l y.tab.h ass6_16CS30033_translator.h
	flex ass6_16CS30033.l

y.tab.c: ass6_16CS30033.y
	yacc -dtv ass6_16CS30033.y -W

y.tab.h: ass6_16CS30033.y
	yacc -dtv ass6_16CS30033.y -W
	
clean:
	rm ass6_16CS30033_1.s ass6_16CS30033_2.s  ass6_16CS30033_3.s  ass6_16CS30033_4.s  ass6_16CS30033_5.s ass6_16CS30033_translator.h.gch
	rm lex.yy.c y.tab.c y.tab.h lex.yy.o y.tab.o ass6_16CS30033_translator.o test1 test2 test3 test4 test5 y.output a.out ass6_16CS30033_target_translator.o libass2_16CS30033.a ass6_16CS30033_1.o ass2_16CS30033.o ass6_16CS30033_2.o ass6_16CS30033_3.o ass6_16CS30033_4.o ass6_16CS30033_5.o
	rm test1 ass6_16CS30033_1.o libass2_16CS30033.a ass2_16CS30033.o ass6_16CS30033_quads1.out ass6_16CS30033_quads2.out ass6_16CS30033_quads3.out ass6_16CS30033_quads4.out ass6_16CS30033_quads5.out	
	


test1: ass6_16CS30033_1.o libass2_16CS30033.a ass6_16CS30033_1.s
	gcc ass6_16CS30033_1.o -o test1 -L. -lass2_16CS30033

ass6_16CS30033_1.o: myl.h
	gcc -c ass6_16CS30033_1.s

test2: ass6_16CS30033_2.o libass2_16CS30033.a ass6_16CS30033_2.s
	gcc ass6_16CS30033_2.o -o test2 -L. -lass2_16CS30033
	
ass6_16CS30033_2.o: myl.h
	gcc -Wall -c ass6_16CS30033_2.s

test3: ass6_16CS30033_3.o libass2_16CS30033.a ass6_16CS30033_3.s
	gcc ass6_16CS30033_3.o -o test3 -L. -lass2_16CS30033
ass6_16CS30033_3.o: myl.h
	gcc -Wall -c ass6_16CS30033_3.s

test4: ass6_16CS30033_4.o libass2_16CS30033.a ass6_16CS30033_4.s
	gcc ass6_16CS30033_4.o -o test4 -L. -lass2_16CS30033
ass6_16CS30033_4.o: myl.h
	gcc -Wall -c ass6_16CS30033_4.s

test5: ass6_16CS30033_5.o libass2_16CS30033.a ass6_16CS30033_5.s
	gcc ass6_16CS30033_5.o -o test5 -L. -lass2_16CS30033
ass6_16CS30033_5.o: myl.h
	gcc -Wall -c ass6_16CS30033_5.s

libass2_16CS30033.a: ass2_16CS30033.o
	ar -rcs libass2_16CS30033.a ass2_16CS30033.o

ass2_16CS30033.o: ass2_16CS30033.c myl.h
	gcc -Wall -c ass2_16CS30033.c