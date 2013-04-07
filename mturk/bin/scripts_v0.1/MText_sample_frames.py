#!/usr/bin/python

import sys,random


fn=sys.argv[1];
sampling_step=int(sys.argv[2])
sampling_offset=int(sys.argv[3])




videos=file(fn,'r').readlines();

random.seed();

print "Sqn\tVideo\tFrame"

sqn=0;
for iV,v in enumerate(videos):
	(video_name,nFrames)=v.strip().split(" ")
	nFrames=int(nFrames)
	#print video_name,nFrames
	
	selected_frames=range(sampling_offset+1,sampling_offset+nFrames+1,sampling_step);
	for f in selected_frames:
		sqn=sqn+1;
		print "%d\t%s\t%06d" %(sqn,video_name,f);

	