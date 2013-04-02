% another restart script
cat_str = 'cat'

% NOTE: to use this script, set cat_str to the desired category label first.
%distributed processing settings
%run in parallel?
isparallel=1;
%if isparallel=1, number of parallel jobs
nprocs=50;
%if isparallel=1, whether to run on multiple machines or locally
isdistributed=1;

%output directory settings
global ds;
myaddpath;
ds.prevnm=mfilename;
ds.isrecalc = 0;
ranking=1;

   patch_dir{1}=['/data/hays_lab/finder/Discriminative_Patch_Discovery/' ...
               'pascal_07_patches/overallcounts'];

   patch_dir{2}=['/data/hays_lab/finder/Discriminative_Patch_Discovery/' ...
               'pascal_07_patches/posterior'];

dssetout([patch_dir{ranking} '/' cat_str '/'  ds.prevnm '_out']);

%ds.dispoutpath=[ ds.prevnm '_out/'];
%loadimset(7);
%% NOTE: this should be changed to the correct dataset also
load('dataset20.mat'); 


setdataset(imgs,'/data/hays_lab/pascal_07/VOCdevkit/VOC2007/JPEGImages/','');
if(isfield(ds.conf.gbz{ds.conf.currimset},'imgsurl'))
  ds.imgsurl=ds.conf.gbz{ds.conf.currimset}.imgsurl;
end

%general configuration

%define the number of training iterations used.  The paper uses 3; sometimes
%using as many as 5 can result in minor improvements.
num_train_its=5;

rand('seed',1234)

%parameters for Saurabh's code
ds.conf.params= struct( ...
  'imageCanonicalSize', 400,...% images are resized so that their smallest dimension is this size.
  'patchCanonicalSize', {[80 80]}, ...% patches are extracted at this size.  Should be a multiple of sBins.
  'scaleIntervals', 8, ...% number of levels per octave in the HOG pyramid 
  'sBins', 8, ...% HOG sBins parameter--i.e. the width in height (in pixels) of each cell
  'useColor', 1, ...% include a tiny image (the a,b components of the Lab representation) in the patch descriptor
  'patchOverlapThreshold', 0.6, ...%detections (and random samples during initialization) with an overlap higher than this are discarded.
  'svmflags', '-s 0 -t 0 -c 0.1');

ds.conf.detectionParams = struct( ...
  'selectTopN', false, ...
  'useDecisionThresh', true, ...
  'overlap', 0.4, ...% detections with overlap higher than this are discarded.
  'fixedDecisionThresh', -1.002);

%pick which images to use out of the dataset

imgs=ds.imgs{ds.conf.currimset};
ds.mycity={cat_str};%paris'};% for 15 scene test
parimgs=find(ismember({imgs.city},ds.mycity));

ds.ispos=zeros(1,numel(imgs));
ds.ispos(parimgs)=1;
otherimgs=ones(size(imgs));
otherimgs(parimgs)=0;

otherimgs=find(otherimgs);
rp=randperm(numel(parimgs));

% keyboard
parimgs=parimgs(rp);%2000));%usually 2000 positive images is enough; sometimes even 1000 works.
rp=randperm(numel(otherimgs));
otherimgs=otherimgs(rp);%8000));%
ds.myiminds=[parimgs(:); otherimgs(:)];
ds.parimgs=parimgs;

'positive'
numel(parimgs)
'other'
numel(otherimgs)
%keyboard
%%
%sample random positive "candidate" patches
step=2;
ds.isinit=makemarks(ds.myiminds(1:step:end),numel(imgs));
initInds=find(ds.ispos&ds.isinit);
if(isparallel&&(~dsmapredisopen()))
    dsmapredopen(nprocs, 1, ~isdistributed);
end

dsload('ds.assignednn','ds.assignedidx','ds.pyrscales','ds.pyrcanosz');

dsload('ds.bestbin0','ds.selectedClust','ds.initFeats','ds.assignedClust'