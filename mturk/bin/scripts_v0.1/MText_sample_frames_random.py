#!/usr/bin/python

import sys,random


fn=sys.argv[1];
samples_per_video=int(sys.argv[2])




videos=file(fn,'r').readlines();

random.seed();

sqn=0;
for iV,v in enumerate(videos):
	(video_name,nFrames)=v.strip().split(" ")
	nFrames=int(nFrames)
	#print video_name,nFrames
	
	selected_frames=random.sample(range(1,nFrames+1),samples_per_video);
	for f in selected_frames:
		sqn=sqn+1;
		print "%d\t%s\t%06d" %(sqn,video_name,f);

	