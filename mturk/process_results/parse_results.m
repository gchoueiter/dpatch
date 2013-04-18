%%%
% This takes results files for the cluster task,
% parses the results, and saves the data to mat files.
%
%%
function parse_results(results_file, save_dir, numC)
try
addpath(genpath('/home/gen/dpatch/'))
% change this if you don't want to use SGE to calc patch models
isparallel = 1;
log_path = '/data/hays_lab/finder/Discriminative_Patch_Discovery/grid_out';

fid = fopen(results_file);
results = textscan(fid, ['%q%q%*q%*q%*q%*q%*q%*q%*q%*q%*q%*q%*q%*q%*q%*' ...
                    'q%*q%*q%q%q%*q%*q%q%q%*q%*q%*q%*q%*q%q%q%q']);
fclose(fid);
for i = 1:length(results)
    firstLine{i} = results{i}{1};
end
baseurlInd = find(cellfun(@(x) strcmp('Answer.baseurl',x), firstLine));
resultsInd = find(cellfun(@(x) strcmp('Answer.results',x), firstLine));
assignmentIdInd = find(cellfun(@(x) strcmp('assignmentid',x), ...
                               firstLine));
acceptTimeInd = find(cellfun(@(x) strcmp('assignmentaccepttime',x), ...
                             firstLine));
submitTimeInd = find(cellfun(@(x) strcmp('assignmentsubmittime',x), ...
                             firstLine));
workerIdInd = find(cellfun(@(x) strcmp('Answer.workerId',x), ...
                             firstLine));
cat_str_prefix = 'http://cs.brown.edu/~gen/nn_patches/';
cat_str = results{baseurlInd}{2}(length(cat_str_prefix)+1:end);
[cat_str, rem] = strtok(cat_str,'/');
cat_str

% TODO: change this to make a results dir for each cat
if ~exist(fullfile(save_dir, cat_str))
    mkdir(fullfile(save_dir, cat_str))
end
save(fullfile(save_dir, cat_str, [cat_str '_mturk_raw_results.mat']), 'results');

% make the results into images to look at
selectedImages = cellfun(@(x) regexp(x, ',','split'), results{resultsInd}(2:end), ...
                         'UniformOutput', false);
selectedPatches = cellfun(@(x) cellfun(@(y) strrep(y, '.jpg',''), ...
                                                x, 'UniformOutput', false), ...
                                        selectedImages, 'UniformOutput', false);
imgPre = 'http://cs.brown.edu/~gen/';
imgPreF = '/home/gen/www/';
patchJpgFs = cellfun(@(x,z) cellfun(@(y) [imgPreF x(length(imgPre)+1:end) ...
                   y], z, 'UniformOutput', false), results{baseurlInd}(2:end), ...
                    selectedImages, 'UniformOutput', false);
patchImgs = cellfun(@(x) cell2mat(cellfun(@(y) imread(y), x, 'UniformOutput', false)), ...
                    patchJpgFs, 'UniformOutput', false);

% write images
selectedPsSaveName = cellfun(@(x,y) [imgPreF x(length(imgPre)+1:end) ...
                    'selectedPatches_' y '.jpg'], results{baseurlInd}(2:end), ...
                             results{assignmentIdInd}(2:end), 'UniformOutput', false);
cellfun(@(x,y) imwrite(x, y), patchImgs, selectedPsSaveName, 'UniformOutput', ...
        false) 

% write html to look at results
[html]=htmlimagetable(selectedPsSaveName);

fhtml = fopen( fullfile('/home/gen/www/nn_patches/', cat_str,['results.html']), 'w');
fwrite(fhtml, html, 'uchar');
fclose(fhtml);

% convert accept time and submit time to 
% date ex: 'Mon Apr 08 21:10:46 EDT 2013' - 'ddd mmm dd HH:MM:SS EDT yyyy'
acceptTime = cellfun(@(x) datevec(strrep(x, 'EDT ', ''), ['ddd mmm dd HH:' ...
                    'MM:SS yyyy']), results{acceptTimeInd}(2:end), 'UniformOutput', false);
sumbitTime =  cellfun(@(x) datevec(strrep(x, 'EDT ', ''), ['ddd mmm dd HH:' ...
                    'MM:SS yyyy']), results{submitTimeInd}(2:end), 'UniformOutput', ...
                      false);

timeSpent = etime(cell2mat(sumbitTime), cell2mat(acceptTime));

