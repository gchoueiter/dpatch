% this is to restart some autoclust dsmapreduce process that has been
% stopped
%dsinterrupt;
dsmapredopen(nprocs, 1, ~isdistributed);


while((ds.batch.nextClust<=numel(ds.selectedClust)||size(ds.batch.round.posFeatures,1)>0))
    {'ds.batch.round.curriter','j'};dsup;
    stopfile=[ds.prevnm '_stop'];
    if(exist(stopfile,'file'))
      %lets you stop training and just output the results so far
      break;
    end
    pausefile=[ds.prevnm '_pause'];
    if(exist(pausefile,'file'))
      keyboard;
    end

    %choose which candidate clusters to start working on
    ntoadd=ds.conf.processingBatchSize-numel(ds.batch.round.selectedClust);
    rngend=min((ds.batch.nextClust+ntoadd-1),numel(ds.selectedClust));
    newselclust=ds.selectedClust(ds.batch.nextClust:rngend);
    newfeats=find(ismember(ds.assignedClust,newselclust));
    {'ds.batch.round.posFeatures','[ds.batch.round.posFeatures; ds.initFeats(newfeats,:)]'};dsup;
    {'ds.batch.round.assignedClust','[ds.batch.round.assignedClust ds.assignedClust(newfeats)]'};dsup;
    {'ds.batch.round.selectedClust','[ds.batch.round.selectedClust newselclust]'};dsup;
    {'ds.batch.round.selClustIts','[ds.batch.round.selClustIts zeros(size(newselclust))]'};dsup;
    {'ds.batch.nextClust','ds.batch.nextClust+ntoadd'};dsup;

    %choose the training/validation sets for the current round
    nsets=3;
    jidx=mod(j-1,nsets)+1;
    jidxp1=mod(j,nsets)+1;
    currtrainset=ds.myiminds([jidx:nsets:numel(ds.parimgs) (numel(ds.parimgs)+j):7:numel(ds.myiminds)]);
    currvalset=ds.myiminds([jidxp1:nsets:numel(ds.parimgs) (numel(ds.parimgs)+j+1):7:numel(ds.myiminds)]);
    {'ds.batch.round.totrainon','currtrainset'};dsup;
    {'ds.batch.round.tovalon','currvalset'};dsup;
    
    %initialize the SVMs using the random negative patches
    dsmapreduce('autoclust_initial',{'ds.batch.round.selectedClust'},{'ds.batch.round.firstDet','ds.batch.round.firstResult'});
    dets=VisualEntityDetectors(ds.batch.round.firstDet, ds.conf.params);
    {'ds.batch.round.detectors','dets'};dsup;

    %Use the hard negative mining technique to train on negatives from the current negative set
    istrain=zeros(numel(ds.imgs{ds.conf.currimset}),1);
    istrain(ds.batch.round.totrainon)=1;
    allnegs=find((~ds.ispos(:))&istrain(:));
    currentInd = 1;
    maxElements = length(allnegs);
    iter = 1;
    startImgsPerIter = 15;
    alpha = 0.71;
    if(~dsfield(ds,'batch','round','mineddetectors'))
      dsdelete('ds.batch.round.negmin');
      while(currentInd<=maxElements)
        imgsPerIter = floor(startImgsPerIter * 2^((iter - 1)*alpha));
        finInd = min(currentInd + imgsPerIter - 1, maxElements);
        {'ds.batch.round.negmin.iminds','allnegs(currentInd:finInd)'};dsup;
        conf.noloadresults=1;
        dsmapreduce('autoclust_mine_negs',{'ds.batch.round.negmin.iminds'},{'ds.batch.round.negmin.imageflags'},struct('noloadresults',1));
        dsmapreduce('autoclust_train_negs',{'ds.batch.round.selectedClust'},{'ds.batch.round.nextnegmin.traineddetectors'},struct('noloadresults',1));
        dsload('ds.batch.round.nextnegmin.traineddetectors');

        dets = VisualEntityDetectors(ds.batch.round.nextnegmin.traineddetectors, ds.conf.params);
        {'ds.batch.round.detectors','dets'};dsup;
        dssave();
        dsdelete('ds.batch.round.negmin');
        dsmv('ds.batch.round.nextnegmin','ds.batch.round.negmin');
        iter=iter+1;
        currentInd=currentInd+imgsPerIter;
      end
      dsdelete('ds.batch.round.negmin');
    end
    {'ds.batch.round.iminds','[ds.batch.round.totrainon; ds.batch.round.tovalon]'};dsup;
    {'ds.batch.round.mineddetectors','dets'};dsup;
    pausefile=[ds.prevnm '_pause'];
    if(exist(pausefile,'file'))
      keyboard;
    end

    %run detection on both the training and validation sets
    dsmapreduce('autoclust_detect',{'ds.batch.round.iminds'},{'ds.batch.round.detectorflags'},struct('noloadresults',1));

    %find the top detections for each detector
    conf2.allatonce=true;
    dsmapreduce('autoclust_topn',{'ds.batch.round.selectedClust'},{'ds.batch.round.traintopN','ds.batch.round.validtopN','ds.batch.round.alltopN'},conf2);
    validtopN=ds.batch.round.validtopN;
    traintopN=ds.batch.round.traintopN;


    %extract the top 5 from the validation set for the next round
    [posFeatures, positivePatches, ...
      posCorrespInds, posCorrespImgs, assignedClustVote, ...
      assignedClustTrain, selectedClusters] = ...
      prepareDetectedPatchClusters(validtopN, ...
        10, 5, ds.conf.params, ds.batch.round.tovalon(logical(ds.ispos(ds.batch.round.tovalon))), ds.batch.round.selectedClust);
      currdets=simplifydets(positivePatches,posCorrespImgs,assignedClustTrain);
    %extract the top 100 and display them
    [~, positivePatches2, ...
      ~, posCorrespImgs2,~,assignedClustTrain2] = ...
      prepareDetectedPatchClusters(ds.batch.round.alltopN, ...
        100, 100, ds.conf.params, ds.batch.round.tovalon, ds.batch.round.selectedClust);
    dispdets=simplifydets(positivePatches2,posCorrespImgs2,assignedClustTrain2);
    %end
    dispdetscell={};
    dispdetscellv2={};
    for(i=1:numel(ds.batch.round.selectedClust))
      mydispdets=dispdets([dispdets.detector]==ds.batch.round.selectedClust(i));
      [~,ord5]=sort([mydispdets.decision],'descend');
      dispdetscell{i}=mydispdets(ord5([1:10 15:7:min(numel(ord5),100)]));
      dispdetscell{i}=dispdetscell{i}(:)';
    end
    dispdets=cell2mat(dispdetscell)';

    %Up until this point in the while loop, if the program crashes (e.g. due
    %to disk write failures) you can just restart it at line 286 and the
    %right thing should happen. After this point, however,
    %the program starts performing updates that shouldn't happen twice.

    dsmv('ds.bestbin_topn','ds.bestbin');  
    prepbatchwisebestbin(dispdets,j+2,100,[1:10 15:7:100]);
    dispres_discpatch;
    dsmv('ds.bestbin','ds.bestbin_topn');
    dssave;
    ds.bestbin_topn.alldiscpatchimg=cell(size(ds.bestbin_topn.alldiscpatchimg));

    tooOldClusts=ds.batch.round.selectedClust(ds.batch.round.selClustIts>=num_train_its);
    ds.sys.savestate.thresh=[];
    finished=find(ismember(ds.batch.round.selectedClust,intersect(selectedClusters,tooOldClusts)));
    ds.findetectors{j}=selectDetectors(ds.batch.round.detectors,finished);
    ds.finSelectedClust{j}=ds.batch.round.selectedClust(finished(:)');

    %store stuff (finished detectors, top detections etc.) for next round 
    {'ds.batch.nFinishedDets','ds.batch.nFinishedDets+size(ds.findetectors{j}.firstLevModels.w,1)'};dsup;
    selectedClusters=setdiff(selectedClusters,tooOldClusts);
    markedAssiClust=ismember(ds.batch.round.assignedClust, selectedClusters);
    markedAssiClust=ismember(assignedClustTrain, selectedClusters);
    assignedClustTrain=assignedClustTrain(markedAssiClust);
    posFeatures=posFeatures(markedAssiClust,:);
    [~,indstokeep]=ismember(selectedClusters,ds.batch.round.selectedClust);
    indstokeep(indstokeep==0)=[];
    selClustIts=ds.batch.round.selClustIts(indstokeep)+1;
    dssave;
    dsdelete('ds.batch.round.topdetsmap');
    dsmv('ds.batch.round',['ds.batch.round' num2str(j)])%create a backup
    dssave();
    {'ds.batch.round.posFeatures','posFeatures'};dsup;
    {'ds.batch.round.assignedClust','assignedClustTrain'};dsup;
    {'ds.batch.round.selectedClust','selectedClusters(:)'''};dsup;
    {'ds.batch.round.selClustIts','selClustIts'};dsup;
    dssave();
    eval(['ds.batch.round' num2str(j) '=struct();']);%remove the backup from memory
    j=j+1;
end
toc(maintic);
dets=collateAllDetectors2(ds.findetectors);
{'ds.selectedClust','cell2mat(ds.finSelectedClust)'};dsup;
dssave;
{'ds.dets','dets'};dsup;

%run the detectors on the entire dataset to compute purity/overlap
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
for k=1:numel(disptype)
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
      %      k = 1; 
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
  
  % pause
  % copy everything from the k = 1 directory into the k = 2 directory and change the output path   
  if(k==1)
      stat = 1;
      while(stat > 0.1)
        pause(5)
        stat = system(['cp -rf ' patch_dir{k} '/' cat_str '/ ' patch_dir{k+1} '/' cat_str '/ ']);
      end        
      dssetout([patch_dir{k+1} '/' cat_str '/'  ds.prevnm '_out']);
  end
  
end