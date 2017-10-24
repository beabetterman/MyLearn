#!/bin/bash

die(){
    echo "$@"
    exit 1
}

[ "$#" -eq 1 ] || die "1 arguments required. The file name should be provided."

# TODO set var by parameters
user_name=zhiming.wang
password=lgeyt123
server=172.28.216.20
remote_directory="Temp" 
#origin_file_path="Debug_LGM700AT-00-V10h-GLOBAL-COM-OCT-10-2017+0.kdz"
origin_file_path=$1
echo $origin_file_path
origin_file_name=$(echo $origin_file_path | awk -F"/" '{print $NF}' )
echo $origin_file_name

# ------------ Zip and Split the files to transfer-----------------
origin_file_name_no_suffix=$(echo $origin_file_name | awk -F"." '{print $1}')
echo origin_file_name_no_suffix : "$origin_file_name_no_suffix"
// temp comment , need turn on when release.
zip "$origin_file_name_no_suffix".zip $origin_file_name

# Splitted file size
file_size=$(ls -al "$origin_file_name_no_suffix".zip | awk '{print $5}')
file_size=$(($file_size/1000000))
echo File size is : "$file_size"m
zip_size=$((file_size/10))
echo Splitted into 10 files, each file size is : "$zip_size"m
split -b "$zip_size"m "$origin_file_name_no_suffix".zip "$origin_file_name_no_suffix"_zip

# Mark origin file list and copied file list , to check whether all files copied done.
origin_file_list=origin_file_list_$(date +%Y%m%d%H%M%S).txt
touch $origin_file_list
ls -al "$origin_file_name_no_suffix"_zip* >> $origin_file_list

copy_log_name=copy_log_$(date +%Y%m%d%H%M%S).txt
touch $copy_log_name

# TODO Not sure touch in remote or not.
:<<!
expect -c "
    set timeout -1
    spawn ssh $user_name@$server

    expect "?assword:"
    send \"$password\r\"

    expect "?$"
    send \"touch $remote_directory\/$copy_log_name\r\"

    send \"exit\r\"
    expect eof"
!

# ----------------- Create new window to copy the files ----------------------
# each zip file
file_parts=$(ls "$origin_file_name_no_suffix"_zip*)
echo file_parts is $file_parts
current_window_index=$(tmux display-message -p '#I')
# Flag for mark copy windows
window_flag=0
# This is important to keep the copy windows open state.
tmux set-option set-remain-on-exit on
file_path=$(pwd)
for each_file in $file_parts
do
    tmux new-window -n cw$window_flag
    tmux send-keys -t cw$window_flag "tmux set-option set-remain-on-exit on" C-m
    tmux send-keys -t cw$window_flag "cd $file_path" C-m
    tmux send-keys -t cw$window_flag ". copy_binary_by_sftp_script.sh $user_name $password $server $remote_directory  $each_file $copy_log_name" C-m
    sleep 3
    tmux send-keys -t cw$window_flag "tmux set-option set-remain-on-exit off" C-m
    let window_flag++
done
tmux set-option set-remain-on-exit off

# Back to the main process window to check the copy status.
tmux select-window -t :$current_window_index 

# TODO add the check of file copied or not. By checking the two files.
origin_file_number=$(awk 'END{print NR}' "$origin_file_list")
echo origin file number : $origin_file_number
copied_file_number=$(awk 'END{print NR}' "$copy_log_name")
echo copied file number : $copied_file_number
while [ "$origin_file_number" -ne "$copied_file_number"  ]
do
    copied_file_number=$(awk 'END{print NR}' "$copy_log_name")
    echo "Copy job isn't done. Wait for another 30 seconds,origin file number: $origin_file_number , copied done file number: $copied_file_number"
    sleep 30
done 

echo "Congratulations! Copy job is done."

# compass the splitted files, and unzip the files.
expect -c "
    set timeout -1
    spawn ssh $user_name@$server

    expect "?assword:"
    send \"$password\r\"

    expect "$?"
    send \"cd Temp\r\"

    expect "$?"
    send \"cat "$origin_file_name_no_suffix"_zip* \>\> "$origin_file_name_no_suffix".zip\r\"

    expect "$?"
    send \"unzip "$origin_file_name_no_suffix".zip\r\"

    expect "$?"
    send \"ls -al "$origin_file_name" > abc.txt\r\"

    expect "$?"
    send \"rm "$origin_file_name_no_suffix"_zip* \r\"


    expect "$?"
    send \"exit\r\"

    expect eof"

# TODO check the file final size.
ls -al "$origin_file_name_no_suffix".kdz >> abc.txt

for i in {0..$window_flag}
do 
    tmux kill-window -t :cw$i
done 

rm "$origin_file_name_no_suffix"_zip*
