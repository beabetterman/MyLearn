#!/bin/bash

#对变量赋值,+两侧不能有空格
Test_Var_In_String="Test variable in String"
echo "Here is the String [${Test_Var_In_String}], should use \${} surround the variable"
# No ; and the end of the command line
#除了在变量赋值和在FOR循环语句头中，BASH 中的变量使用必须在变量前加"$"符号

#Test Variable assign 
Test_Variable_Any_Type=2013
echo ${Test_Variable_Any_Type}
Test_Variable_Any_Type="String"
echo ${Test_Variable_Any_Type}

# Calculate expression
x=2013
echo "x is :[${x}]"
let "x=$x+1"
echo "x = ${x}"
x="${x}+1"
echo "x = ${x}"

