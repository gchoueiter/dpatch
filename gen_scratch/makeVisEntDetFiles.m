% script for taking cell arrays of dpatch dectors and turning them into
% VisualEntityDetectors

fdir = ['/data/hays_lab/finder/Discriminative_Patch_Discovery/' ...
        '15_scene_patches/'];
fnames{1} = fullfile(fdir, 'nearestneighbors' , 'detectors_linear.mat');
fnames{2} = fullfile(fdir, 'nearestneighbors' , 'detectors_polynomial.mat');
fnames{3} = fullfile(fdir, 'nearestneighbors' , 'detectors_rbf.mat');
fnames{4} = fullfile(fdir, 'nearestneighbors' , 'detectors_sigmoid.mat');
fnames{5} = fullfile(fdir, 'overallcounts' , 'detectors.mat');
fnames{6} = fullfile(fdir, 'posterior' , 'detectors.mat');

params= struct( ...
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


for fn = 1:length(fnames)
    clear detectors
    load(fnames{fn});
    
    models = {};
    for i = 1:length(detectors.firstLevModels.info)
        models{i}.w = detectors.firstLevModels.w(i,:);
        models{i}.rho = detectors.firstLevModels.rho(i,1);
        models{i}.firstLabel = detectors.firstLevModels.firstLabel(i,1);
        models{i}.info = detectors.firstLevModels.info{i};
        models{i}.threshold = detectors.firstLevModels.threshold(i,1);
    end

    detectors = VisualEntityDetectors(models, params);

    disp([fnames{fn}(1:end-4) '_visentdet.mat length = ' num2str(length(detectors.firstLevModels.info))]);
    save([fnames{fn}(1:end-4) '_visentdet.mat'],'detectors');

end