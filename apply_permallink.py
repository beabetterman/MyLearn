#!/usr/bin/env python
#made by likepaul.kim / likepaul.kim@lge.com
# updated by jungkyun.park date 14.05.05

import sys
import os
import subprocess
import json
from time import strftime

##
remoteUrl = 'ssh://lap.lge.com:29475/'
remoteAppsUrl = "ssh://165.243.137.64:29427/"
remoteLrUrl = "ssh://lr.lge.com:29477/"

##
lapUrl="http://lap.lge.com:8145/lap/"
appsUrl="http://165.243.137.64:8097/LG_apps/"
lrUrl="http://lr.lge.com:8147/lap-review/"

ConflictedList = []
AppliedList = []
FailedList = []
NeedToClean = []

OKGREEN = '\033[92m'
HEADER="\033[95m"
YELLOW="\033[93m"
ENDC = '\033[0m'
RED = '\033[31m'
BLUE = '\033[34m'
MAGENT = '\033[35m' #pink
CYAN = '\033[36m'
WHITE = '\033[37m'
BOLD = '\033[01m'  # remove bold : '\033[22m 
UNDERLINE = '\033[4m' #remove : '\033[24m' 
ITALIC = '\033[3m' #remove : '\033[23m'
MIDDLELINE = '\033[9m' #remove : '\033[29m'

def getChanges(id, gerrit_type):
	if (gerrit_type=="LG_apps"):
		qcmd = ["ssh", "-p", "29427", "165.243.137.64", "gerrit", \
			"query", "--format=JSON", "--current-patch-set", \
			"change:"+id]
	elif (gerrit_type=="lap"):
		qcmd = ["ssh", "-p", "29475", "lap.lge.com", "gerrit", \
			"query", "--format=JSON", "--current-patch-set", \
			"change:"+id]
	elif (gerrit_type=="lr"):
		qcmd = ["ssh", "-p", "29477", "lr.lge.com", "gerrit", \
			"query", "--format=JSON", "--current-patch-set", \
			"change:"+id]
	changes = []
	p = subprocess.Popen(qcmd, shell=None, stdout=subprocess.PIPE)
	while 1:
		context = p.stdout.readline()
		if not context:
			break
		changes.append(json.loads(context))
	changes.pop(len(changes)-1)
	changes.reverse()
	return changes

