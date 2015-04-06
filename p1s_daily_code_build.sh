#!/bin/bash
# Get tag information
unset mpBranchDailyTag mainBranchDailyTag
mpBranchDailyTag=$1
mainBranchDailyTag=$2
if [ ! $mainBranchDailyTag ] 
then
    echo "Not set mainBranchDaily Tag, will set to today automatically."
    mainBranchDailyTag=`date  +%y%m%d`
fi

read -p "Input main branch daily tag is: ${mainBranchDailyTag} and mp branch tag is :${mpBranchDailyTag}" -t 10
echo ""
echo "Main branch tag is : ${mainBranchDailyTag} , MP branch tag is : ${mpBranchDailyTag}"

# Sync the latest mp branch code
# First clean the code
repo forall -c git checkout -f
repo forall -c git clean -df
rm -rf android/out-g4stylusn_global_com &
rm -rf RELEASE &
# Sync code
repolr -b  msm8916_l_p1s_mp_150307
repolr -b  msm8916_l_p1s_mp_150307 -m $mpBranchDailyTag.xml
repo sync -d -cj8
repo start  msm8916_l_p1s_mp_150307 --all

# Get main branch manifest file from base branch, and save the manifest file.
repolr -b lamp_l_release -m msm8916/msm8916.xml --reference=/home001/mirror/lr
if [ ! -d msm8916TagsAndLogs ] 
then
    mkdir msm8916TagsAndLogs
fi
# if the main branch tag file not found, try to set to tag to the former day
if [ ! -e .repo/manifests/msm8916/msm8916/$mainBranchDailyTag.xml ]
then
    echo "Can't find the main tag ${mainBranchDailyTag}, try to set to the tag to former day."
    mainBranchDailyTag=`date -d "-1 day" +%y%m%d`
    if [ ! -e .repo/manifests/msm8916/msm8916/$mainBranchDailyTag.xml ]
    then
        echo "Can't find the main tag ${mainBranchDailyTag}, please check main branch tag manually."
        return
    fi
fi

cp .repo/manifests/msm8916/msm8916/$mainBranchDailyTag.xml msm8916TagsAndLogs

# Sync the MP branch code.
repolr -b msm8916_l_p1s_mp_150307 -m $mpBranchDailyTag.xml --reference=/home001/mirror/lr
cp msm8916TagsAndLogs/$mainBranchDailyTag.xml .repo/manifests/
repo forall android/vendor/lge/apps/ImsA_L android/vendor/lge/apps/RcsCall android/vendor/lge/apps/LTECall4_KLP android/vendor/lge/apps/LGTelephonyServices -c git pull

# Get the main branch latest code for certain projects.
repolr -m $mainBranchDailyTag.xml
repo sync android/vendor/lge/apps/ImsA_L android/vendor/lge/apps/RcsCall android/vendor/lge/apps/LTECall4_KLP android/vendor/lge/apps/LGTelephonyServices -d -cj8

# Make tag to save the main branch code information. (Code to be merged commits.)
echo "Before make the tag."
repo forall android/vendor/lge/apps/ImsA_L android/vendor/lge/apps/RcsCall android/vendor/lge/apps/LTECall4_KLP android/vendor/lge/apps/LGTelephonyServices -c git tag -a ${mainBranchDailyTag} -m ${mainBranchDailyTag}

# Sync code
repolr -b msm8916_l_p1s_mp_150307 -m $mpBranchDailyTag.xml --reference=/home001/mirror/lr
repo sync android/vendor/lge/apps/ImsA_L android/vendor/lge/apps/RcsCall android/vendor/lge/apps/LTECall4_KLP android/vendor/lge/apps/LGTelephonyServices -d -cj8

#Merge tag
repo forall android/vendor/lge/apps/ImsA_L android/vendor/lge/apps/RcsCall android/vendor/lge/apps/LTECall4_KLP android/vendor/lge/apps/LGTelephonyServices -c git merge $mainBranchDailyTag --commit | tee msm8916TagsAndLogs/merge${mainBranchDailyTag}.log

echo "Code Preparation is Done"
#-----------------------------------------------
#  Build
#-----------------------------------------------

# Modem build
cd non_HLOS
./build_target.sh g4stylusn_global_com | tee ../msm8916TagsAndLogs/modem`date +%y%m%d`.log &

# TODO Need delete the command, after the temp build.
exit 0

# Android build
cd ../android
source ./build/envsetup.sh
lunch g4stylusn_global_com-userdebug
m -j16

# Release tot
cd ..
./release_image.sh g4stylusn_global_com [ OPEN_HK ] | tee msm8916TagsAndLogs/`date +%y%m%d`release.log


cleanP1sCode() {
    repo forall -c git checkout -f
    repo forall -c git clean -df
    rm -rf android/out-g4stylusn_global_com &
    rm -rf RELEASE &
}

repolr -b msm8916_l_p1s_mp_150307 -m $mpBranchDailyTag.xml --reference=/home001/mirror/lr
repo sync android/vendor/lge/apps/ImsA_L android/vendor/lge/apps/RcsCall android/vendor/lge/apps/LTECall4_KLP android/vendor/lge/apps/LGTelephonyServices -d -cj8
repo start msm8916_l_p1s_mp_150307 --all
repo sync android/vendor/lge/apps/ImsA_L android/vendor/lge/apps/RcsCall android/vendor/lge/apps/LTECall4_KLP android/vendor/lge/apps/LGTelephonyServices -d -cj8
