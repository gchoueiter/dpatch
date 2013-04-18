% This is a script for training svms for all of the human selected
% patches
% Called from parse_results.m
%
disp('Training all patch detectors...');
cat_dir = ['/data/hays_lab/finder/' ...
                    'Discriminative_Patch_Discovery/15_scene_patches/' ...
                    'nearestneighbors/' cat_str '/autoclust_main_nn_only_out/'];
for clusterNum = 1:length(nonOverlapClusters)
    for selectNum = 1:length(nonOverlapClusters{clusterNum})
        selectedPatches = sprintf('%s-',nonOverlapClusters{clusterNum}{selectNum}{:});
        if exist(fullfile(cat_dir, 'cluster_detectors', ['cluster' clusterNum], ...
                   [selectedPatches 'sigmoid.mat']), ...
                 'file')
            continue;
        end
        % calculate all patch models
        %    if isparallel launch grid job to make 
        if(~isparallel)

            % launch job locally          
            makeIndvDet(cat_str, num2str(clusterNum), selectedPatches);
        else
            % launch job on grid
            logdir = fullfile(log_path, cat_str, ['cluster' num2str(clusterNum)]);
            if(~exist(logdir, 'dir'))
                mkdir(logdir);
            end

            logfileerr = fullfile(logdir, ['qsub_out_' num2str(selectNum) '.err']);
            logfileout = fullfile(logdir, ['qsub_out_' num2str(selectNum) '.out']);

            tmpFuncCall = sprintf('/home/gen/dpatch/human_patches/makeIndvDet.sh %s %d %s', ...
                                  cat_str, clusterNum, selectedPatches);            
            qsub_cmd = ['qsub -N patch-' num2str(clusterNum) '-' num2str(selectNum) ...
                        ' -l short' ' -e ' logfileerr ...
                        ' -o ' logfileout ' ' tmpFuncCall];

            unix(qsub_cmd);
        end

    end
end