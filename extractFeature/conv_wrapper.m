% gen
% wrapper for TY_conv_func
% saves results to file 
% status 0-pass >0-fail

function [status] = conv_wrapper(img_name, save_path, patch_num)
    % feat is the response of the densely sampled convolution of the image
    % with the dpatch
    % imsize is the [rows cols] of the image

try
    [feat, imsize] = conv_func(img, npatch, params);

    save_name = fullfile(save_path, sprintf('%s_dpatch_tmp_feat_%d.mat', img_name, patch_num));
    save(save_name, 'feat', 'imsize');

catch e
    disp(e.message);
    status = 1;
end

end
