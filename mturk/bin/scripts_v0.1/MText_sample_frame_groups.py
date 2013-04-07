#!/usr/bin/python
""" Sample N groups of k frames from every video
	
"""


import sys,random


if len(sys.argv)<5:
	print """Usage: MT_ext_sample_frame_groups frame_counts N_groups_per_video N_samples_per_group SamplingStep"""
	sys.exit();

fn=sys.argv[1];
groups_per_video=int(sys.argv[2])
samples_per_group=int(sys.argv[3])
frames_step=int(sys.argv[4])



videos=file(fn,'r').readlines();

random.seed();

sqn=0;
for iV,v in enumerate(videos):
	(video_name,nFrames)=v.strip().split(" ")
	nFrames=int(nFrames)
	
	selected_frames=random.sample(range(1,nFrames+1-samples_per_group*frames_step),groups_per_video);
	for f in selected_frames:
		for iSample in range(0,samples_per_group):
			sqn=sqn+1;
			print "%d\t%s\t%06d" %(sqn,video_name,f+iSample*frames_step);

	