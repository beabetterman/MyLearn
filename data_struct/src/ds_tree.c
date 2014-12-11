/*****************************
 * src/ds_tree.c
 * by wzm
 * **************************/
static int ds_tree_flag = 0;
void ds_tree_init(void){
    if(ds_tree_flag){
        //log("module inited..", X)
        return;
    }
    ds_tree_flag = 1;
    // TODO : module init ...
}

void ds_tree_destroy(void){
    if(!ds_tree_flag){
        //log("module not inited..", X)
        return;
    }
    ds_tree_flag = 0;
    // TODO module destroy...
}
