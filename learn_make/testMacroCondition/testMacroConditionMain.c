#include <stdio.h>
#include "testMacroConditionMain.h"
int main(int argc,char *argv[]){
    printf("%s\n", TEST_GCC_CMD);
/*#ifndef __abc__ */
#if !defined(__abc__) && !defined(__def__)
    printf("%s\n", "Not define __abc__ and __def__.");
#endif

/*#ifndef CONFIG_MACH_MSM8X10_W3_GLOBAL_COM */
#if !defined(CONFIG_MACH_MSM8X10_W3_GLOBAL_COM) && !defined(CONFIG_MACH_MSM8X10_W3DS_GLOBAL_COM)
    printf("%s\n", "haha");
#endif
    return 0;

}
