% testing the spatial pryramid features
    test_path = '/data/hays_lab/15_scene_dataset';
    load(fullfile(test_path, 'images.mat'));

img_ind = 1;
rank_ind = 2;
svm_ind = 1;
    ranking_type = {'overallcounts', 'posterior', 'nearestneighbors'};
    svm_type = {'linear', 'polynomial', 'rbf', 'sigmoid'};
i = img_ind;

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


disp('Calculating feature');

% tic;
% feat = makeVisEntDetFeatures(img_name, img_path, save_path, detectors_fname, ...
%                              -1.002);;

% toc;
%clear feat
makeVisEntDetFeatures(img_name, img_path, save_path, detectors_fname,-1.002);
disp('Loading feature');
tic;
load(fullfile(save_path,[img_name(1:end-4) '.mat']));

         sub_decision = decision(find(levels == 1 | levels ==9 | levels == ...
                                       14), :);
         feat = reshape(sub_decision, numel(sub_decision), 1);

toc;