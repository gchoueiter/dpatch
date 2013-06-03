% pack the features of a list of images into a single matrix where every
% row is the feature vector of the image with the same index

% this is meant to pack features made using the makeVisEntDetFeatures.m
%patches to include should be a cell array where each cell is a logical
%array of the patches to include
function feature_vector = pack_features_SPM(feat_name, imgs, patches_to_include)

global sc;

for i = 1:length(imgs)
    
    feat_save_path = fullfile(sc.feat_path, feat_name, [imgs(i).fullname(1:end-4) '.mat']);
    % if the feature doesn't exist, calculate it
    %    keyboard
    if(~exist(feat_save_path, 'file'))        
        switch feat_name(1:6)
            case 'dpatch'
              %keyboard
              fprintf('extracting feature for image: %s\n', ...
                      imgs(i).fullname);
              img_name = imgs(i).fullname;
              % this adds .jpg if there is no extension or leaves it the
              % same if there is
              img_name = strrep(img_name, '.jpg', '');
              img_name = [img_name '.jpg'];
              makeVisEntDetFeatures(img_name, sc.img_path, fullfile(sc.feat_path, ...
                                          feat_name), sc.detectors_fname,  -1.002, 0);

        end        
    end
    
    %load feature for this image

    load(feat_save_path);

    try
    
        %%TODO: handle corrupt feature files...

        cur_feat = decision(:,patches_to_include);
        cur_feat = reshape(cur_feat, numel(cur_feat), 1);
        if(~exist('feature_vector', 'var'))
            feature_vector = zeros(length(imgs), length(cur_feat));
        end
        feature_vector(i,:) = cur_feat;
        
        %        feats_cell{i} = feat(patches_to_include);
        disp(['loading feature for image number ' num2str(i)]);

    catch e
        disp(e.message)
        e.stack.name
        e.stack.line
        keyboard;
    end
    clear decision;

end



end