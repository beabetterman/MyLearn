#!/bin/bash

die(){
    echo "$@"
    exit 1
}

[ "$#" -eq 1 ] || die "1 arguments required. The file name should be provided."

tmux new -s se -n mywindow -d
tmux send-keys -t se:mywindow "bash main_copy_process.sh $1" C-m
tmux attach -t se
