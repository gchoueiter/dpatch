%% script for recalculating ranking of patches
for cat_ind = 6:15
%% NOTE: this should be changed to the correct dataset also
load('dataset15.mat');

scene_cats=unique(arrayfun(@(x) x.city,imgs,'UniformOutput', ...
                           false));
cat_str = scene_cats{cat_ind};
if strcmp(cat_str, 'bedroom') == 1
    skip;
end

% NOTE: to use this script, set cat_str to the desired category label first.
%distributed processing settings
%run in parallel?
isparallel=1;
%if isparallel=1, number of parallel jobs
nprocs=200;
%if isparallel=1, whether to run on multiple machines or locally
isdistributed=1;

%output directory settings
global ds;
myaddpath;
%ds.prevnm=mfilename;
ds.prevnm='autoclust_main_15scene'
ds.isrecalc = 1;
ranking=1;

   patch_dir{1}=['/data/hays_lab/finder/Discriminative_Patch_Discovery/' ...
               '15_scene_patches/overallcounts'];

   patch_dir{2}=['/data/hays_lab/finder/Discriminative_Patch_Discovery/' ...
               '15_scene_patches/posterior'];

dssetout([patch_dir{ranking} '/' cat_str '/'  ds.prevnm '_out']);

%ds.dispoutpath=[ ds.prevnm '_out/'];
%loadimset(7);
 

%gen change
%% TODO: need to change 'imgs' so it only contains training images,
%% i.e. first 150 images from every scene class


imgs_train=[]; 
for i = 1:length(scene_cats)
train_inds = find(~arrayfun(@(x) isempty(strfind(x.city, scene_cats{i})), ...
                     imgs));
train_inds = train_inds(1:150);
imgs_train = horzcat(imgs_train, imgs(train_inds));
end
imgs=imgs_train;

setdataset(imgs,'/data/hays_lab/15_scene_dataset/','');
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
%%
  % pause
  % copy everything from the k = 1 directory into the k = 2 directory and change the output path   

%       stat = 1;
%       while(stat > 0.1)
%         pause(5)
%         stat = system(['cp -rf ' patch_dir{1} '/' cat_str '/ ' patch_dir{2} '/' cat_str '/ ']);
%       end        
%       dssetout([patch_dir{2} '/' cat_str '/'  ds.prevnm '_out']);



%sample random positive "candidate" patches
step=2;
ds.isinit=makemarks(ds.myiminds(1:step:end),numel(imgs));
initInds=find(ds.ispos&ds.isinit);
if(isparallel&&(~dsmapredisopen()))
    dsmapredopen(nprocs, 1, ~isdistributed);
end




%run the detectors on the entire dataset to compute purity/overlap
%%%%%%%%%
% just for recalculating ranking
dets = load([patch_dir{ranking} '/' cat_str '/'  ds.prevnm '_out/ds/dets.mat']);
ds.dets = dets.data;
%%%%%%%%%
citiestogen=ds.mycity;
ds.conf.origdetectionParams=ds.conf.detectionParams;
dps = struct( ...
          'selectTopN', false, ...
          'useDecisionThresh', true, ...
          'overlap', .5,...
          'fixedDecisionThresh', -.85,...
          'removeFeatures',1);
{'ds.conf.detectionParams','dps'};dsup;
dsmapreduce(['myaddpath;dsload(''ds.dets'');ds.detsimple{dsidx}=simplifydets(ds.dets.detectPresenceInImg(' ...
            'double(getimg(ds.myiminds(dsidx)))/256,ds.conf.detectionParams' ...
            '),ds.myiminds(dsidx));'],{'ds.myiminds'},{'ds.detsimple'},struct('noloadresults',1));
if(dsmapredisopen())
  dsmapredclose;
end

maxdet=size(ds.dets.firstLevModels.w,1);
imgs=ds.imgs{ds.conf.currimset};
dsdelete('ds.bestbin');


