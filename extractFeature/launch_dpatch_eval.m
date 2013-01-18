% gen
% this starts a dpatch convolution job
% evaluates dpatch on img
% saves result to save_path
function launch_dpatch_eval(patch_num)

global GVARS

% TODO: check if results exist
save_name = fullfile(GVARS.save_path, sprintf('%s_dpatch_feat_%d.mat', GVARS.img_name(1:end-4), patch_num));
if(exist(save_name,'file'))
    disp(sprintf('Result exists for this patch in %s', save_name));
    return;
end


if(~GVARS.isparallel)
    
    % launch conv job locally          
    conv_wrapper(GVARS.img_name, GVARS.img_path, GVARS.save_path, ...
		 GVARS.npatch_fname, patch_num, GVARS.params_fname);


else
    % launch conv job on grid
    logdir = fullfile(GVARS.log_path, GVARS.img_name(1:end-4));
    if(~exist(logdir, 'dir'))
        mkdir(logdir);
    end

    logfileerr = fullfile(GVARS.log_path, GVARS.img_name(1:end-4), ['qsub_out_' num2str(patch_num) '.err']);
    logfileout = fullfile(GVARS.log_path, GVARS.img_name(1:end-4), ['qsub_out_' num2str(patch_num) '.out']);

    tmpFuncCall = sprintf('conv_grid_wrapper.sh %s %s %s %s %d %s', ...
			  GVARS.img_name, GVARS.img_path, ...
			  GVARS.save_path, GVARS.npatch_fname, ...
			  patch_num, GVARS.params_fname);
    %keyboard
qsub_cmd = ['qsub -N dp' GVARS.rand ' -l short' ' -e ' logfileerr ' -o ' logfileout ' ' tmpFuncCall];
    
    unix(qsub_cmd);
end

end
