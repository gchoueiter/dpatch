#!/usr/bin/python


import os, sys

input_file=sys.argv[1]
if len(sys.argv)>2:
	if sys.argv[2]=='-sandbox':
		sandbox_flag="-sandbox";
	else:
		print "error";
		sys.exit();
else:
	sandbox_flag="";

records=open(input_file,'r').readlines();

wd=os.getcwd();

#mthome=os.getenv('MTURK_CMD_HOME');
#os.chdir(mthome+'/bin/');

print "#!/bin/bash"

print "pushd $MTURK_CMD_HOME/bin/"
for r in records[1:]:
	(assignmentID,workerID,bonus,comment)=r.strip().split('\t')
	cmd="./grantBonus.sh %s -workerid %s -assignment %s -reason %s -amount %s" %(sandbox_flag,workerID,assignmentID,comment,bonus)
	print cmd
	#os.system(cmd);

print "popd"
#os.chdir(wd);
