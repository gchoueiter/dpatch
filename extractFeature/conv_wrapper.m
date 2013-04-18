% gen
% wrapper for conv_func
% saves results to file 
% status 0-pass >0-fail

function [status] = conv_wrapper(img_name, img_path,save_path, detectors_fname, ...
                                 params_fname)
    % feat is the response of the densely sampled convolution of the image
    % with the dpatch
    % imsize is the [rows cols] of the image

    % check if patch_num is string (i.e. it is from a grid call)
addpath(genpath('.'))
if (nargin == 4)
    [detectors_fname, remain] = strtok(detectors_fname, ' ');
    [params_fname, remain] = strtok(remain, ' ');
    detectors_fname = strtrim(detectors_fname);
    params_fname = strtrim(params_fname);
end
% if (nargin == 4)
%     [detectors_fname, remain] = strtok(detectors_fname, ' ');
%     [patch_num, params_fname] = strtok(remain, ' ');
%     detectors_fname = strtrim(detectors_fname);
%     patch_num = strtrim(patch_num);
%     params_fname = strtrim(params_fname);
% end

%     if(strcmp('char', class(patch_num)))
% addpath('../');
% addpath(genpath('../dswork'));
% addpath(genpath('../crossValClustering'));
% addpath(genpath('../hog'));
% addpath(genpath('../extractFeature'));
% %patch_num = str2double(patch_num);
%     end
    %disp(sprintf('calculating response to patch number %d...',patch_num));
try
   % last_stroke = strfind(img_name, '/');
   % last_stroke = last_stroke(end);
   % save_name = fullfile(save_path, sprintf('%s_dpatch_tmp_feat_%d.mat', ...
   %                                         img_name(last_stroke:end-4), patch_num));
   % if exist(save_name, 'file')
   %     disp( ['temp patch ' num2str(patch_num) ' already calculated']);
   %     return;
   % end
   img = im2double(imread(fullfile(img_path,img_name)));

   load(detectors_fname);
  conv_func(img, img_name, save_path, detectors);%, patch_num);%conv_func();% [feat, imsize] = 
      
   % save(save_name, 'feat', 'imsize');

catch e
    disp(e.message);
    status = 1;
end

end
