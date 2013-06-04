% tests scene classification 
%% IMPORTANT: run extract feature for all images first. The extract
%% feature here is just a catch in case.
try
global sc;
addpath(genpath('/home/gen/dpatch'))
%% If this is parallel, you need to run the function twice. The first
%% time will end with an error.
isparallel = 1;
re_run = 1;
cd '/home/gen/dpatch/scene_classifier/'
ranking_type = {'overallcounts', 'posterior', 'nearestneighbors'};
svm_type = {'linear', 'polynomial', 'rbf', 'sigmoid'};

% VARRY TRAINING EXAMPLES - MAX VAL = 150
num_train_ex = 100;

%all_perf = cell(3,4);
%all_ap = cell(3,4);
%all_perf = zeros(4, 1500, 6);
%all_ap = zeros(4,1500, 15, 6);
cur_type_ind =1;

sc.dataset = '/home/gen/dpatch/dataset15.mat';
load(sc.dataset);
% set up test/train index for 15 scene dataset
scene_cats=unique(arrayfun(@(x) x.city,imgs,'UniformOutput', ...
                           false));
imgs_train=[]; 
imgs_test=[];
train_inds = [];
test_inds = [];
for i = 1:length(scene_cats)
    cat_inds = find(~arrayfun(@(x) isempty(strfind(x.city, scene_cats{i})), ...
                         imgs));
    % NOTE: the same imgs that were used for dpatch discovery are re-used
    % in the scene classifier training set. 
    train_inds = horzcat(train_inds, cat_inds(1:num_train_ex));  
    test_inds = horzcat(test_inds, cat_inds(151:end));
    
end
imgs_train = imgs(train_inds);
imgs_test = imgs(test_inds);
disp('train and test images!');
fprintf('num train images %d\n', length(imgs_train)); 
fprintf('num test images %d\n', length(imgs_test)); 

sc.njobs = 900;
sc.isparallel = 0;
sc.log_path = '/data/hays_lab/finder/Discriminative_Patch_Discovery/15scene_classifiers/logs/';
if(~exist(sc.log_path, 'dir'))
    mkdir(sc.log_path);    
end

% for 15 classes dataset
sc.img_path = '/data/hays_lab/15_scene_dataset/';
sc.save_path = ['/data/hays_lab/finder/Discriminative_Patch_Discovery/' ...
                '15scene_classifiers_SPM2_train_' num2str(num_train_ex) '/'];
if(~exist(sc.save_path, 'dir'))
    mkdir(sc.save_path);
end
sc.feat_path   = fullfile(sc.img_path, 'features_pyra/');
sc.kernel_path = fullfile(sc.save_path, 'kernels/');
if(~exist(sc.kernel_path,'dir'))
    mkdir(sc.kernel_path);
end
sc.svm_path = fullfile(sc.save_path, 'svms/');
if(~exist(sc.svm_path,'dir'))
    mkdir(sc.svm_path);
end

for rank = 2:3%1:3

for sub = 1%:4
    %all_perf = zeros(4,1500,6);%num_feat, num_patches);
if sub >1 & (rank ==1 | rank ==2)
    continue;
end
data_path = ...%'/data/hays_lab/finder/Discriminative_Patch_Discovery/try2/';
            ['/data/hays_lab/finder/Discriminative_Patch_Discovery/' ...
             '15_scene_patches/' ranking_type{rank} '/'];
if rank ~=3
    load(fullfile(data_path, 'detectors_visentdet.mat'));
    load(fullfile(data_path, 'detectors_visentdet_patch_paths.mat'));
    if sub>1
        continue;
    end
else
    disp('loading detectors');
    load(fullfile(data_path, ['detectors_' svm_type{sub} '_visentdet.mat']));
end



if rank == 3
    dpatch_svm_type = ['_' svm_type{sub}];
else
    dpatch_svm_type = '';
end
sc.detectors_fname = fullfile(data_path, ['detectors' dpatch_svm_type '_visentdet.mat']);
% include libsvm for training svms
addpath(genpath('/home/gen/libsvm-mat-3.0-1'));

if(~exist(sc.save_path, 'dir'))
    mkdir(sc.save_path);
    mkdir(sc.feat_path);
    mkdir(sc.kernel_path);
    mkdir(sc.svm_path);
end


% set up type of features to use
n = 1;
sc.feat(n).name = ['dpatch' dpatch_svm_type];
sc.feat(n).kernel_name = 'rbf';
n = 2;
sc.feat(n).name = ['dpatch' dpatch_svm_type];
sc.feat(n).kernel_name = 'kchi2';
n = 3;
sc.feat(n).name = ['dpatch' dpatch_svm_type];
sc.feat(n).kernel_name = 'kl2';
n = 4;
sc.feat(n).name = ['dpatch' dpatch_svm_type];
sc.feat(n).kernel_name = 'kl1';

