#!/bin/bash

echo "Please use below parameter. .syncCode.sh ServerType(Note:YT/KR) branchName  syncType tagManifest"
echo "Parameter Description:"
echo "============================================="
echo "ServerType: repolr -> KR server, Not Certain for YT"
echo "branchName: branch name"
echo "syncType: -qj8 -> full branch code to merge code; -qcj8 -> only current branch"
echo "tagManifest: manifest xml file name"
echo "============================================="

unset serverType branchName syncType tagManifest
serverType=$1
branchName=$2
syncType=$3
tagManifest=$4

if [ ! $severType ]
then
    serverType=KR
fi

if [ -z $tagManifest ]
then
    echo "No manifest is set yet."
else
    tagManifest="-m "+$tagManifest
fi


if [ $serverType == "KR" ]
then
    repolr -b $branchName $tagManifest.xml --reference=/home001/mirror/lr
    repo sync $syncType
    repo start $branchName --all
    repo forall -c 'git remote set-url --push lr ssh://lr.lge.com:29477/${REPO_PROJECT}'
else
    echo "Not set for YT server"
fi




