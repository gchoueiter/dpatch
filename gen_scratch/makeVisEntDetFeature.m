%%%
% This function makes a raw dense Dpatch feature for the input image and type
% of detector. 
%%%

function [decision, levels, pyra] = makeVisEntDetFeature(img_name, img_path, save_path, detectors_fname,  detection_threshold, overwrite)

    % check if feat file exists, overwrite depending
if( exist(fullfile(save_path,[img_name(1:end-4) '_raw.mat']), ...
                      'file'))%~overwrite &
    disp(['Raw HOG feature was already calculated: ' img_name]);
    load(fullfile(save_path,[img_name(1:end-4) '_raw.mat']));
    return;
end
global ds

load(detectors_fname);
im = im2double(imread(fullfile(img_path, img_name)));

featParams= struct( ...
  'imageCanonicalSize', 400,...% images are resized so that their smallest dimension is this size.
  'patchCanonicalSize', {[80 80]}, ...% patches are extracted at this size.  Should be a multiple of sBins.
  'scaleIntervals', 8, ...% number of levels per octave in the HOG pyramid 
  'sBins', 8, ...% HOG sBins parameter--i.e. the width in height (in pixels) of each cell
  'useColor', 1, ...% include a tiny image (the a,b components of the Lab representation) in the patch descriptor
  'patchOverlapThreshold', 0.6, ...%detections (and random samples during initialization) with an overlap higher than this are discarded.
  'svmflags', '-s 0 -t 0 -c 0.1');

ds.conf.params = featParams;

detectionParams = struct( ...
  'selectTopN', false, ...
  'useDecisionThresh', true, ...
  'overlap', 0.4, ...% detections with overlap higher than this are discarded.
  'fixedDecisionThresh', detection_threshold);
[im, canoScale] = convertToCanonicalSize(im, ...
                                         featParams.imageCanonicalSize);
% HACK! check with James that this is the 'best' thing to do
%im = im(1:featParams.imageCanonicalSize,1:featParams.imageCanonicalSize);
pyra = constructFeaturePyramid(im, featParams);
%keyboard

[detections, decision, levels, indexes]  = getDetectionsForEntDets_AllPatches(detectors.firstLevModels, ...
                                                  pyra,detectors.params.patchCanonicalSize, ...
                                                  detectionParams,im);
%disp('at end of makeVisEntDetFeature()');
%keyboard

         save(fullfile(save_path,[img_name(1:end-4) '_raw.mat']), ...
              'decision', 'levels', 'pyra');
         %              'detections', 'decision', 'levels', 'indexes');



end