% % plot num workers vs. time per hit
% figure
% plot(timeSpent, '*')
% figure
% hist(timeSpent)
% % plot hist of hits done
% figure
[uniqueWorkers uwi_ind uwj_ind] = unique(results{workerIdInd}(2:end));
numHitsDone = hist(uwj_ind, length(uniqueWorkers));
[max_hits, max_i] = max(numHitsDone);
disp(['max num hits done: ' num2str(max_hits(1)) ' by ' uniqueWorkers{max_i(1)}]);
% plot(d, 'r*')

% make a list of 'good workers' work time >= avg time - stddev
%find hit times for each worker
hitTimesPerWorker = arrayfun(@(x) timeSpent(x == uwj_ind), [1:length(uniqueWorkers)], ...
                            'UniformOutput', false);
%avg hit times for each worker
avgHitTimesPerWorker = cell2mat(cellfun(@(x) mean(x), hitTimesPerWorker, ...
                                        'UniformOutput', false));
%avg time overall
avgHitTime = mean(avgHitTimesPerWorker);
%stddev overall
stdHitTime = std(avgHitTimesPerWorker);

%mask of worker's who's avg time is less than one stddev
badTimeWorkers = avgHitTimesPerWorker < (avgHitTime - stdHitTime);
disp(['number of bad workers by time : ' num2str(sum(badTimeWorkers))]);

