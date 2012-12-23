% gen
% straw function for testing extract_feature
% status 0-pass >0-fail

function [status] = conv_test(img_name, save_path, patch_num)
    % feat is the response of the densely sampled convolution of the image
    % with the dpatch
    % imsize is the [rows cols] of the image

try
    feat = magic(3);
    feat = reshape(feat, 1, 9);
    imsize = [3 3];

    save_name = fullfile(save_path, sprintf('%s_dpatch_tmp_feat_%d.mat', img_name, patch_num));
    save(save_name, 'feat', 'imsize');

catch e
    disp(e.message);
    status = 1;
end

end
