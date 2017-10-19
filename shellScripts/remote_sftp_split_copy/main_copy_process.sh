#!/bin/bash

# TODO set var by parameters
user_name=zhiming.wang
password=lgeyt123
server=172.28.216.20
origin_file_path="Debug_LGM700AT-00-V10h-GLOBAL-COM-OCT-10-2017+0.kdz"
echo $origin_file_path
origin_file_name=$(echo $origin_file_path | awk -F"/" '{print $NF}' )
echo $origin_file_name

# zip and split the files to transfer
origin_file_name_no_suffix=$(echo $origin_file_name | awk -F"." '{print $1}')
echo origin_file_name_no_suffix : "$origin_file_name_no_suffix"
// TODO temp comment , need turn on when release.
#zip "$origin_file_name_no_suffix".zip $origin_file_name

# Splitted file size
file_size=$(ls -al "$origin_file_name_no_suffix".zip | awk '{print $5}')
file_size=$((file_size/1000000))
echo File size is : "$file_size"m
zip_size=$((file_size/10))
echo Splitted into 10 files, each file size is : "$zip_size"m


split -b "$zip_size"m "$origin_file_name_no_suffix".zip "$origin_file_name_no_suffix"_zip

# each zip file
file_parts=$(ls "$origin_file_name_no_suffix"_zip*)
echo file_parts is $file_parts

# Origin file list. To check the copied files.
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
    send \"touch Temp\/$copy_log_name\r\"

    send \"exit\r\"
    expect eof"
!

# Flag for mark copy windows
window_flag=0
# This is important to keep the copy windows open state.
tmux set-option set-remain-on-exit on
for each_file in $file_parts
do
    tmux new-window -n cw$window_flag
    tmux send-keys -t cw$window_flag ". copy_binary_by_sftp_script.sh $user_name $password $server $each_file $copy_log_name" C-m
    sleep 3
    let window_flag++
done

# TODO add the check of file copied or not. By checking the two files.
origin_file_number=$(awk 'END{print NR}' "$origin_file_list")
echo origin file number : $origin_file_number
copied_file_number=$(awk 'END{print NR}' "$copy_log_name")
echo copied file number : $copied_file_number
while [ "$origin_file_number" -ne "$copied_file_number"  ]
do
    copied_file_number=$(awk 'END{print NR}' "$copy_log_name")
    echo "Copy job isn't done. Wait for another 30 seconds"
    sleep 30
done 

echo "Congratulations! Copy job is done."

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
    send \"ls -al "$origin_file_name_no_suffix".kdz > abc.txt\r\"


    expect "$?"
    send \"exit\r\"

    expect eof"

# TODO check the file final size.
ls -al "$origin_file_name_no_suffix".kdz >> abc.txt

for i in {0..$flag}
do 
    tmux kill-window -t :cw$i
done 

rm "$origin_file_name_no_suffix"_zip*
