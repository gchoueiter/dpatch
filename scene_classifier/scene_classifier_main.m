% tests scene classification 
global sc;

sc.njobs = 150;
sc.isparallel = 1;
sc.log_path = '/data/hays_lab/finder/Discriminative_Patch_Discovery/15scene/logs/';
if(~exist(sc.log_path, 'dir'))
    mkdir(sc.log_path);    
end

% for 15 classes dataset
sc.save_path = '/data/hays_lab/finder/Discriminative_Patch_Discovery/15scene/';
sc.feat_path   = fullfile(sc.save_path, 'features/');
sc.kernel_path = fullfile(sc.save_path, 'kernels/');
sc.svm_path = fullfile(sc.save_path, 'svms/');
sc.dataset = '/home/gen/dpatch/dataset15.mat';
load(sc.dataset);
sc.npatch_fname = '/home/gen/dpatch/detectors15.mat';
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
    train_inds = horzcat(train_inds, cat_inds(1:150));
    test_inds = horzcat(test_inds, cat_inds(151:end));
    
end
imgs_train = imgs(train_inds);
imgs_test = imgs(test_inds);

% set up type of features to use
num_feat = 1;
sc.feat(num_feat).name = 'dpatch';
sc.feat(num_feat).kernel_name = 'kl2';

% NOTE: this could iterate through num_feat number of different features

% pack features
% NOTE: features are the dpatch responses for the top N dpatches discovered
% for each scene category, i.e. dpatch_feat_matrix = [N*indv_dpatch_feature_vector_size*15 x num_images]

% does feature matrix exist?
feat_matrix_name = sprintf('%s_image_features.mat',sc.feat(num_feat).name);
if(~exist(fullfile(sc.feat_path,feat_matrix_name), 'file'))
    feature_vector = pack_features(sc.feat(num_feat).name,imgs);
    save(feat_matrix_name, 'feature_vector');
else
    load(feat_matrix_name);
end
disp(sprintf('%s features are packed', sc.feat(num_feat).name));

% calculate master kernel
kernel_name = sprintf('master_kernel_%s.mat',sc.feat(num_feat).name);
if (~exist(fullfile(sc.kernel_path, kernel_name), 'file'))
    % compute training and testing kernels
    master_kernel = kernel(feature_vector, sc.feat(num_feat).name);
    save(fullfile(sc.kernel_path, kernel_name), 'master_kernel');            
else
    load(fullfile(sc.kernel_path, kernel_name));
end
disp(sprintf('%s kernels are computed', sc.feat(num_feat).name));

% sub-sample kernel
K = master_kernel(train_inds, train_inds);
K_test = master_kernel(test_inds, test_inds);

% for each class
num_classes = length(scene_cats);
class_train = zeros(size(train_inds));
class_test = zeros(size(test_inds));
for cat = 1:num_classes
    class_train(~arrayfun(@(x) isempty(strfind(x.city, scene_cats{cat})), imgs_train)) = cat;
    class_test(~arrayfun(@(x) isempty(strfind(x.city, scene_cats{cat})), imgs_test)) = cat;
end    
% train svm
if ~exist([sc.svm_path 'SVM_Result_' sc.feat(num_feat).name '_' sprintf('%.4d',length(train_inds)) '.mat'],'file')
    score_test = svm_one_vs_all(K,K_test,class_train,num_classes);        
    % evaluation multi-class
    [confidence,class_hat] = max(score_test, [], 2);
    C = confusionMatrix(class_test,class_hat');
    disp(sprintf('#train = %.4d   Performance = %f %%',num_train,mean(diag(C))));
    
    % save result
    save([sc.svm_path 'SVM_Result_' sc.feat(num_feat).name '_' sprintf('%.4d',length(train_inds)) '.mat'],'class_hat','score_test','confidence', 'C');
else
    load([sc.svm_path 'SVM_Result_' sc.feat(num_feat).name '_' sprintf('%.4d',length(train_inds)) '.mat']);
    disp('this svm already exists');
    disp(sprintf('#train = %.4d   Performance = %f %%',num_train,mean(diag(C))));
end

