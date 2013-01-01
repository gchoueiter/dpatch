function [feat, imsize] = TY_conv_func(img, npatch, params);
%   img:    the input image
%   npatch: n models
%   params: the params from DPatch discovery code
global ds;
if nargin == 0
    %% load test model
    img = im2double(imread('C:\Users\tsungyi\Documents\GitHub\dpatch\15_scene_dataset\store\image_0010.jpg'));
    figure(2)
    imshow(img)
    
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
    
    detectors = load('detectors.mat'); % detector can be found at ds.batch.round{k}.detectors.mat
    detectors = detectors.data;
    npatch = detectors.firstLevModels;
    
end

% dets = detectors.detectPresenceInImg(img);
tic

feats = constructFeaturePyramid(img, params);  % reuse the code from dpatch    
for numDet = 1 : 600
    w = reshape(full(npatch.w(numDet,:)), [8,8,33]);  % current patch discovery code has 31 (hog) + 2 (color) dims features
    rho = npatch.rho(numDet);
%     feats = constructFeaturePyramidForImg(img, params, 1:numLevel);  % reuse the code from dpatch
    numDim = size(feats.features{1}, 3);

    % sanity check
%     [features, levels, indexes, gradsums] = unentanglePyramid(feats, params.patchCanonicalSize);
    
    % %% compute template model and feature pyramid from dpatch code
    % 
    % % from dpatch code
    % ds.conf.params = params;
    % detectionParams = struct( ...
    %           'selectTopN', false, ...
    %           'useDecisionThresh', true, ...
    %             'overlap', .5,...%collatedDetector.params.overlapThreshold, ...
    %               'fixedDecisionThresh', -.7,...
    %               'removeFeatures',1);
    % detections = getDetectionsForEntDets(detectors.firstLevModels, feat, ...
    %     params.patchCanonicalSize, detectionParams,img);
    % % detections = getDetectionsForEntDets(detectors.firstLevel, pyra, ...
    % %     params.patchCanonicalSize, detectionParams,im);
    % % 
    % % results.firstLevel = constructResults(detections, ...
    % %   detectionParams.removeFeatures);

    %% tylin's detection
%     w_sum = sum(w(:));
    numDim = size(w, 3);
%     % normalize feature
%     % dpatch code normalizes feature by mean subtraction and variance
%     % normalization of 8x8x33 features
%     % we compute mean (mu) and standard deviation (sigma) of each patch in
%     % input image
%     for lev = 1 : numLevel
%         row = size(feats.features{lev}, 1);
%         col = size(feats.features{lev}, 2);
%         % use convolution to compute mean and var
%         X = zeros(row, col);
%         X2 = zeros(row, col);
%         for i = 1 : numDim
%             X = X + conv2(feats.features{lev}(:,:, i), ones(8,8) * (1/64) * (1/numDim), 'same');
%             X2 = X2 + conv2(feats.features{lev}(:,:, i).^2, ones(8,8) * (1/64) * (1/numDim), 'same');
%         end
%         X_std = sqrt(X2 - X.^2);
%         mu{lev} = X;
%     %     sigma{lev} = (X_std * (8*8*numDim) );
%         sigma{lev} = X_std ;
%     end

    % conv between the svm model and features in pyramid
    
    for lev = 1 : length(feats.scales)
        row = size(feats.features{lev}, 1);
        col = size(feats.features{lev}, 2);
        
        res{lev} = zeros(row, col);
        for i = 1 : numDim
            res{lev} = res{lev} + conv2(feats.features{lev}(:,:,i), w(:,:, i), 'same');
        end
%         res{lev} = (res{lev} - w_sum*mu{lev})./ sigma{lev} - rho * ones(size(res{lev}));
        res{lev} = res{lev} - rho * ones(size(res{lev}));
    end
    
    % output feat:
    % feat{# of det}.svmout{# of pyramid level}
    feat{numDet}.svmout = res;
    
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
toc
feat.scales = feats.scales;

end