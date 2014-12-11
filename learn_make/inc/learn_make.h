#ifndef _LEARN_MAKE_H_ // 我自己参考其他软件写法的习惯，对于头文件防止重复定编译的定义
// 采用文件名全大写，前后加_的方式实现
#define _LEARN_MAKE_H_

/*
    如果你想知道为什么要加
    #ifndef XXXX
    #define XXXX
    你尝试这个头文件里，加上#include "learn_make.h"并尝试自己手工，将@include对应的文件内容copy到这个位置，如同预编译那样做的哦，
你再简单的分析一下，是否会无限循环的加载文件内容，就可以理解了。
*/
#define TEST_GCC_CMD "test gcc cmd"
#endif // _LEARN_MAKE_H_
//这里的写法只是让你知道这个#endif对应那个#if #ifdef #ifndef 等等存在作用域的预处理工作
