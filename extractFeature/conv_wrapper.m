% gen
% wrapper for conv_func
% saves results to file 
% status 0-pass >0-fail

function [status] = conv_wrapper(img_name, img_path,save_path, npatch_fname, ...
                                 patch_num, params_fname)
    % feat is the response of the densely sampled convolution of the image
    % with the dpatch
    % imsize is the [rows cols] of the image

    % check if patch_num is string (i.e. it is from a grid call)

if (nargin == 4)
    [npatch_fname, remain] = strtok(npatch_fname, ' ');
    [patch_num, params_fname] = strtok(remain, ' ');
    npatch_fname = strtrim(npatch_fname);
    patch_num = strtrim(patch_num);
    params_fname = strtrim(params_fname);
end

    if(strcmp('char', class(patch_num)))
addpath('../');
addpath(genpath('../dswork'));
addpath(genpath('../crossValClustering'));
addpath(genpath('../hog'));
addpath(genpath('../extractFeature'));
       patch_num = str2double(patch_num);
    end
    disp(sprintf('calculating response to patch number %d...',patch_num));
try
   img = im2double(imread([img_path img_name]));
   detectors = load(npatch_fname);
   detectors = detectors.data;
   npatch = detectors.firstLevModels;
   load(params_fname);
   [feat, imsize] = conv_func(img, img_path, npatch, patch_num, params);%conv_func();%

   last_stroke = strfind(img_name, '/');
   last_stroke = last_stroke(end);
   save_name = fullfile(save_path, sprintf('%s_dpatch_tmp_feat_%d.mat', img_name(last_stroke:end-4), patch_num));
    save(save_name, 'feat', 'imsize');

catch e
    disp(e.message);
    status = 1;
end

end
