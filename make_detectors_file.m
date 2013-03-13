% This script makes a file of the correct format for
% extractFeature/conv_func.
%
% detectors are the output of autoclust_main*.m 
%
% This creates a dictionary of the top N non-repetitive detectors
clear detectors
global ds;
myaddpath;

detectors_fname = 'detsDclust.mat';
data_path = '/data/hays_lab/finder/Discriminative_Patch_Discovery/try2/';
sub_path = 'autoclust_main_15scene_out/ds/';
dpatches_per_cat = 100;

% load sorted dets files from each category and cat all sub structures.
% find all category dirs
cat_paths = dir(data_path);
cat_paths = cat_paths(3:end);

for cat = 1:length(cat_paths)
    clear data
    fname = fullfile(data_path, cat_paths(cat).name, sub_path, ...
                     detectors_fname);
    try
    load(fname);
    % concat detectors - copy params (if not exist) and firstLevModels
    % data.firstLevModels
    %          w: [491x2112 double]
    %        rho: [491x1 double]
    % firstLabel: [491x1 double]
    %       info: {491x1 cell}
    %  threshold: [491x1 double]
    %       type: 'composite' 
    if(~exist('detectors','var'))
        detectors.params = data.params;
        fields = fieldnames(data.firstLevModels);
        detectors.firstLevModels = data.firstLevModels;
        for i=1:numel(fields)
            detectors.firstLevModels.(fields{i}) = detectors.firstLevModels.(fields{i})(1:min(size(detectors.firstLevModels.(fields{i}),1),dpatches_per_cat),:);
            
        end
    else
        fields = fieldnames(data.firstLevModels);

        for i=1:numel(fields)
            detectors.firstLevModels.(fields{i}) = vertcat(detectors.firstLevModels.(fields{i}),...
                                                           data.firstLevModels.(fields{i})(1:min(size(data.firstLevModels.(fields{i}),1),dpatches_per_cat),:));
            
        end
    end

    catch e
        disp(e.message);
    end
end

save(fullfile(data_path, 'detectors.mat'), 'detectors');