% This script makes a file of the correct format for
% extractFeature/conv_func.
%
% detectors are the output of autoclust_main*.m 
%
% This creates a dictionary of the top N non-repetitive detectors
% set rank = 1 or 2 or 3  :
% detectors_fname = 'detsDclust.mat' or if rank == 3: 'detsDclust_linear.mat' or
% 'detsDclust_polynomial.mat' or 'detsDclust_rbf.mat' or 'detsDclust_sigmoid.mat'
clear detectors
global ds;
myaddpath;
ranking_type = {'overallcounts', 'posterior', 'nearestneighbors'};
%% must supply this!!!! 
%detectors_fname = 'detsDclust.mat';
data_path = ['/data/hays_lab/finder/Discriminative_Patch_Discovery/' ...
             '15_scene_patches/' ranking_type{rank} '/'];

sub_path = 'autoclust_main_15scene_out/ds/';
if rank == 3
    sub_path = 'autoclust_main_nn_only_out/cluster_detectors/';
end
dpatches_per_cat = 100;

% load sorted dets files from each category and cat all sub structures.
% find all category dirs
cat_paths = dir(data_path);
cat_paths = cat_paths(3:end);
% keyboard
for cat = 1:length(cat_paths)
    clear data
    fname = fullfile(data_path, cat_paths(cat).name, sub_path, ...
                     detectors_fname)
    try
    load(fname);

    %should make a list of the patch jpgs that correspond to the
    %different detectors
    % these are stored in data_path/sub_path/{'bestbin' or
    % 'bestbin_overallcounts' or
    % 'bestbin_posterior'}/alldiscpatchimg[]/*.jpg
    % inds are stored in alldisclabelcat.mat (col 2 is detector
    % number, index corresponds to patch#.jpg)
    % tosave.mat is the list of detector inds sorted
    if rank ~= 3
        alldisclabel_fname = fullfile(data_path, cat_paths(cat).name, sub_path,...
                                        ['bestbin_' ranking_type{rank}], 'alldisclabelcat.mat');
        alldiscpatch_dir = fullfile(data_path, cat_paths(cat).name, sub_path,...
                                        ['bestbin_' ranking_type{rank}], 'alldiscpatchimg[]');
        bbhtml_fname = fullfile(data_path, cat_paths(cat).name, sub_path,...
                                        ['bestbin_' ranking_type{rank}], 'bbhtml.html');   
        tosave_fname = fullfile(data_path, cat_paths(cat).name, sub_path,...
                                        ['bestbin_' ranking_type{rank}], 'tosave.mat');                                   
        bbhtml_f = fopen(bbhtml_fname);
        patch_membership = load(alldisclabel_fname);
        text = textscan(bbhtml_f, '%s');
        numlines = text{1}((cellfun(@(x) ~isempty(strfind(x,'<br/>')), text{1})));
        dinds = cell2mat(cellfun(@(x) str2double(x(strfind(x,':')+1:strfind(x,'<')-1)),numlines,'UniformOutput', 0));
    %     keyboard
    else
        dinds = 1:length(data.firstLevModels.info);
    end
   
    % concat detectors - copy params (if not exist) and firstLevModels
    % data.firstLevModels
    %          w: [491x2112 double]
    %        rho: [491x1 double]
    % firstLabel: [491x1 double]
    %       info: {491x1 cell}
    %  threshold: [491x1 double]
    %       type: 'composite' 
    if(~exist('detectors','var'))
        %check if length(dinds) == length(data.firstLevModels.info) 
        if length(dinds) == length(data.firstLevModels.info)
            dinds = dinds(1:min(length(dinds), dpatches_per_cat));
            if rank == 3
                dinds= randi(length(data.firstLevModels.info),1,min(length(dinds), ...
                                                                 dpatches_per_cat));
                disp('using randomly picked set of detectors');
                length(dinds)
            end
            detectors.overlapping = zeros(length(dinds),1);
        else
            tosave = load(tosave_fname);
            if size(tosave.data,1) == 1
                tosave.data = tosave.data';
            end
            dinds = dinds(1:min(length(dinds), dpatches_per_cat));
            tosave.data = tosave.data(1:min(length(tosave.data),dpatches_per_cat));
            detectors.overlapping = arrayfun(@(x) isempty(find(dinds == x)),tosave.data);
            dinds = tosave.data;
        end
        detectors.params = data.params;
        fields = fieldnames(data.firstLevModels);
        detectors.firstLevModels = data.firstLevModels;

        for i=1:numel(fields)
            detectors.firstLevModels.(fields{i}) = detectors.firstLevModels.(fields{i})(1:min(size(detectors.firstLevModels.(fields{i}),1),dpatches_per_cat),:);
            
        end

         
%          keyboard
        if rank ~=3
            detectors.patch_paths = cellfun(@(y) arrayfun(@(x) fullfile(alldiscpatch_dir, [num2str(x) '.jpg']), y, ...
                                                          'UniformOutput', false), arrayfun(@(x) find(patch_membership.data(:,2) == x), dinds,...
                                                          'UniformOutput', false), 'UniformOutput', false);
%         keyboard
        end
         
    else
%         keyboard
        if length(dinds) == length(data.firstLevModels.info)
            dinds = dinds(1:min(length(dinds), dpatches_per_cat));
            if rank == 3
                dinds= randi(length(data.firstLevModels.info),1,min(length(dinds), ...
                                                                 dpatches_per_cat));
                disp('using randomly picked set of detectors');
                length(dinds)
            end
            detectors.overlapping = vertcat(detectors.overlapping,zeros(length(dinds),1));
        else
            tosave = load(tosave_fname);
            if size(tosave.data,1) == 1
                tosave.data = tosave.data';
            end
            dinds = dinds(1:min(length(dinds), dpatches_per_cat));
            tosave.data = tosave.data(1:min(length(tosave.data),dpatches_per_cat));
            detectors.overlapping = vertcat(detectors.overlapping,arrayfun(@(x) isempty(find(dinds == x)),tosave.data));
            dinds = tosave.data;
        end
        fields = fieldnames(data.firstLevModels);

        for i=1:numel(fields)
            detectors.firstLevModels.(fields{i}) = vertcat(detectors.firstLevModels.(fields{i}),...
                                                           data.firstLevModels.(fields{i})(1:min(size(data.firstLevModels.(fields{i}),1),dpatches_per_cat),:));
            
        end
%         keyboard

        if rank ~= 3
            temp = cellfun(@(y) arrayfun(@(x) fullfile(alldiscpatch_dir, [num2str(x) '.jpg']), y, ...
                                    'UniformOutput', false), arrayfun(@(x) find(patch_membership.data(:,2) == x), dinds,...
                                    'UniformOutput', false), 'UniformOutput', false);
            if(size(temp,2) > 1)
                temp = temp';
            end
            detectors.patch_paths = vertcat(detectors.patch_paths, temp);
    %                             keyboard
        end
    end

    detectors.firstLevModels
    fclose(bbhtml_f);
    catch e
        disp(e.message);
    end
end

save(fullfile(data_path, ['detectors' detectors_fname(length('detsDclust')+1:end)]), 'detectors');