# NOTES: using the CMU VisEntDets to get detections on an image, only results in the highest detection for an image, not the spatial pyramid feature


# WHAT I WANT: a spatial pyramid feature for an image, where each element is the SVM confidence of the detector(i) firing at that location

# make VisualEntityDetectors files

  # load detectors
  # make 'models' cell array
models = {};
for i = 1:length(detectors.firstLevModels.info)
models{i}.w = detectors.firstLevModels.w(i,:);
models{i}.rho = detectors.firstLevModels.rho(i,1);
models{i}.firstLabel = detectors.firstLevModels.firstLabel(i,1);
models{i}.info = detectors.firstLevModels.info{i};
models{i}.threshold = detectors.firstLevModels.threshold(i,1);
end

 detectionParams = struct( ...
  'selectTopN', false, ...
  'useDecisionThresh', true, ...
  'overlap', 0.4, ...% detections with overlap higher than this are discarded.
  'fixedDecisionThresh', -1.002);

# calc features using VisEntDets

 [results] = data_test.detectPresenceUsingEntDet(im,detectionParams);
disp('adding image to metadata...');
for(i=1:numel(results.firstLevel.detections))
  for(j=1:numel(results.firstLevel.detections(i).metadata))
    results.firstLevel.detections(i).metadata(j).im = im_fname;
  end
end

# detections is the max detection for each det for each img
# decision is the spatial pyramid response
# levels is the pyramid levels
# indexes is something from the unentanglePyramid function...
[detections, decision, levels, indexes]  = getDetectionsForEntDets(data_test.firstLevModels, pyra,detectors.params.patchCanonicalSize, detectionParams,im);
# change scene_classification code to take new features 
# maybe try to visualize firing - ie get top dets for a given dpatch

# calc scene class numbers
