#!/opt/local/bin/python
import os,sys,time,urllib,random

if len(sys.argv)<2:
	print """Usage: ./parse_results.py output_root
E.g. ./parse_resutls.py runs/sandbox1
"""
	sys.exit();


FN="workload.results";

OUTD=sys.argv[1];
if not OUTD[-1] == '/':
	OUTD=OUTD+'/';

OUTDPRIVATE=OUTD+"results_private/";
OUTD_GRADING=OUTD+"grading/";
OUTD=OUTD+"results/";

if not os.path.exists(OUTD):
	os.makedirs(OUTD)

if not os.path.exists(OUTDPRIVATE):
	os.makedirs(OUTDPRIVATE)

if not os.path.exists(OUTD_GRADING):
	os.makedirs(OUTD_GRADING)


OUTDRAW=OUTD+"raw/";

if not os.path.exists(OUTDRAW):
	os.makedirs(OUTDRAW)



base="http://visual-hits.s3.amazonaws.com/demo-heads/";

#xml_base="http://vision-app1.cs.uiuc.edu/frames/annotations/demo-heads/"
#imgBase="http://vision-app1.cs.uiuc.edu/frames/";

#xml_base="http://visual-hits.s3.amazonaws.com/demo-heads/frames/annotations/demo-heads/"
xml_base="annotations/demo-heads/"
imgBase=base;





lines=file(FN,'r').readlines();
header=lines[0];
attr_names=map(lambda s:s.strip("\"\n"),header.split("\t"));
#print attr_names

#indexFN="%s/index.txt" % (OUTD)	
#indexF=open(indexFN,'w');
workersFN="%s/workers.txt" % (OUTDPRIVATE)	
fWorkers=open(workersFN,'w');

#approveFN="%s/task.approve" % (OUTD)	
#approveF=open(approveFN,'w');
#print >>approveF, "assignmentIDToApprove"

commentsFN="%scomments.txt"%(OUTD)
fComments=open(commentsFN,'w');

fields=map(lambda s:s.strip('"'),lines[0].strip("\n").split("\t"));

#print fields
#base_url="http://vision-app1.cs.uiuc.edu/code/aspect_grade.html"

fGrading=open(OUTD_GRADING+"workload.input","w");
print >>fGrading,"parentAssignmentID\tTaskURL"




fResults=open(OUTD+"results.html","w");
print >>fResults,"<html><ul>";


def convert_file2dictionary(filename,dictKeyField):
	fTasks=open(filename,"r")
	original_lines=fTasks.readlines();
	fTasks.close();
	original_fields=map(lambda s:s.strip('"'),original_lines[0].strip("\n").split("\t"));
	all_tasks={};
	for t in original_lines[1:]:
		task_dictionary={};
		for k,v in map(None,original_fields,t.split('\t')):
			task_dictionary[k]=v;
		all_tasks[task_dictionary[dictKeyField]]=task_dictionary;
	return all_tasks;

all_tasks=convert_file2dictionary('workload.input','Id');


if os.path.exists("workload.approve_file") and os.path.exists("workload.redo"):
	bHasGradingResults=1
	approve_data=convert_file2dictionary("workload.approve_file","assignmentIdToApprove")
	redo_data=convert_file2dictionary("workload.redo","assignmentIdToReject")
	print approve_data,redo_data
	fGoodResults=open(OUTD+"good.results",'w')

else:
	bHasGradingResults=0


def hist(lst):
	h={};
	for i,e in enumerate(lst):
		if e not in h:
			h[e]=[1,[i]];
		else:
			elem=h[e]
			elem[0]=elem[0]+1;
			elem[1].append(i);
	return h;


nToGrade=0;
iAlignmentSqn=0;
for (iLine,l) in enumerate(lines[1:]):
	values=map(lambda s:s.strip("\"\n"),l.split("\t"));

	vMap={};
	for (iV,v) in enumerate(values):
		vMap[fields[iV]]=v;

	if not "Answer.Comments" in vMap:
		continue;

	#all_tasks[task_dictionary['Sqn']]=task_dictionary;
	#print vMap["Answer.Comments"];
	#print vMap["Answer.Comments"];
	#print vMap["Answer.answer"];

	TaskSqn=vMap["annotation"].split()[2];
	task=all_tasks[TaskSqn];

	answer=vMap["Answer.sites"].strip();
	if answer=="":
		continue
	comments=vMap["Answer.Comments"];

	if not comments=="":
		print >>fComments,comments
		print comments

	answer_xml=urllib.unquote_plus(answer)
	fXML=open(OUTD+vMap["assignmentid"]+".xml",'w')
	print >>fXML,answer_xml
	#print answer_xml
	fXML.close();


	view_URL="%scode/generic2.html?swf=label_generic&swf_w=900&swf_h=600&mode=display2&img_base=%s&video=%s&frame=%s&task=%s&annotationURL=%s&assignmentid=NONE" % (base,imgBase,task["Video"],task["Frame"],task["Task"],"annotations/"+task["Task"]+"/"+vMap["assignmentid"]+".xml")
	
	print >>fResults,"""<li><a href="%s">Task %s, %s, (%d)</a></li>""" % (view_URL,TaskSqn,vMap["assignmentid"],len(answer_xml));



	continue


	view_URL="http://vision-app1.cs.uiuc.edu/code/generic3_grade.html?swf=visual_alignment&swf_w=900&swf_h=600&mode=display&image_base=%s&frames=%s&part_name=%s&task=alignment&annotation=%s&originalAssignmentID=%s" % (task["ImgBase"],task["ImgList"].strip(),task["PartLabel"],urllib.quote_plus(xml_base+vMap["assignmentid"]+".xml"),vMap["assignmentid"]);
	view_URL2=view_URL.replace("&","&amp;");


	#print "%s\t%s"%(vMap["hitid"],urllib.quote_plus(view_URL))
	#print "%s\t%s"%(vMap["hitid"],view_URL)
	print view_URL2
	print >>fGrading,"%s\t%s"%(vMap["assignmentid"],view_URL2)

	nToGrade+=1;

	if bHasGradingResults:
	   aID='"'+vMap["assignmentid"]+'"'
	   aID2=vMap["assignmentid"]
	   if not (aID in approve_data or aID2 in approve_data) or (aID in redo_data or aID2 in redo_data):
		pass
	   else:
	   	print >>fGoodResults,"%s" %vMap["assignmentid"];




print "Found %d tasks to grade" % nToGrade

fGrading.close();
fComments.close();
	
