% gen
% this starts a dpatch convolution job
% evaluates dpatch on img
% saves result to save_path
function launch_dpatch_eval(img, save_path, npatch, njob, isparallel)

global GVARS

% TODO: check if results exist

if(~isparallel)
    
    % TODO: launch conv job locally
    % feat is the response of the densely sampled convolution of the image
    % with the dpatch
    % imsize is the [rows cols] of the image
    % NOTE to Tsung-Yi : this is where we call your function
    [feat, imsize] = TY_conv_func(img, npatch);
else
    % TODO: launch conv job on grid
    
end

save_name = fullfile(save_path, sprintf('dpatch_feat_%5d.mat', npatch));
save(save_name, 'feat', 'imsize');
GVARS.job_stat(njob, 1) = 0;

end