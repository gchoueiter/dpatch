load('dataset15.mat'); 

%gen change
%% TODO: need to change 'imgs' so it only contains training images,
%% i.e. first 150 images from every scene class

scene_cats=unique(arrayfun(@(x) x.city,imgs,'UniformOutput', ...
                           false));
numfile = 0;
for sc = 1:length(scene_cats)
    [~,b] = system([' ls -l /data/hays_lab/15_scene_dataset/' ...
                    'features_pyra/dpatch_linear_nearestneighbors/' ...
                    scene_cats{sc} ' | wc -l']);

    numfile = numfile+(str2num(b)-1);

end
numfile

numfile = 0;
for sc = 1:length(scene_cats)
    [~,b] = system([' ls -l /data/hays_lab/15_scene_dataset/' ...
                    'features_pyra/dpatch_posterior/' ...
                    scene_cats{sc} ' | wc -l']);

    numfile = numfile+(str2num(b)-1);

end
numfile