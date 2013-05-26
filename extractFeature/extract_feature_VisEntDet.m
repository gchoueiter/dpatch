% gen
%calculates dpatch feature using the VisualEntityDetector object and its member methods.
% the detectors saved in detectors_fname should be VisualEntityDetector

function extract_feature_VisEntDet(img_name, img_path, save_path, detectors_fname, njobs, isparallel, log_path)

% there are conflicting versions of some files, so this explicitly
% includes the correct versions
addpath('../');
addpath(genpath('../dswork'));
addpath(genpath('../crossValClustering'));
addpath(genpath('../hog'));
addpath(genpath('../extractFeature'));

%GVARS is a struct that holds variables used in the functions below
global GVARS

if nargin < 5
    njobs = 0;
    isparallel = 0;
    log_path ='.';
end

GVARS.save_path = save_path;

% variable that save busy state of jobs (0-free, 1-busy)
GVARS.rand = sprintf('%8d',floor(rand(1)*1e8));
GVARS.njobs = njobs;
%% TODO: load info about dpatch models
%GVARS.detectors_fname =
%'/data/hays_lab/finder/Discriminative_Patch_Discovery/try2/CALsuburb]/autoclust_main_15scene_out/ds/batch/round6/detectors.mat';
GVARS.detectors_fname = detectors_fname;

% load the dpatch library
load(GVARS.detectors_fname);
GVARS.detectors = detectors;
GVARS.detectionParams = struct( ...
  'selectTopN', false, ...
  'useDecisionThresh', true, ...
  'overlap', 0.4, ...% detections with overlap higher than this are discarded.
  'fixedDecisionThresh', -1.002);

%GVARS.img = im2double(imread([img_path img_name]));
GVARS.img_path = img_path;
%if(strcmp(img_name(end-3), '.'))
%    img_name = img_name(1:end-4);
%end
GVARS.img_name = img_name;

GVARS.save_path = fullfile(save_path,img_name(1:end-4),'/');
if(~exist(GVARS.save_path, 'dir'))
    mkdir(GVARS.save_path);
end

last_stroke = strfind(GVARS.img_name, '/');
last_stroke = last_stroke(end);
save_name = fullfile(GVARS.save_path, [GVARS.img_name(last_stroke:end-4) '.mat']);

if(exist(save_name, 'file'))
    disp(['this dpatch feature already calculated- ' save_name]);
    return;
end

GVARS.isparallel = isparallel;
GVARS.njobs = njobs;
GVARS.log_path = log_path;

feat = calc_feat();


%final_feats = maxpool(tmp_feats);


%keyboard
 save(save_name, 'feat');
 save(fullfile(save_path,[img_name(1:end-4) '.mat']), 'feat');




 disp('dpatch feature calculated!');
end



function feat = calc_feat()

  global GVARS

  feat = GVARS.detectors.detectPresenceInImg(im);

end

