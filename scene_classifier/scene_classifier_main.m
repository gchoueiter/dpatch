% tests scene classification 
%% IMPORTANT: run extract feature for all images first. The extract
%% feature here is just a catch in case.
try
global sc;
ranking_type = {'overallcounts', 'posterior', 'nearestneighbors'};
svm_type = {'linear', 'polynomial', 'rbf', 'sigmoid'};
for rank = 1:3
for sub = 1:4
data_path = ...%'/data/hays_lab/finder/Discriminative_Patch_Discovery/try2/';
            ['/data/hays_lab/finder/Discriminative_Patch_Discovery/' ...
             '15_scene_patches/' ranking_type{rank} '/'];
if rank ~=3
    load(fullfile(data_path, 'detectors.mat'));
    if sub>1
        continue;
    end
else
    load(fullfile(data_path, ['detectors_' svm_type{sub} '.mat']));
end

sc.njobs = 900;
sc.isparallel = 0;
sc.log_path = '/data/hays_lab/finder/Discriminative_Patch_Discovery/15scene/logs/';
if(~exist(sc.log_path, 'dir'))
    mkdir(sc.log_path);    
end

% for 15 classes dataset
sc.img_path = '/data/hays_lab/15_scene_dataset/';
sc.save_path = '/data/hays_lab/finder/Discriminative_Patch_Discovery/15scene_classifiers/';
sc.feat_path   = fullfile(sc.img_path, 'features/');%sc.save_path, 'features/');
sc.kernel_path = fullfile(sc.save_path, 'kernels/');
if(~exist(sc.kernel_path,'dir'))
    mkdir(sc.kernel_path);
end
sc.svm_path = fullfile(sc.save_path, 'svms/');
if(~exist(sc.svm_path,'dir'))
    mkdir(sc.svm_path);
end
sc.dataset = '/home/gen/dpatch/dataset15.mat';
load(sc.dataset);
if rank == 3
    dpatch_svm_type = ['_' svm_type{sub}];
else
    dpatch_svm_type = '';
end
sc.detectors_fname = fullfile(data_path, ['detectors' dpatch_svm_type '.mat']);
% include libsvm for training svms
addpath(genpath('/home/gen/libsvm-mat-3.0-1'));

if(~exist(sc.save_path, 'dir'))
    mkdir(sc.save_path);
    mkdir(sc.feat_path);
    mkdir(sc.kernel_path);
    mkdir(sc.svm_path);
end

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
    train_inds = horzcat(train_inds, cat_inds(1:150));
    test_inds = horzcat(test_inds, cat_inds(151:end));
    
end
imgs_train = imgs(train_inds);
imgs_test = imgs(test_inds);
disp('train and test images!');
fprintf('num train images %d\n', length(imgs_train)); 
fprintf('num test images %d\n', length(imgs_test)); 
% set up type of features to use
n = 1;
sc.feat(n).name = 'dpatch';
sc.feat(n).kernel_name = 'rbf';
n = 2;
sc.feat(n).name = 'dpatch';
sc.feat(n).kernel_name = 'kchi2';
n = 3;
sc.feat(n).name = 'dpatch';
sc.feat(n).kernel_name = 'kl2';
n = 4;
sc.feat(n).name = 'dpatch';
sc.feat(n).kernel_name = 'kl1';

num_training_patches = [1 5 10 50 100]; %num patches per category
num_training_patches(num_training_patches>length(detectors.firstLevModels.info))= length(detectors.firstLevModels.info);
num_training_patches = unique(num_training_patches);

num_training_patches_used = zeros(size(num_training_patches));


% NOTE: this iterates through num_feat number of different features
%       and num_patches number of training patches
nind = 1;
for num_patches = num_training_patches
    patches_to_include = zeros(length(detectors.firstLevModels.info),1);
    for cat = 1:length(scene_cats)
        if isfield(detectors, 'patch_paths')
            cat_inds = find(cell2mat(cellfun(@(x) ~isempty(strfind(x{1}, ...
                                                              scene_cats{cat})),detectors.patch_paths, 'UniformOutput', 0)));
        else
            cat_inds = (cat-1)*100+1:(cat-1)*100+num_patches;
            numel(cat_inds)
            num_patches
        end
        if length(cat_inds) > num_patches
            cat_inds = cat_inds(1:num_patches);
        end
        patches_to_include(cat_inds) = 1;
    end
    patches_to_include = logical(patches_to_include);
    num_training_patches_used(nind) = sum(patches_to_include);
    nind = nind+1;
