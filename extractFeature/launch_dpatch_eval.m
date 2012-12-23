% gen
% this starts a dpatch convolution job
% evaluates dpatch on img
% saves result to save_path
function launch_dpatch_eval(patch_num, job_num)

global GVARS

% TODO:
% check
% if
% results
% exist
save_name = fullfile(GVARS.save_path, sprintf('%s_dpatch_feat_%d.mat', GVARS.img_name, patch_num));
if(exist(save_name,'file'))
    disp(sprintf('Result exists for this patch in %s', save_name));
    return;
end


if(~GVARS.isparallel)
    
    % TODO: launch conv job locally
    % NOTE to Tsung-Yi : this is where we call your function
    conv_test(GVARS.img_name, GVARS.save_path, patch_num);
else
    % TODO: launch conv job on grid
    logfileerr = fullfile(GVARS.log_path, ['qsub_out_' num2str(patch_num) '_' num2str(job_num) '.err']);
    logfileout = fullfile(GVARS.log_path, ['qsub_out_' num2str(patch_num) '_' num2str(job_num) '.out']);

    tmpFuncCall = sprintf('TY_conv.sh %s %s %d', GVARS.img_name, GVARS.save_path, patch_num);
    qsub_cmd = ['qsub -N dpatch_eval' num2str(job_num) ' -l short' ' -e ' logfileerr ' -o ' logfileout ' ' tmpFuncCall];
    
    unix(qsub_cmd);
end

GVARS.job_stat(job_num, 1) = 0;

end