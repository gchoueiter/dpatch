function makeSPMFeature_GridWrapper(img_ind_str, rank_ind_str, svm_ind_str)

    img_ind = str2double(img_ind_str);
    rank_ind = str2double(rank_ind_str);
    svm_ind = str2double(svm_ind_str);

    addpath(genpath('/home/gen/dpatch'));

    test_path = '/data/hays_lab/15_scene_dataset';
    load(fullfile(test_path, 'images.mat'));
    ranking_type = {'overallcounts', 'posterior', 'nearestneighbors'};
    svm_type = {'linear', 'polynomial', 'rbf', 'sigmoid'};
    for i = img_ind:min(img_ind+0, length(images))

	    image = images{i};
	    img_path = test_path;
	    img_name = image;%image(37:end);

            if rank_ind == 3
                dpatch_svm = ['_' svm_type{svm_ind}];
            else
                dpatch_svm = '';
            end 

            save_path = fullfile(img_path, ['features_pyra/dpatch' ...
                                [dpatch_svm '_' ranking_type{rank_ind}] '/']);
            if(~exist(save_path, 'dir'))
                mkdir(save_path);               
            end
            if(~exist(fullfile(save_path,img_name(1:end-14))))
                mkdir(fullfile(save_path,img_name(1:end-14)));
            end
                
               
            detectors_fname = ['/data/hays_lab/finder/' ...
                               'Discriminative_Patch_Discovery/' ...
                               '15_scene_patches/' ranking_type{rank_ind} ...
                               '/detectors' dpatch_svm '_visentdet.mat'];



            %            keyboard
        makeSPMFeature(img_name, img_path, save_path, detectors_fname, ...
                              -1.002, 0);

    end
    fprintf('DONE CALCULATING SPM DPatch features up to image %d\n',i);


end