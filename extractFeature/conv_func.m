% this is a slightly different version of TY_conv_func
%  This runs the conv_func on the input image with the dpatch
%  specified by patch_ind
function [feat, imsize] = conv_func(img, imgsHome, npatch, patch_ind, params);
%   img:    the input image
%   npatch: n dpatch models
%   patch_ind: index of patch to use from npatch
%   params: the params from DPatch discovery code

global ds; 


% This is the test case
if nargin == 0
    %% load test model
    img = im2double(imread('/data/hays_lab/15_scene_dataset/store/image_0010.jpg'));
    %figure(2)
    %imshow(img)
    disp('proof of img');
    img(1:2,1:2,:)

    %parameters for Saurabh's code
    params= struct( ...
      'imageCanonicalSize', 400,...% images are resized so that their smallest dimension is this size.
      'patchCanonicalSize', {[80 80]}, ...% patches are extracted at this size.  Should be a multiple of sBins.
      'scaleIntervals', 4, ...% number of levels per octave in the HOG pyramid 
      'sBins', 4, ...% HOG sBins parameter--i.e. the width in height (in pixels) of each cell
      'useColor', 1, ...% include a tiny image (the a,b components of the Lab representation) in the patch descriptor
      'patchOverlapThreshold', 0.6, ...%detections (and random samples during initialization) with an overlap higher than this are discarded.
      'svmflags', '-s 0 -t 0 -c 0.1', ...
      'numLevel', 3);
    ds.conf.params = params;

    ds.conf.detectionParams = struct( ...
  'selectTopN', false, ...
  'useDecisionThresh', true, ...
  'overlap', 0.4, ...% detections with overlap higher than this are discarded.
  'fixedDecisionThresh', -1.002);    
    
    numLevel = params.numLevel;
    
    detectors = load('/data/hays_lab/finder/Discriminative_Patch_Discovery/try2/CALsuburb]/autoclust_main_15scene_out/ds/batch/round6/detectors.mat');
%load('detectors.mat'); % detector can be found at ds.batch.round{k}.detectors.mat
    detectors = detectors.data;
    npatch = detectors.firstLevModels;
    patch_ind = 1;
end

feats = constructFeaturePyramid(img, params);  % reuse the code from dpatch 

for numDet = patch_ind
    %keyboard
    w = reshape(full(npatch.w(numDet,:)), [8,8,33]);  % current patch discovery code has 31 (hog) + 2 (color) dims features
    rho = npatch.rho(numDet);
    numDim = size(feats.features{1}, 3);


    %% tylin's detection
    numDim = size(w, 3);
    % conv between the svm model and features in pyramid
    
    for lev = 1 : length(feats.scales)
        row = size(feats.features{lev}, 1);
        col = size(feats.features{lev}, 2);
        
        res{lev} = zeros(row, col);
        for i = 1 : numDim
            res{lev} = res{lev} + conv2(feats.features{lev}(:,:,i), w(:,:, i), 'same');
        end

        res{lev} = res{lev} - rho * ones(size(res{lev}));
    end
    
    % output feat:
    % feat{# of det}.svmout{# of pyramid level}
    feat.svmout = res;
    
%     % visualization
%     % comment this when it is ready to run
%     figure(1);
%     imagesc(res{1});
%     hold on;
%     [I, J] = find(res{1} > -1.002);
%     I
%     if ~isempty(I)
%         plot(J, I, 'bo');
%     end
%     axis image
%     axis off
%     colorbar()
%     wait = waitforbuttonpress;
end


feat.scales = feats.scales;
imsize = size(img);

end
