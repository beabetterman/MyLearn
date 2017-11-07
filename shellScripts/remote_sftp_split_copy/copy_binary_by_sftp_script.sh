#!/bin/bash

#Program
# For User version PDM file management and copy.
# Autho wzm
# Version 0.01


die(){
    echo  "$@"
    exit 1
}

[ "$#" -eq 6 ] || die "5 arguments required, user_name, password, server, remote directory, file_name, log_file_name $# provided"

user_name=$1;
password=$2
server=$3
remote_directory=$4
file_name=$5
copy_log_name=$6
export HISTIGNORE="expect*"
echo $user_name $password $server $remote_directory  $file_name $copy_log_name 
#tmux new-window -n new_window
#tmux select-window -t new_window

ls -al $file_name
    
expect -c "
    set timeout -1
    spawn sftp $user_name@$server
    
    expect {
    "*yes/no*" {send \"yes\r\";exp_continue}
    "?assword:" {send \"$password\r\"}
    }
    
    expect "sftp?"
    send \"cd $remote_directory\r\"

    expect "sftp?"
    send \"put $file_name $file_name\r\"
    expect "?100%?"

    send \"ls -al $file_name\r\"
    expect "sftp?"

    send \"!ls -al $file_name 2>&1 | tee -a $copy_log_name \r\"
    expect "sftp?"

    send \"exit\r\"
    expect eof"

export HISTIGNORE="";

#send \"lls -al $file_name | 1>copy_done_log.txt 2>copy_error_log.txt \r\"
