#!/bin/bash

flag=0
for each_file in {0..9}
do
    #tmux kill-window -t :$each_file 
    tmux kill-window -t :cw"$flag"
    echo cw$flag
    let flag++
done

#rm Debug_LGM700AT-00-V10h-GLOBAL-COM-OCT-10-2017+0_zip*
#rm Debug_LGM700AT-00-V10h-GLOBAL-COM-OCT-10-2017+0.zip
