#!/bin/bash

RED='\e[1;31m';
GREEN='\e[1;32m';
YELLOW='\e[1;33m';
BLUE='\e[1;34m';
PINK='\e[1;35m';
NCOL='\e[0m';

while read line
do
    cd $line
    while true
    do
        #git push --tags> /dev/null
        result=`git push --tags 2>&1`
        echo $result | grep 'fatal'
        if [ $? -ne 0 ]
        then
            echo -e ${GREEN}${line}${NCOL}
            break
        else
            echo -e ${RED}${line}${NCOL}
        fi
    done
    cd - > /dev/null
done < .repo/project.list