% make the results into just numbers
% check for overlap of selection - condense non-overlapping clusters
% find the intersect of all the selectedPatches from each cluster
% (interset has >=3 intersect points) 
% if the selectedPatches(i) has no overlap also keep it ( <3 same points
clustInds = reshape(repmat([1:numC], 3,1), numC*3, 1);
votesForImagePos = zeros(25,1);
for i = 1:numC
    resp = selectedPatches(clustInds == i);

    %mark the votes for image positions
    for respind = 1:length(resp)
        imgNums = cell2mat(cellfun(@(x) str2num(x),resp{respind},'UniformOutput', ...
                                   false));
        votesForImagePos(imgNums) = votesForImagePos(imgNums)+1;
    end
    j = 1;
    inds = 1:length(resp);
    didInter = zeros(length(resp));
    for outer = inds
        for inner = inds(inds ~= outer)
            inter = intersect(resp{outer}, resp{inner});
            if length(inter) >= 3
                nonOverlapClusters{i}{j} = inter;
                j = j+1;
                didInter(outer,inner) = 1;
            end
        end
    end
    didntInter = ~sum(didInter);
    if sum(didntInter) == length(resp)
        tempClust = resp(didntInter);
    else
        tempClust = [nonOverlapClusters{i}(:); resp(didntInter)];
    end
    [~, uinds] = unique(cellfun(@(x) sprintf('%s,',x{:}), tempClust, ...
                                'UniformOutput', false));    
    nonOverlapClusters{i} = tempClust(uinds);
    %    keyboard
end

save(fullfile(save_dir, cat_str, [cat_str '_mturk_parsed_results.mat']), 'results', ...
              'selectedPatches', 'timeSpent', 'uniqueWorkers', 'numHitsDone', ...
              'hitTimesPerWorker', 'avgHitTimesPerWorker', 'avgHitTime', ...
              'stdHitTime', 'badTimeWorkers', 'nonOverlapClusters', 'votesForImagePos');


numFinDets = 0;
tic;
while(numFinDets < sum(cellfun(@(x) length(x), nonOverlapClusters))*4)
    % train an svm on each
    train_patches;

    % check that all patch models are calculated 
    cat_dir = ['/data/hays_lab/finder/' ...
                        'Discriminative_Patch_Discovery/15_scene_patches/' ...
                        'nearestneighbors/' cat_str '/' ...
               'autoclust_main_nn_only_out/'];
    [status,jobs] = system('qstat -q short.q |wc -l');
    while(str2num(jobs) > 0)
        disp('...');
        pause(10);
        [status,jobs] = system('qstat -q short.q |wc -l');
    end
    disp('finished this round');
    finDets = subdir([cat_dir 'cluster_detectors/*.mat']);
    numFinDets = length(finDets)
    toc;
end

% load all patch models for different kernel types
kernel_types{1}.name = 'linear';
kernel_types{1}.t = '0';
kernel_types{2}.name = 'polynomial';
kernel_types{2}.t = '1';
kernel_types{3}.name = 'rbf';
kernel_types{3}.t = '2';
kernel_types{4}.name = 'sigmoid';
kernel_types{4}.t = '3';
params= struct( ...
  'imageCanonicalSize', 400,...% images are resized so that their smallest dimension is this size.
  'patchCanonicalSize', {[80 80]}, ...% patches are extracted at this size.  Should be a multiple of sBins.
  'scaleIntervals', 8, ...% number of levels per octave in the HOG pyramid 
  'sBins', 8, ...% HOG sBins parameter--i.e. the width in height (in pixels) of each cell
  'useColor', 1, ...% include a tiny image (the a,b components of the Lab representation) in the patch descriptor
  'patchOverlapThreshold', 0.6, ...%detections (and random samples during initialization) with an overlap higher than this are discarded.
  'svmflags', '');
detectionParams = struct( ...
  'selectTopN', false, ...
  'useDecisionThresh', true, ...
  'overlap', 0.4, ...% detections with overlap higher than this are discarded.
  'fixedDecisionThresh', -1.002);

%functions later won't work without this
%global ds;
ds.conf.params = params;
dssetout(cat_dir);
% load valset images - make them a cell array of double mats
tic;
load('/home/gen/dpatch/dataset15.mat'); 
scene_cats=unique(arrayfun(@(x) x.city,imgs,'UniformOutput', ...
                           false));
imgs_train=[]; 
for i = 1:length(scene_cats)
train_inds = find(~arrayfun(@(x) isempty(strfind(x.city, scene_cats{i})), ...
                     imgs));
train_inds = train_inds(1:150);
imgs_train = horzcat(imgs_train, imgs(train_inds));
end
imgs=imgs_train;
valset_inds = 1:2:length(imgs);
ds.myiminds = 1:length(valset_inds);
for vi = 1:length(valset_inds)
    valset{vi} = im2double(imread(imgs(vi).fullpath));
end
toc;
iscatimg =ismember({imgs(valset_inds).city},cat_str);
%ds.ispos = iscatimg;

for kt = 1:length(kernel_types)
    idx = 1;
    for clusterNum = 1:length(nonOverlapClusters)
        for selectNum = 1:length(nonOverlapClusters{clusterNum})
            selectedPatches = sprintf('%s-',nonOverlapClusters{clusterNum}{selectNum}{:});

            load(fullfile(cat_dir, 'cluster_detectors', ['cluster' num2str(clusterNum)], ...
                   [selectedPatches kernel_types{kt}.name '.mat']));
            clustDets{idx}=model;
            %ds.batch.round.firstResult{dsidx} = struct('predictedLabels',
            %predictedLabels, 'accuracy', accuracy, 'decision', decision);

            idx = idx+1;
        end
    end
    params.svmflags = ['-t ' kernel_types{kt}.t ' -s 0 -c 0.1'];
    
    dets=VisualEntityDetectors(clustDets, params);
    
    %%%%%% THIS PART TAKES FOREVER - probably need to start ds parallel
    %%%%%% jobs and work with that system.
    %%%%%% TODO: rewrite this so it uses your feature extractor. Compare
    %%%%%% your feature extractor to the one in detectPresenceUsingEntDet
    % % get posterior score:
    % %for all images in the val set, run detectPresence (this applies all
    % %detectors to images)
    % for imind = 1:length(valset)
    %     ds.detsimple{imind}=simplifydets(dets.detectPresenceInImg(valset{imind},detectionParams),imind);
    % end
    % maxdet=size(dets.firstLevModels.w,1);
    % [topn,posCounts,negCounts]=readdetsimple(maxdet,-.2,struct('oneperim',1, ...
    %                                               'issingle',1,'nperdet', ...
    %                                               250, 'imgs', imgs(valset_inds)));
    % alldetections=[topn{1}(:);topn{2}(:)]';
    % for(i=unique([alldetections.detector]))
    %   counts(i,1)=sum(posCounts{1}(i,:));
    %   counts(i,2)=sum(negCounts(i,:));
    % end
    % post=(counts(:,1)+1)./(sum(counts,2)+2)

    % % sort them by  posterior score 
    % [~,detord]=sort(post,'descend');

    % % check for overlap
    % [overl groups affinities]=findOverlapping(dets(detord),struct('findNonOverlap',1));
    % save dictionary
    data = dets;
    save(fullfile(cat_dir, 'cluster_detectors',['detsDclust_' ...
                        kernel_types{kt}.name '.mat']),'data', '-v7.3');
    % print webpage of sorted detectors with their outputs

end

catch e
    disp(e.message);
    keyboard
end
end
