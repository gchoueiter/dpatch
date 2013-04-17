% This makes *one* dpatch model in the same format as CMU Singh and Doersch
% code - VisualEntityDetectors
% From mturk responses
%note:all args should be strings
function makeIndvDet(cat_str, clusterNum, selectedPatches)

addpath(genpath('/home/gen/libsvm-mat-3.0-1/'))
addpath(genpath('/home/gen/dpatch/'));

%clusterNum = str2num(clusterNum);
sP = textscan(selectedPatches,'%d-');
sP = sP{1};

% This needs to be changed if the features for the negative set are
% elsewhere
cat_dir = ['/data/hays_lab/finder/' ...
                    'Discriminative_Patch_Discovery/15_scene_patches/' ...
                    'nearestneighbors/' cat_str '/autoclust_main_nn_only_out/'];
initFeatsNeg = load([cat_dir 'ds/' ...
                    'initFeatsNeg.mat']);
initFeatsNeg = initFeatsNeg.data;
for p = 1:length(sP)
    % I made a mistake saving cluster feats to the right names, so they
    % are all in cluster(#num)/(#img+[#num-1]*100).mat
    %keyboard
    load([cat_dir 'cluster_feats/cluster' clusterNum ...
                       '/' num2str(sP(p)+(str2num(clusterNum)-1)*100) '.mat']);
    sPFeats(p,:) = feat;
end

% using default libsvm gamma and coef0 
kernel_types{1}.name = 'linear';
kernel_types{1}.t = '0';
kernel_types{2}.name = 'polynomial';
kernel_types{2}.t = '1';
kernel_types{3}.name = 'rbf';
kernel_types{3}.t = '2';
kernel_types{4}.name = 'sigmoid';
kernel_types{4}.t = '3';

% load feats and labels

labels = [ones(length(sP), 1); ...
ones(size(initFeatsNeg, 1), 1) * -1];
features=[sPFeats; initFeatsNeg];

% set params for dpatch model
params= struct( ...
  'imageCanonicalSize', 400,...% images are resized so that their smallest dimension is this size.
  'patchCanonicalSize', {[80 80]}, ...% patches are extracted at this size.  Should be a multiple of sBins.
  'scaleIntervals', 8, ...% number of levels per octave in the HOG pyramid 
  'sBins', 8, ...% HOG sBins parameter--i.e. the width in height (in pixels) of each cell
  'useColor', 1, ...% include a tiny image (the a,b components of the Lab representation) in the patch descriptor
  'patchOverlapThreshold', 0.6, ...%detections (and random samples during initialization) with an overlap higher than this are discarded.
  'svmflags', '');

for kt = 1:length(kernel_types)
    %set params
    
    params.svmflags = ['-t ' kernel_types{kt}.t ' -s 0 -c 0.1'];

    % train svm
    % run prediction
    % save model and decisions
    fprintf('Training SVM ...  ');
    size(labels)
    size(features)
    kernel_types{kt}.name
    model = mySvmTrain(labels, features, params.svmflags, true);
    [predictedLabels, train_accuracy, train_decision] = mySvmPredict(labels, ...
                                           features, model);
    %TODO:this is wrong!!    
    % inCatDets = sum(train_decision(1:length(sP))>-.2);
    % outCatDets = sum(train_decision(length(sP)+1:end)>-.2);
    % if inCatDets == 0
    %     posterior = 0;
    % else
    %     posterior = inCatDets/(inCatDets+outCatDets);
    % end
    %    posterior = (sum(train_decision(1:length(sP))>-.2) +1)/...
    %    (sum(train_decision(1:length(sP))>-.2)+sum(train_decision(length(sP)+1:end)>-.2) +2);

    % save model and prediction results 
    if ~exist(fullfile(cat_dir, 'cluster_detectors', ['cluster' clusterNum]), 'dir')
        mkdir(fullfile(cat_dir, 'cluster_detectors', ['cluster' clusterNum]));
    end
    save( fullfile(cat_dir, 'cluster_detectors', ['cluster' clusterNum], ...
                   [selectedPatches kernel_types{kt}.name '.mat']),...
                   'model', 'train_accuracy', 'train_decision', 'predictedLabels');
 
end

end