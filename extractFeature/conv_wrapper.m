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

if (nargin == 4)
    [detectors_fname, remain] = strtok(detectors_fname, ' ');
    [params_fname, remain] = strtok(remain, ' ');
    detectors_fname = strtrim(detectors_fname);
    params_fname = strtrim(params_fname);
end

try
    
    %% this is a temporary hack!!
    try
       img = im2double(imread(fullfile(img_path,img_name)));
    catch e
       disp(e.message);
       img = 0;
    end

   load(detectors_fname);
  conv_func(img, img_name, save_path, detectors);%, patch_num);%conv_func();
      

catch e
    disp(e.message);
    status = 1;
end

end
