% pack the features of a list of images into a single matrix where every
% row is the feature vector of the image with the same index

function feature_vector = pack_features(feat_name, imgs, patches_to_include)
global sc;

feats_cell = {length(imgs),1};
for i = 1:length(imgs)
    
    feat_save_path = fullfile(sc.feat_path, feat_name, [imgs(i).fullname(1:end-4) '.mat']);
    % if the feature doesn't exist, calculate it
    if(~exist(feat_save_path, 'file'))        
        switch feat_name(1:6)
            case 'dpatch'
              %                keyboard
              fprintf('extracting feature for image: %s\n', imgs(i).fullname);
              extract_feature(imgs(i).fullname(1:end-4), sc.img_path,...
                                fullfile(sc.feat_path, feat_name), ...
                                sc.detectors_fname, sc.njobs, sc.isparallel, sc.log_path);
        end        
    end
    
    %load feature for this image
    load(feat_save_path);
    %% TODO: !!!!change this to sameple from each category!!!
%     keyboard
    try
    
        if(length(patches_to_include)>length(feat) )
            fprintf(['number of requested patches and feature length do not ' ...
                     'match: num_patches = %d and feat_length = %d \n Recalculating patch in case... \n'],length(patches_to_include), ...
                    length(feat));
            keyboard
            switch feat_name(1:6)
                case 'dpatch'
                  %                keyboard
                  fprintf('extracting feature for image: %s\n', imgs(i).fullname);
                  extract_feature(imgs(i).fullname(1:end-4), sc.img_path,...
                                    fullfile(sc.feat_path, feat_name), ...
                                    sc.detectors_fname, sc.njobs, sc.isparallel, sc.log_path);
                    load(feat_save_path);
                    feats_cell{i} = feat(patches_to_include);
            end        
        else
            feats_cell{i} = feat(patches_to_include);
        end
    catch e
        keyboard;
    end
    clear feat;

end

feature_vector = reshape(cell2mat(feats_cell),  length(feats_cell{1}), length(feats_cell))';

end