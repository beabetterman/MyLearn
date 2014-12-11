.PHONY: build_lib
build_lib:bin/libds_tree.a
bin/libds_tree.a:obj/ds_tree.o
	ar -r bin/libds_tree.a obj/ds_tree.o

obj/ds_tree.o: src/ds_tree.c inc/ds_tree.h
	gcc -fpic -Iinc -c src/ds_tree.c -o obj/ds_tree.o

.PHONY:test
test:bin/test
bin/test:bin/libds_tree.a obj/test_ds_tree_main.o 
	# If write like below line, will occur function not found
	gcc obj/test_ds_tree_main.o -Lbin -lds_tree -o bin/test
	#gcc -Lbin -lds_tree obj/test_ds_tree_main.o -o bin/test

obj/test_ds_tree_main.o:src/test_ds_tree_main.c inc/ds_tree.h
	gcc -Iinc -c src/test_ds_tree_main.c -o obj/test_ds_tree_main.o


.PHONY: clean
clean: 
	-rm obj/*
	-rm bin/*
