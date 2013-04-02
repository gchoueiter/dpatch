function extract_feature_CheckAndRelaunch(rank_str)
    rank_ind = str2double(rank_str);
    addpath(genpath('/home/gen/dpatch'));
    test_path = '/data/hays_lab/15_scene_dataset';
    load(fullfile(test_path, 'images.mat'));
    checkTil = 4485;
    hasFeat = zeros(length(images),1);
    ranking_type = {'overallcounts', 'posterior'};
    data_path = ['/data/hays_lab/finder/Discriminative_Patch_Discovery/' ...
             '15_scene_patches/' ranking_type{rank_ind} '/'];
    load(fullfile(data_path, 'detectors.mat'));
    for i = 1:length(images)%2300+1:checkTil%

	    image = images{i};
	    img_path = test_path;
	    img_name = image;%image(37:end);
            ranking_type = {'overallcounts', 'posterior'};
            save_path = fullfile(img_path, ['features/dpatch_' ...
                                ranking_type{rank_ind} '/']);

            last_stroke = strfind(img_name, '/');
            last_stroke = last_stroke(end);
            %            hasFeat(i,1) = exist(fullfile(save_path, [img_name(last_stroke:end-4) ...
            %                   '.mat']),'file');
            if exist(fullfile(save_path, [img_name(1:end-4) '.mat']),'file')
                load(fullfile(save_path, [img_name(1:end-4) '.mat']));
                hasFeat(i,1) = length(feat) == length(detectors.firstLevModels.info);
                unix(['rm -f ' fullfile(save_path, [img_name(1:end-4) '.mat'])]);
                clear feat;
            end

            launchJobs = 1;
            if(~hasFeat(i,1) & launchJobs)

                %keyboard
                % launch conv job on grid
                log_path = '/data/hays_lab/people/gen/grid_out/dpatch_extract_feat/';
                logdir = fullfile(log_path, img_name(1:end-4));
                if(~exist(logdir, 'dir'))
                    mkdir(logdir);
                end

                logfileerr = fullfile(log_path, img_name(1:end-4), ['qsub_out.err']);
                logfileout = fullfile(log_path, img_name(1:end-4), ['qsub_out.out']);

                tmpFuncCall = sprintf(['extract_feature_per_image.sh %s ' ...
                '%s'], num2str(i), rank_str);
                %                keyboard
                qsub_cmd = ['qsub -N dp' num2str(rand()) ' -l long' ' -e ' logfileerr ' -o ' logfileout ' ' tmpFuncCall];
                
                unix(qsub_cmd);
            end
            % if(hasFeat(i,1))
            %     cp_cmd = ['cp ' fullfile(save_path, img_name(1:end-4), [img_name(last_stroke:end-4) ...
            %                     '.mat']) ' ' fullfile(save_path, ...
            %                                           img_name(1:last_stroke-1))];
            %     unix(cp_cmd);
            %     %rm_cmd = ['rm -rf ' fullfile(save_path, img_name(1:end-4)) '/*dpatch_tmp_feat*'];
            %     %unix(rm_cmd); 

            % end
    end
    %keyboard
    fprintf('%d out of %d images calculated so far ...\n', sum(hasFeat > ...
                                                      0), length(hasFeat));
    %keyboard

end