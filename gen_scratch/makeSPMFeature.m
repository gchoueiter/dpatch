%%%
% This function makes a SPM Dpatch feature for the input image and type
% of detector. 
%%%

function [feat] = makeSPMFeature(img_name, img_path, save_path, detectors_fname, ...
                                 detection_threshold, overwrite)


disp('calculating raw features');
[decision, levels, pyra] = makeVisEntDetFeature(img_name, img_path, save_path, ...
                                  detectors_fname,  detection_threshold, ...
                                                overwrite);
num_lvls = numel(unique(levels));%[1 9 14]

if(~overwrite & exist(fullfile(save_path,[img_name(1:end-4) '_spm_lvl' ...
                    num2str(num_lvls) '.mat']), 'file'))
    disp(['SPM feature already calculated for image: ' img_name(1:end-4)]);
    load(fullfile(save_path,[img_name(1:end-4) '_spm_lvl' ...
                    num2str(num_lvls) '.mat']));
    return;
end


disp('calculating SPM feature');

feat = zeros(1*num_lvls,size(decision,2));%(((1+4+16)*num_lvls,size(decision,2)));
% for each patch
for patch = 1:size(decision,2)
feat_ind = 1;
% for each level of resolution
lvls = unique(levels);
       for l = 1:length(lvls)
           lvl = lvls(l);
           % reshape feature array into spatially aligned matrix
           cur_feat = decision(find(levels == lvl),patch);
           % reshape cur_feat!!

           for spm_lvl = 1%:3
           % for each level of SPM
                for gridx = 1:2^(spm_lvl-1)
                    for gridy =1:2^(spm_lvl-1)
                        % for each grid location -> histogram that patch!
                        % !! cur_feat should be subsampled for this grid location
                        pos_det = sum(cur_feat > detection_threshold);
                        feat(feat_ind, patch) = pos_det;
                        feat_ind = feat_ind+1;
                    end
                end
           end
       end
end
% final feature should be (3 resolutions * (1+4+16) grid squares)x(n
% patches)
disp(['saving SPM feature for image: ' img_name(1:end-4) '_spm_lvl' ...
                    num2str(num_lvls)]);
save(fullfile(save_path,[img_name(1:end-4) '_spm_lvl' ...
                    num2str(num_lvls) '.mat']),  'feat');
end