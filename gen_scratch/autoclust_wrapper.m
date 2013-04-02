function autoclust_wrapper(scene_cat_ind)%, r_ind)
scene_cat_ind = str2double(scene_cat_ind);
cd '/home/gen/dpatch/'
load('dataset15.mat');
scene_cats=unique(arrayfun(@(x) x.city,imgs,'UniformOutput', ...
                           false));
%keyboard
cat_str = scene_cats{scene_cat_ind};
% ranking = 1 : overallcounts, ranking = 2 : posterior
ranking=1;%str2double(r_ind);
disp(sprintf('calling dpatch clustering for %s overallcounts...',cat_str));
autoclust_main_15scene
ranking=2;%str2double(r_ind);
disp(sprintf('calling dpatch clustering for %s posterior...',cat_str));
autoclust_main_15scene
end
