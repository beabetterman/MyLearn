#需要顶头写，表示一个操作的开始，用次来直接区分不同操作的描述范围#本身是个注释符号
.PHONY: build
build: bin/learn_make
bin/learn_make: obj/learn_make.o
	gcc obj/learn_make.o -o bin/learn_make
obj/learn_make.o: src/learn_make.c inc/learn_make.h inc1/learn_make1.h inc2/learn_make2.h inc3/learn_make3.h obj/learn_make.o
	gcc -Iinc -Iinc1 -Iinc2 -Iinc3 -c src/learn_make.c  -o obj/learn_make.o
#需要TAB一下，不然会当成其他的含义，比如一个操作本身
rebuild: clean build
.PHONY: clean
clean:
	-rm obj/*
	-rm bin/*