num_training_patches_per_cat = [1 5 10 50 100];
num_training_patches = [1 5 10 50 100]*length(scene_cats); 
num_training_patches(num_training_patches>length(detectors.firstLevModels.info))= length(detectors.firstLevModels.info);
num_training_patches = unique(num_training_patches);

num_training_patches_used{cur_type_ind} = zeros(size(num_training_patches));


% NOTE: this iterates through num_feat number of different features
%       and num_patches number of training patches

nind = 1;
% calculating all feature matricies in advance to decease loading time
for num_patches = num_training_patches_per_cat%[1 5 10 50 100];

    patches_to_include = zeros(length(detectors.firstLevModels.info),1);
    disp(sprintf('%s features are loading...', ['dpatch' dpatch_svm_type])); 
    for cat = 1:length(scene_cats)
        if exist('patch_paths', 'var')
            cat_inds = find(cell2mat(cellfun(@(x) ~isempty(strfind(x{1}, ...
                                                              scene_cats{cat})),patch_paths, 'UniformOutput', 0)));
        else
            cat_inds = (cat-1)*100+1:(cat-1)*100+num_patches;
            % disp(['start ind for patches ' num2str(cat_inds(1)) ...
            %      ' and num patches ' num2str(num_patches) ' cat number ' num2str(cat)]);

        end
        if length(cat_inds) > num_patches
            cat_inds = cat_inds(1:num_patches);
        end
        patches_to_include(cat_inds) = 1;
    end
    patches_to_include = logical(patches_to_include);
    num_training_patches_used{cur_type_ind}(nind) = sum(patches_to_include);
    nind = nind+1;
    % pack features
    % NOTE: features are the dpatch responses for the top N dpatches discovered
    % for each scene category, i.e. dpatch_feat_matrix = [N*indv_dpatch_feature_vector_size*15 x num_images]
    % does feature matrix exist?

    feat_matrix_name = sprintf('%s_image_spm_features_num_patches_%d.mat', [['dpatch' dpatch_svm_type] ...
                        '_' ranking_type{rank}], num_patches);
