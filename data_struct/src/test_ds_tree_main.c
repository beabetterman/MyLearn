/*
 * Just for test.
 */

#include <stdio.h>
#include "ds_tree.h"
extern void ds_tree_init(void); // Have a try to cancel the comment character //
int main(int argc, char *argv[]){
    printf("Now in test_ds_tree_main file. Method: main\n");
    ds_tree_init();
    ds_tree_destroy();
    printf("At the end of the main. Before return.\n");
    return 0;
}
