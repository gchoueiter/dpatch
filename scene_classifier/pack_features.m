% pack the features of a list of images into a single matrix where every
% row is the feature vector of the image with the same index

function feature_vector = pack_features(feat_name, imgs)
global sc;

feats_cell = {length(imgs),1};
for i = 1:length(imgs)
    
    feat_save_path = fullfile(sc.feat_path, feat_name, [imgs(i).fullname(1:end-4) '.mat']);
    % if the feature doesn't exist, calculate it
    if(~exist(feat_save_path, 'file'))        
        switch feat_name
            case 'dpatch'
                extract_feature(imgs(i).fullname(1:end-4), ...
                                fullfile(sc.feat_path, feat_name), ...
                                sc.npatch_fname, sc.njobs, sc.isparallel, sc.log_path);
        end        
    end
    
    %load feature for this image
    load(feat_save_path);
    feats_cell{i} = feat;
    clear feat;

end

feature_vector = reshape(cell2mat(feats_cell),  length(feats_cell{1}), length(feats_cell))';

end