def applyPatchSet(changes):
	repoRoot = os.getcwd()
	checkAppsCommit = "lap"
	for change in changes:
		show_result("======================================")
		cmdRepoList = ["repo", "list", change[0][u'project']]
		pRepoList = subprocess.Popen(cmdRepoList, shell=None, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
		repoListResult = pRepoList.stdout.readline()
		path = repoListResult.split(' ')[0]
		if not path:
			print (change[0][u'url'] + RED + " -> Invalid path..!!" + ENDC)
			#print (Url + change[u'number'] + RED + " -> Invalid path..!!" + ENDC)
			FailedList.append(change[0][u'url'] + " failed (Invalid path)")
		else:
			os.chdir(path)
			if (change[1] == "lap"):
				show_result(lapUrl+change[0][u'number'])
				cmdGitPull = ["git", "fetch", remoteUrl + change[0][u'project'], change[0][u'currentPatchSet'][u'ref']]		
			elif (change[1]== "LG_apps") :
				show_result(appsUrl+change[0][u'number'])
				cmdGitPull = ["git", "fetch", remoteAppsUrl + change[0][u'project'], change[0][u'currentPatchSet'][u'ref']]
			elif (change[1]== "lr"):
				show_result(lrUrl+change[0][u'number'])
				cmdGitPull = ["git", "fetch", remoteLrUrl + change[0][u'project'], change[0][u'currentPatchSet'][u'ref']]
			checkAppsCommit = change[1]
			
			pGitPull = subprocess.Popen(cmdGitPull, shell=None, stdout=subprocess.PIPE)
			pGitPull.wait()
			cmdGitPull = ["git", "cherry-pick", "FETCH_HEAD"]
			pGitPull = subprocess.Popen(cmdGitPull, shell=None, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
			pGitPull.wait()
			read_stdout = pGitPull.stdout.read()
			print read_stdout
			checkApplyError(pGitPull.stderr.read(), read_stdout, change[0], path, checkAppsCommit)
			show_result("======================================")
			os.chdir(repoRoot)


def printResultToFile():
	show_result(OKGREEN+"############################################"+ENDC)
	show_result(OKGREEN+"##########      R E S U L T      ###########"+ENDC)
	show_result(OKGREEN+"############################################"+ENDC)
	show_result (HEADER+"########## Applied Permallink ###########"+ENDC)
	for Applied in AppliedList:
		show_result(Applied)
	show_result (HEADER+"########## Conflicted Permallink ###########"+ENDC)
	for Conflict in ConflictedList:
		show_result(Conflict)
	show_result (HEADER+"########## Failed Permallink ###########"+ENDC)
	for Failed in FailedList:
		show_result(Failed)
	for each in NeedToClean:
		show_result(each)

def show_result(str):
	print(str)
	result_file.writelines(str + "\n")

def checkApplyError(errString, stdoutString, change, path, gerrit_type):
	if (gerrit_type=="LG_apps"):
		Url = appsUrl
	elif (gerrit_type== "lap") :
		Url = lapUrl
	elif (gerrit_type== "lr"):
		Url = lrUrl
	show_result(errString)
	errorCase1 = r"after resolving the conflicts, mark the corrected paths"
	errorCase_alreadyapply = r"nothing to commit"
	errorCase_Untrackedfiles = r"nothing added to commit but untracked files present"

	if (errString == ""):
		AppliedList.append(Url + change[u'number'])
		
	elif (stdoutString.find(errorCase_alreadyapply) != -1):
		AppliedList.append(Url + change[u'number'] + " already applied")
		cmdGitReset = ["git", "reset"]
		pGitReset = subprocess.Popen(cmdGitReset, shell=None, stdout=subprocess.PIPE)
		pGitReset.wait()
	elif (stdoutString.find(errorCase_Untrackedfiles) != -1):
		NeedToClean.append(Url + change[u'number'] + " Need to Clean")
		cmdGitReset = ["git", "reset"]
		pGitReset = subprocess.Popen(cmdGitReset, shell=None, stdout=subprocess.PIPE)
		pGitReset.wait()
	else :
		ConflictedList.append(Url + change[u'number'])
		cmdGitReset = ["git", "reset", "--hard"]
		pGitReset = subprocess.Popen(cmdGitReset, shell=None, stdout=subprocess.PIPE)
		pGitReset.wait()
		cmdGitClean = ["git", "clean", "-fdx"]
		pGitClean = subprocess.Popen(cmdGitClean, shell=None, stdout=subprocess.PIPE)
		pGitClean.wait()
	return 0

def readFromTxt(filename):
	tmp=""
	cmdCatFile = ["cat" , filename]
	pCatFile = subprocess.Popen(cmdCatFile, shell=None, stdout=subprocess.PIPE)
	changes = []
	while 1:
		permallink = pCatFile.stdout.readline()
		if not permallink:
			break;
		permallink = str.strip(permallink)
		if (permallink == ""):
			continue;
		if (permallink[len(permallink)-1:len(permallink)] == "/"):
			permallink = permallink[0:len(permallink)-1]
		permallinkSplit = permallink.split('/')
		
		permallinkId = str.strip(permallinkSplit[len(permallinkSplit) -1])
		
		##
		#checking pattern
		print "checking pattern : " + permallinkId
		if (len(permallinkId) < 2):
			permallinkId = str.strip(permallinkSplit[len(permallinkSplit) -2])
			print "modified pattern : " + permallinkId
		elif (isInt(permallinkId)==False):
			permallinkId = permallinkId[0:len(permallinkId)-1]
			while (isInt(permallinkId)==False):
				permallinkId = permallinkId[0:len(permallinkId)-1]
			print "modified pattern : " + permallinkId
		else:
			permallinkId = str.strip(permallinkSplit[len(permallinkSplit) -1])
			print YELLOW + "good" + ENDC
		print (CYAN + "======================================" + ENDC)
		#checking pattern
		
		if (permallink.find("LG_apps/") > 0):
			tmp=getChanges(permallinkId, "LG_apps")
			if ( tmp == []):
				FailedList.append(appsUrl + permallinkId + RED+" -> gerrit query fail" + ENDC)
			else:
				changes.append([tmp[0], "LG_apps"])
		elif (permallink.find("lap/") > 0):
			tmp=getChanges(permallinkId, "lap")
			if ( tmp == []):
				FailedList.append(lapUrl + permallinkId + RED+" -> gerrit query fail" + ENDC)
			else:
				changes.append([tmp[0], "lap"])
		elif (permallink.find("lap-review/") > 0):
			tmp=getChanges(permallinkId, "lr")
			if ( tmp == []):
				FailedList.append(lrUrl + permallinkId + RED+" -> gerrit query fail" + ENDC)
			else:
				changes.append([tmp[0], "lr"])
		##
	return changes

def isInt(s):
  try:
    int(s)
    return True
  except ValueError:
    return False	

def readFromPermallink(permallink):
	tmp=""
	permallink = str.strip(permallink)
	if (permallink[len(permallink)-1:len(permallink)] == "/"):
		permallink = permallink[0:len(permallink)-1]
	permallinkSplit = permallink.split('/')
	permallinkId = str.strip(permallinkSplit[len(permallinkSplit) -1])
	changes=[]
	
	##
	#checking pattern
	print "checking pattern : " + permallinkId
	if (len(permallinkId) < 2):
		permallinkId = str.strip(permallinkSplit[len(permallinkSplit) -2])
		print "modified pattern : " + permallinkId
	elif (isInt(permallinkId)==False):
		permallinkId = permallinkId[0:len(permallinkId)-1]
		while (isInt(permallinkId)==False):
			permallinkId = permallinkId[0:len(permallinkId)-1]
		print "modified pattern : " + permallinkId
	else:
		permallinkId = str.strip(permallinkSplit[len(permallinkSplit) -1])
		print YELLOW + "good" + ENDC
	print (CYAN + "======================================" + ENDC)
	#checking pattern
	
	print(permallink)
	if (permallink.find("LG_apps/") > 0):
		print("LG_apps")
		tmp=getChanges(permallinkId, "LG_apps")
		if ( tmp == []):
			FailedList.append(appsUrl + permallinkId + RED+" -> gerrit query fail" + ENDC)
		else:
			changes.append([tmp[0], "LG_apps"])
	elif (permallink.find("lap/") > 0):
		print("lap")
		tmp=getChanges(permallinkId, "lap")
		if ( tmp == []):
			FailedList.append(lapUrl + permallinkId + RED+" -> gerrit query fail" + ENDC)
		else:
			changes.append([tmp[0], "lap"])
	elif (permallink.find("lap-review/") > 0):
		print("lap-review")
		tmp=getChanges(permallinkId, "lr")
		if ( tmp == []):
			FailedList.append(lrUrl + permallinkId + RED+" -> gerrit query fail" + ENDC)
		else:
			changes.append([tmp[0], "lr"])
	##
	return changes


def main(argv):
	if (not os.access("script_result", os.F_OK)):
		os.mkdir("script_result")
	global result_file
	result_file = file('script_result/apply_permallink_'+ strftime("%y%m%d-%H%M%S") +'.txt', 'w')	
	listChange = []
	if (argv[0].find("http://") != -1): # case : permallink input 
		listChange = readFromPermallink(argv[0])
	elif (argv[0].endswith(".txt")): # case : txt file input 
		listChange = readFromTxt(argv[0])
	else:
		print("Wrong file, please input txt file" )
		sys.exit(-1)
	applyPatchSet(listChange)
	printResultToFile()


if __name__ == '__main__':
    main(sys.argv[1:])

