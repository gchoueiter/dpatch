#!/usr/bin/python

# Copyright 2008 Alexander Sorokin, University of Illinois at Urbana-Champaign.
# Intended for research use



import os,sys
import httplib,urllib

server_name="vision-app1.cs.uiuc.edu:8080"

iArg=1
session=None
tasks_file=None

while iArg<len(sys.argv):
        if iArg==1:
                session=sys.argv[iArg];
        if iArg==2:
                tasks_file=sys.argv[iArg];
        iArg=iArg+1;

if session is None or tasks_file is None:
        print "Usage: hm_load_hits.py session tasks_file"
        sys.exit();


conn = httplib.HTTPConnection(server_name)
print conn
path="/mt/load_tasks/"+session+"/";
print path
        
data=file(tasks_file,'r').read();
print data
print len(data)
conn.request("POST", path,'data='+urllib.quote(data))


#conn.endheaders();
#conn.send(data);        
r1 = conn.getresponse()
        
print r1.status, r1.reason
        
if r1.status==200:
	data1 = r1.read()
	print "Success, created %s tasks"%data1
else:
	print "Failed"
	data1 = r1.read()
	print data1
        conn.close()