%'overallcounts' is the version of the display described in the paper: for each detector, 
%find the top 30 detections, and rank based on the proportion that's in paris.
%
%'posterior' finds all firings with a score > -.2 and computes the quantity 
%(#paris+1)/(#paris+#nonparis+2), where #paris is the number of firings in Paris,
%and #nonparis is the number of firings outside Paris.  Thus, it's a posterior
%estimate of the probability \theta that a firing will be in Paris, starting
%with a uniform prior on \theta.  In practice, detectors are more confident on
%elements that look very different from the negative set; hence this ranking
%tends to prefer elements that look very different from the negative set, whereas
%the 'overallcounts' tends to prefer elements that are more common.

disptype={'overallcounts', 'posterior'};
dsload('ds.myiminds','recheck');
[topn,posCounts,negCounts]=readdetsimple(maxdet,-.2,struct('oneperim',1,'issingle',1,'nperdet',250));
for k=2%1:numel(disptype)
  alldetections=[topn{1}(:);topn{2}(:)]';
  detsimpletmp=[];
  tmpdetectors=[alldetections.detector];
  tmpdecisions=[alldetections.decision];
  for(i=unique([alldetections.detector]))
    myinds=find(tmpdetectors==i);
    [~,ord]=sort(tmpdecisions(myinds),'descend');
    tmpdetsfordetr=alldetections(myinds(ord(1:min(numel(ord),30))));
    if(strcmp('overallcounts',disptype{k}))
      topNall{i}=alldetections(myinds(ord(1:min(numel(ord),250)))); 
    else
      topNall{i}=alldetections(myinds(ord(1:min(numel(ord),50))));
    end
    detsimpletmp=[detsimpletmp tmpdetsfordetr];
    switch(disptype{k})
    case('overallcounts')
      counts(i,1)=sum(ds.ispos([tmpdetsfordetr.imidx]));
      counts(i,2)=numel(tmpdetsfordetr)-counts(i,1);
    case('posterior')
      counts(i,1)=sum(posCounts{1}(i,:));
      counts(i,2)=sum(negCounts(i,:));
    end
    disp(i)
  end
  if(strcmp(disptype{k},'overallcounts'))
    [~,detord]=sort(counts(:,1),'descend');
  else
    post=(counts(:,1)+1)./(sum(counts,2)+2)
    [~,detord]=sort(post,'descend');
  end
  [overl groups affinities]=findOverlapping(topNall(detord),struct('findNonOverlap',1));
  dsload('ds.selectedClust','recheck');
  resSelectedClust=ds.selectedClust(detord(overl));
  detsimple=topn{1};
  for(j=1:numel(detsimple))
    detsimple(j).detector=ds.selectedClust(detsimple(j).detector);
  end
  if(~dsfield(ds,'selectedClustDclust'))
    {'ds.selectedClustDclust','resSelectedClust'};dsup;%this is the final ordering output
    [~,mapping]=ismember(ds.selectedClustDclust,ds.selectedClust);
    ds.detsDclust=selectDetectors(ds.dets,mapping);%this is the final output set of detectors
  end

  %generate a display of the final detectors
  ds.bestbin.imgs=imgs;
  nycdets2=[];
  mydetectors=[];
  mydecisions=[];
  nycdets=detsimple;
  for(j=numel(nycdets):-1:1)
    mydetectors(j)=nycdets(j).detector;
    mydecisions(j)=nycdets(j).decision;
  end
  curridx=1;
  for(j=unique(mydetectors))
    myinds=find(mydetectors==j);
    [~,best]=maxk(mydecisions(myinds),20)
    nycdets2{1,curridx}=nycdets(myinds(best));
    curridx=curridx+1;
  end
  nycdets2=cell2mat(nycdets2');
  disp(numel(nycdets2))
  ds.bestbin.alldisclabelcat=[[nycdets2.imidx]',[nycdets2.detector]'];
  ds.bestbin.alldiscpatchimg=extractpatches(nycdets2,ds.bestbin.imgs);
  ds.bestbin.decision=[nycdets2.decision];
  countsIdxOrd=detord(overl(1:min(numel(overl),500)));
  ds.bestbin.tosave=ds.selectedClust(countsIdxOrd);
  ds.bestbin.isgeneral=ones(1,numel(ds.bestbin.tosave));
  ds.bestbin.counts=[counts(countsIdxOrd,1),counts(countsIdxOrd,2)];
  if(exist('misclabel','var'))
    ds.bestbin.misclabel{1}=misclabel(countsIdxOrd);
  end
  dispres_discpatch;
  if(1)
%       k = 1; 
    %if enabled, this piece of code will generate an additional display
    %showing which elements overlap with each other.  Note, however,
    %that it overwrites some metadata for the other display, and so re-generating
    %that display may not work.
    bbhtmlorig=ds.bestbin.bbhtml;
    ds.bestbin.tosave=[];
    ds.bestbin.counts=[];
    ds.bestbin.group=ones(size(ds.bestbin.decision))*2;
    for(i=1:max(groups))
      togroup=detord(find(groups==i));
      togroup=togroup(:)';
      ds.bestbin.tosave=[ds.bestbin.tosave; ds.selectedClust(togroup)'];
      ds.bestbin.counts=[ds.bestbin.counts;[counts(togroup,1),counts(togroup,2)]];
      for(j=togroup(2:end))
        ds.bestbin.alldisclabelcat(end+1,:)=[0 ds.selectedClust(j)];
        ds.bestbin.alldiscpatchimg{end+1}=reshape([1 1 1],1,1,[]);
        ds.bestbin.decision(end+1)=0;
        ds.bestbin.isgeneral(end+1)=1;
        ds.bestbin.group(end+1)=1;
      end
    end
    ds.bestbin.affinities=affinities;
    dispres_discpatch;
    ds.bestbin.bbgrouphtml=ds.bestbin.bbhtml;
    ds.bestbin.bbhtml=bbhtmlorig;
    dsmv('ds.bestbin',['ds.bestbin_' disptype{k}]);
    if(dsfield(ds,'dispoutpath')),dssymlink(['ds.bestbin_' disptype{k}],[ds.dispoutpath]);end
  end
  dssave;
  dsclear(['ds.bestbin_' disptype{k}]);
  

  
end
end