disp(feat_matrix_name);
    if(~exist(fullfile(sc.save_path,feat_matrix_name), 'file'))

        tic;
        %change this to be the number of levels of resolution
        feature_vector = pack_features_SPM([['dpatch' dpatch_svm_type] '_' ...
                            ranking_type{rank}],imgs, 19,patches_to_include);

        toc;
        disp(['this is how big the feature matrix is for ' ...
              num2str(num_patches)]);
        size(feature_vector)
        save(fullfile(sc.save_path,feat_matrix_name), 'feature_vector', '-v7.3');
    else
        load(fullfile(sc.save_path,feat_matrix_name));
    end
    disp(sprintf('%s features are packed', ['dpatch' dpatch_svm_type]));
    
    for num_feat = 1:n

    if ~exist([sc.svm_path 'SVM_Result_' sc.feat(num_feat).name '_' sc.feat(num_feat).kernel_name '_'...
               sprintf('%.4d',length(train_inds)) sprintf('_%d_%d.mat',num_patches,rank)],'file')    
    % calculate master kernel
    kernel_name = sprintf('train_test_kernel_%s_%s_%d_%d.mat',sc.feat(num_feat).name, ...
                          sc.feat(num_feat).kernel_name, num_patches, rank);
    if (~exist(fullfile(sc.kernel_path, kernel_name), 'file'))
        % compute training and testing kernels
        %        keyboard

        [K, K_test] = kernel(feature_vector(train_inds, :)', feature_vector(test_inds, ...
                                                          :)', sc.feat(num_feat));

        save(fullfile(sc.kernel_path, kernel_name), 'K', 'K_test', '-v7.3'); 

    else
        load(fullfile(sc.kernel_path, kernel_name));
    end
    disp(sprintf('%s kernels are computed', sc.feat(num_feat).name));

    % for each class
    num_classes = length(scene_cats);
    class_train = zeros(size(train_inds));
    class_test = zeros(size(test_inds));
    for cat = 1:num_classes
        class_train(~arrayfun(@(x) isempty(strfind(x.city, scene_cats{cat})), imgs_train)) = cat;
        class_test(~arrayfun(@(x) isempty(strfind(x.city, scene_cats{cat})), imgs_test)) = cat;
    end    
    % train svm
    disp('now training svm!');

        %keyboard
        % make this grid
        if ~isparallel
            score_test = svm_one_vs_all(K,K_test,class_train,num_classes); ...
                
        else
            base_path = ['SVM_Result_' sc.feat(num_feat).name '_' sc.feat(num_feat).kernel_name '_'...
                  sprintf('%.4d',length(train_inds)) sprintf('_%d_%d',num_patches,rank)];
            svm_input_load_file = fullfile(sc.svm_path, [base_path '_svm_input_load_file.mat']);
            score_test_save_file = fullfile(sc.svm_path, [base_path '_score_test_save_file.mat']);

            if exist(score_test_save_file, 'file')
                    load(score_test_save_file);
            else

                save(svm_input_load_file,'K','K_test','class_train', ...
                     'num_classes', '-v7.3');

                        log_path = '/data/hays_lab/people/gen/grid_out/scene_class_SPM/';
                        logdir = fullfile(log_path, base_path);
                        if(~exist(logdir, 'dir'))
                            mkdir(logdir);
                        end

                        logfileerr = fullfile(logdir, ['qsub_out.err'])
                        logfileout = fullfile(logdir, ['qsub_out.out'])


                        tmpFuncCall = sprintf( 'svm_one_vs_all_grid_run.sh %s %s',svm_input_load_file, ...
                                                      score_test_save_file);
                        %                keyboard
                        qsub_cmd = ['qsub -N sc' num2str(rand()) ' -l short' ' -e ' logfileerr ' -o ' logfileout ' ' tmpFuncCall];
                        unix(qsub_cmd);
                        continue;
            end
        end



        % evaluation multi-class
        %keyboard
        [confidence,class_hat] = max(score_test, [], 2);
        C = confusionMatrix(class_test,class_hat');
        disp(sprintf('#train = %.4d num_patces = %d  Performance = %f %%',length(train_inds),num_patches,mean(diag(C))));
        %todo: should I calculate ap too?

        for cat = 1:num_classes
            [~,si]=sort(score_test(:, cat),'descend');
            sclass_hat = class_hat(si)';
            sclass_test = class_test(si)';

            tp = (sclass_test == cat);
            fp = (sclass_test ~= cat);
            npos = numel(find(sclass_test == cat));
            % only for attribute dataset -- compute precision/recall        
            % ap and accuracy        
            fp=cumsum(fp);
            tp=cumsum(tp);
            rec=tp/npos;
            prec=tp./(fp+tp);

            ap(cat,1)=VOCap(rec,prec);
            if(isnan(ap(cat,1)))
                ap = 0.0;
            end
            disp(sprintf('category = %s   Average Precision = %f ', ...
                         scene_cats{cat},ap(cat,1)));
        end
        all_ap(num_feat,num_patches, 1:length(ap), cur_type_ind) = ap;
        % save result
        save([sc.svm_path 'SVM_Result_' sc.feat(num_feat).name '_' sc.feat(num_feat).kernel_name '_'...
              sprintf('%.4d',length(train_inds)) sprintf('_%d_%d.mat', ...
                                                         num_patches, ...
                                                         rank)], ...
             'class_hat','score_test','confidence', 'C', 'ap', '-v7.3');  
        all_perf{cur_type_ind}(num_feat, num_patches) = mean(diag(C));
    else
        load([sc.svm_path 'SVM_Result_' sc.feat(num_feat).name '_' sc.feat(num_feat).kernel_name '_' sprintf('%.4d',length(train_inds)) sprintf('_%d_%d.mat',num_patches,rank)]);
        disp('this svm already exists');
        disp(sprintf('#train = %.4d   Performance = %f %%', ...
                     length(train_inds),mean(diag(C))));
        all_perf{cur_type_ind}(num_feat, num_patches) = mean(diag(C));
        all_ap(num_feat,num_patches, 1:length(ap), cur_type_ind) = ap;
    end
disp(['done with num feat' num2str(num_feat)]);
%keyboard
    %end num_feat
    end
disp(['done with num feat' num2str(num_patches)]);
%end num_patches
end


%keyboard
save_name = [sc.svm_path 'SVM_Result_' sc.feat(num_feat).name '_' sc.feat(num_feat).kernel_name '_' sprintf('%.4d',length(train_inds)) sprintf('_all_perf_%s.mat',[ranking_type{rank} dpatch_svm_type])];
%all_perf = all_perf{rank}{sub}(:, num_training_patches);
if(exist('all_perf','var'))
    save(save_name, 'all_perf', 'all_ap', 'num_training_patches_used', '-v7.3');
else
    re_run = 1;
end

% figure
% plot(num_training_patches_used,all_perf','-s')
% ylabel('Performance (%)')
% xlabel('Number of Patches')
% legend(sc.feat(:).kernel_name, 4)
% keyboard
%end subrank
disp(['finished with rank ' num2str(rank) ' subrank ' num2str(sub)]);
cur_type_ind = cur_type_ind +1;
end
%end rank
end

if(re_run)
    %    scene_classifier_main
end
catch e
    disp([' scene_classifer_main broke! we are keyboarding out at the place ' ...
          'where the error happened...']);
    disp(e.message);
    e.stack.name
    e.stack.line
    keyboard
end