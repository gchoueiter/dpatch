%for auto and human patches
%pack_features(feat_name, imgs, patches_to_include)
ranking_type = {'overallcounts', 'posterior', 'nearestneighbors'};
svm_type = {'linear', 'polynomial', 'rbf', 'sigmoid'};

for rank = rankrank
for sub = subsub
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

% for 15 classes dataset
sc.img_path = '/data/hays_lab/15_scene_dataset/';
sc.save_path = '/data/hays_lab/finder/Discriminative_Patch_Discovery/15scene_classifiers/';
sc.feat_path   = fullfile(sc.img_path, 'features/');%sc.save_path, 'features/');         
   sc.dataset = '/home/gen/dpatch/dataset15.mat';
load(sc.dataset);
if rank == 3
    dpatch_svm_type = ['_' svm_type{sub}];
else
    dpatch_svm_type = '';
end
sc.detectors_fname = fullfile(data_path, ['detectors' dpatch_svm_type '.mat']);
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

% NOTE: this is only making the viz for the 15D patch feature

num_training_patches = 1; %num patches per category
num_training_patches(num_training_patches>length(detectors.firstLevModels.info))= length(detectors.firstLevModels.info);
num_training_patches = unique(num_training_patches);

num_patches = num_training_patches

 patches_to_include = zeros(length(detectors.firstLevModels.info),1);

    for cat = 1:length(scene_cats)
        if isfield(detectors, 'patch_paths')
            cat_inds = find(cell2mat(cellfun(@(x) ~isempty(strfind(x{1}, ...
                                                              scene_cats{cat})),detectors.patch_paths, 'UniformOutput', 0)));
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
    
% go through 15D feature responses - save location of highest confidence
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
feats_cell = {length(imgs),1};
num_feat =1
feat_name = [sc.feat(num_feat).name '_' ranking_type{rank}]
patch_nums = find(patches_to_include);
params= struct( 'imageCanonicalSize', 400,...% images are resized so that their smallest dimension is this size.
  'patchCanonicalSize', {[80 80]}, ...% patches are extracted at this size.  Should be a multiple of sBins.
  'scaleIntervals', 8, ...% number of levels per octave in the HOG pyramid 
  'sBins', 8, ...% HOG sBins parameter--i.e. the width in height (in pixels) of each cell
  'useColor', 1, ...% include a tiny image (the a,b components of the Lab representation) in the patch descriptor
  'patchOverlapThreshold', 0.6, ...%detections (and random samples during initialization) with an overlap higher than this are discarded.
  'svmflags', '-s 0 -t 0 -c 0.1');
for ip = 1:length(patch_nums)
    p = patch_nums(ip);
    max_confs = zeros(length(test_inds),3);
    ind = 1;
for i = test_inds
    disp(['cur img test' num2str(ind)]);
    [a,b] = strtok(imgs(i).fullname,'/');
    last_stroke = length(a)+1;
    feat_save_path = fullfile(sc.feat_path, feat_name, imgs(i).fullname(1:end-4),[imgs(i).fullname(last_stroke+1:end-4) '_dpatch_tmp_feat_' num2str(p) '.mat']);
    load(feat_save_path);
    [Y,I] = max(feat.svmout{1});
    [Y2,I2] = max(Y);
    max_confs(ind,1) = Y2;
    max_confs(ind,2) = I(I2);
    max_confs(ind,3) = I2;
    ind = ind+1;
end
% take top 20 confidences
[~,topConfInds] = sort(max_confs(:,1),'descend');
%imgs(test_inds(topConfInds(1:20))).fullpath;
top_test_detections = [];
for curim = 1:20
% crop patches at that location
    img = im2double(imread(imgs(test_inds(topConfInds(curim))).fullpath));
    [I1, canoScale] = convertToCanonicalSize(img, params.imageCanonicalSize);
    %patch loc = params.sBins+index*sBins
    center = params.sBins+max_confs(topConfInds(curim),2:3)*params.sBins;
    patch = I1(max(1,center(1)-40):min(size(I1,1),center(1)+40),max(1,center(2)-40):min(size(I1,2),center(2)+40));
    if(isempty(top_test_detections))
        top_test_detections = imresize(patch,[80 80]);
    else
        try
         top_test_detections = horzcat(top_test_detections, horzcat(ones(80,10), imresize(patch,[80 80])));
        catch
            keyboard
        end
    end
    

  
end
% save figure
imwrite( top_test_detections , ['/home/gen/dpatch/dpatch_paper/topTestDetections_' feat_name '_' num2str(p) '.png']);
clear top_test_detections

% detections for training set
max_confs = zeros(length(test_inds),3);
ind = 1;
for i = train_inds
    disp(['cur img train' num2str(ind)]);
    [a,b] = strtok(imgs(i).fullname,'/');
    last_stroke = length(a)+1;
    feat_save_path = fullfile(sc.feat_path, feat_name, imgs(i).fullname(1:end-4),[imgs(i).fullname(last_stroke+1:end-4) '_dpatch_tmp_feat_' num2str(p) '.mat']);
    load(feat_save_path);
    [Y,I] = max(feat.svmout{1});
    [Y2,I2] = max(Y);
    max_confs(ind,1) = Y2;
    max_confs(ind,2) = I(I2);
    max_confs(ind,3) = I2;
    ind = ind+1;
end
% take top 20 confidences
[~,topConfInds] = sort(max_confs(:,1),'descend');
%imgs(test_inds(topConfInds(1:20))).fullpath;
top_train_detections = [];
for curim = 1:20
% crop patches at that location
    img = im2double(imread(imgs(train_inds(topConfInds(curim))).fullpath));
    [I1, canoScale] = convertToCanonicalSize(img, params.imageCanonicalSize);
    %patch loc = params.sBins+index*sBins
    center = params.sBins+max_confs(topConfInds(curim),2:3)*params.sBins;
    patch = I1(max(1,center(1)-40):min(size(I1,1),center(1)+40),max(1,center(2)-40):min(size(I1,2),center(2)+40));
    if(isempty(top_train_detections))
        top_train_detections = imresize(patch,[80 80]);
    else
        try
         top_train_detections = horzcat(top_train_detections, horzcat(ones(80,10), imresize(patch,[80 80])));
        catch
            keyboard
        end
    end
    

  
end
% save figure
imwrite( top_train_detections , ['/home/gen/dpatch/dpatch_paper/topTrainDetections_' feat_name '_' num2str(p) '.png']);
clear top_test_detections


end

% REPEAT for training set

end
end