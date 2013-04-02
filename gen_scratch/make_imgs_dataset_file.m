% this makes a mat file that contains an array of structs
% these structs hold the information on the images in a dataset in the
% format for the CMU discriminative patches discovery code.

% format: array of structs - dimension N = number of images in datset
%         fields of struct - 
%     fullpath: '/data/hays_lab/15_scene_dataset/bedroom/image_0001.jpg'
%         city: 'bedroom'
%       imsize: [200 267]
%     fullname: 'bedroom/image_0001.jpg'

% for dir
data_path = '/data/hays_lab/pascal_07/VOCdevkit/VOC2007/'
imgs_path = fullfile(data_path, 'JPEGImages');
labels_path = fullfile(data_path, 'ImageSets/Main');
% list all images
ann_files = dir(labels_path);
cats = unique(arrayfun(@(x) strtok(x.name,'_'), ann_files(3:end), 'UniformOutput', false));
cats = cats([1:18 20 23]);
%for cats, load labels
%5011 - num trainval examples in voc 2007
cat_labels = zeros(length(cats), 5011);
trainval_imgs = [];
for c = 1:length(cats)
    fid = fopen(fullfile(labels_path, [cats{c} '_trainval.txt']));
    text = textscan(fid, '%s %d');
    trainval_imgs = text{1,1};
    cat_labels(c, :) = text{1,2};
    fclose(fid);
end
% for all images
for i = 1:size(cat_labels, 2)
% read them, get their size
imgs(i).fullpath = fullfile(imgs_path, [trainval_imgs{i} '.jpg']);
imgs(i).city = cats{cat_labels(:,i)==1};
img_temp = imread(imgs(i).fullpath);
imgs(i).imsize = size(img_temp);
imgs(i).fullname = [trainval_imgs{i} '.jpg'];
% add their info to the array imgs

end
keyboard
save('dataset20.mat', 'imgs');