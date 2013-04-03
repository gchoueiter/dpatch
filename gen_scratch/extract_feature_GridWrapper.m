function extract_feature_GridWrapper(img_ind_str, rank_ind_str)

    img_ind = str2double(img_ind_str);
    rank_ind = str2double(rank_ind_str);

    addpath(genpath('/home/gen/dpatch'));
    test_path = '/data/hays_lab/15_scene_dataset';
    load(fullfile(test_path, 'images.mat'));
    ranking_type = {'overallcounts', 'posterior'};
    for i = img_ind:min(img_ind+0, length(images))

	    image = images{i};
	    img_path = test_path;
	    img_name = image;%image(37:end);
            save_path = fullfile(img_path, ['features/dpatch_' ...
                                ranking_type{rank_ind} '/']);
            if(~exist(save_path, 'dir'))
                mkdir(save_path);
            end
            
            detectors_fname = ['/data/hays_lab/finder/' ...
                               'Discriminative_Patch_Discovery/' ...
                               '15_scene_patches/' ranking_type{rank_ind} '/detectors.mat'];
            njobs = 50;
            isparallel = 0;
            log_path = '/data/hays_lab/people/gen/grid_out/dpatch_extract_feat/';
            if(~exist(log_path, 'dir'))
                mkdir(log_path);
            end
        extract_feature(img_name, img_path, save_path, detectors_fname, njobs, isparallel, log_path)
    end
    fprintf('DONE CALCULATING DPatches up to image %d\n',i);


end