for num_feat = 1:n
    
if ~exist([sc.svm_path 'SVM_Result_' sc.feat(num_feat).name '_' sc.feat(num_feat).kernel_name '_'...
           sprintf('%.4d',length(train_inds)) sprintf('_%d_%d.mat',num_patches,rank)],'file')    
% pack features
% NOTE: features are the dpatch responses for the top N dpatches discovered
% for each scene category, i.e. dpatch_feat_matrix = [N*indv_dpatch_feature_vector_size*15 x num_images]

% does feature matrix exist?
clear feature_vector K K_test
feat_matrix_name = sprintf('%s_image_features.mat',sc.feat(num_feat).name);
if(~exist(fullfile(sc.feat_path,feat_matrix_name), 'file'))
    if rank == 3
        dpatch_svm_type = ['_' svm_type{sub}];
    else
        dpatch_svm_type = '';
    end
    feature_vector = pack_features([sc.feat(num_feat).name '_' ranking_type{rank} ...
                   dpatch_svm_type],imgs,patches_to_include);
    save(feat_matrix_name, 'feature_vector');
else
    load(feat_matrix_name);
end
disp(sprintf('%s features are packed', sc.feat(num_feat).name));

% calculate master kernel
kernel_name = sprintf('train_test_kernel_%s_%s_%d_%d.mat',sc.feat(num_feat).name, ...
                      sc.feat(num_feat).kernel_name, num_patches, rank);
if (~exist(fullfile(sc.kernel_path, kernel_name), 'file'))
    % compute training and testing kernels
    %    keyboard
    [K, K_test] = kernel(feature_vector(train_inds, :)', feature_vector(test_inds, ...
                                                      :)', sc.feat(num_feat));

    save(fullfile(sc.kernel_path, kernel_name), 'K', 'K_test'); 
        
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
    score_test = svm_one_vs_all(K,K_test,class_train,num_classes);        
    % evaluation multi-class
    %keyboard
    [confidence,class_hat] = max(score_test, [], 2);
    C = confusionMatrix(class_test,class_hat');
    disp(sprintf('#train = %.4d   Performance = %f %%',length(train_inds),mean(diag(C))));
    %todo: should I calculate ap too?
    all_perf(num_feat, num_patches,rank) = mean(diag(C));
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
    all_ap{num_feat,num_patches,rank} = ap;
    % save result
    save([sc.svm_path 'SVM_Result_' sc.feat(num_feat).name '_' sc.feat(num_feat).kernel_name '_'...
          sprintf('%.4d',length(train_inds)) sprintf('_%d_%d.mat',num_patches,rank)],'class_hat','score_test','confidence', 'C', 'ap');
else
    load([sc.svm_path 'SVM_Result_' sc.feat(num_feat).name '_' sc.feat(num_feat).kernel_name '_' sprintf('%.4d',length(train_inds)) sprintf('_%d_%d.mat',num_patches,rank)]);
    disp('this svm already exists');
    disp(sprintf('#train = %.4d   Performance = %f %%', ...
                 length(train_inds),mean(diag(C))));
    all_perf(num_feat, num_patches,rank) = mean(diag(C));
    all_ap{num_feat,num_patches,rank} = ap;
end

%end num_feat
end
%end num_patches
end
%keyboard
save_name = [sc.svm_path 'SVM_Result_' sc.feat(num_feat).name '_' sc.feat(num_feat).kernel_name '_' sprintf('%.4d',length(train_inds)) sprintf('_all_perf_%s.mat',ranking_type{rank})];
all_perf = all_perf(:, num_training_patches,rank);
all_ap = all_ap(:, num_training_patches,rank);
save(save_name, 'all_perf', 'all_ap');

% figure
% plot(num_training_patches_used,all_perf','-s')
% ylabel('Performance (%)')
% xlabel('Number of Patches')
% legend(sc.feat(:).kernel_name, 4)
% keyboard
%end subrank
end
%end rank
end
catch e
    disp([' scene_classifer_main broke! we are keyboarding out at the place ' ...
          'where the error happened...']);
    disp(e.message);
    e.stack.name
    e.stack.line
    keyboard
end
