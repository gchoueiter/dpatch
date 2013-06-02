function [sum_im_out]= makeVisEntDetFeatures_CheckAndRelaunch(rank_str, svm_str)
    rank_ind = str2double(rank_str);
    svm_ind = str2double(svm_str);
    %    addpath(genpath('/home/gen/dpatch'));
    test_path = '/data/hays_lab/15_scene_dataset';
    load(fullfile(test_path, 'images.mat'));

    hasFeat = zeros(length(images),1);
    %    ranking_type = {'overallcounts', 'posterior'};
    
    ranking_type = {'overallcounts', 'posterior', 'nearestneighbors'};
    svm_type = {'linear', 'polynomial', 'rbf', 'sigmoid'};
            if rank_ind == 3
                dpatch_svm = ['_' svm_type{svm_ind}];
            else
                dpatch_svm = '';
            end 

            save_path = fullfile(test_path, ['features_pyra/dpatch' ...
                                [dpatch_svm '_' ranking_type{rank_ind}] '/']);
            detectors_fname = ['/data/hays_lab/finder/' ...
                               'Discriminative_Patch_Discovery/' ...
                               '15_scene_patches/' ranking_type{rank_ind} ...
                               '/detectors' dpatch_svm '_visentdet.mat'];
    

    load(detectors_fname);
    for i = 1:length(images)

	    image = images{i};
	    img_path = test_path;
	    img_name = image;%image(37:end);
            
            save_path = fullfile(img_path, ['features_pyra/dpatch' dpatch_svm '_'...
                                ranking_type{rank_ind} '/']);
            

            last_stroke = strfind(img_name, '/');
            last_stroke = last_stroke(end);
            hasFeat(i,1) = exist(fullfile(save_path, [img_name(1:end-4) '.mat']),'file');

            launchJobs = 1;
            if(~hasFeat(i,1) & launchJobs)

                %keyboard
                % launch conv job on grid
                log_path = '/data/hays_lab/people/gen/grid_out/dpatch_makeVisEntDet/';
                logdir = fullfile(log_path, img_name(1:end-4));
                if(~exist(logdir, 'dir'))
                    mkdir(logdir);
                end

                logfileerr = fullfile(log_path, img_name(1:end-4), ['qsub_out.err'])
                logfileout = fullfile(log_path, img_name(1:end-4), ...
                                      ['qsub_out.out'])
%makeVisEntDetFeatures(img_name, img_path, save_path, detectors_fname,  detection_threshold, overwrite)

                tmpFuncCall = sprintf(['makeVisEntDetFeatures_GridRun_perImg.sh %s ' ...
                '%s %s'], rank_str, svm_str, num2str(i));

                qsub_cmd = ['qsub -N dp' num2str(rand()) ' -l short' ' -e ' logfileerr ' -o ' logfileout ' ' tmpFuncCall];

                unix(qsub_cmd);
                disp(['launched feature calc for: ' img_name]);

            end

    end

    fprintf('%d out of %d images calculated so far ...\n', sum(hasFeat > ...
                                                      0), ...
            length(hasFeat));

    %keyboard

end