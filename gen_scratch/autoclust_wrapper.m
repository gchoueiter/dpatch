function autoclust_wrapper(scene_cat_ind)
scene_cat_ind = str2double(scene_cat_ind);
cd ..
load('dataset15.mat');
scene_cats=unique(arrayfun(@(x) x.city,imgs,'UniformOutput', ...
                           false));
cat_str = scene_cats{scene_cat_ind};
disp(sprintf('calling dpatch clustering for %s ...',cat_str));
autoclust_main_15scene

end
