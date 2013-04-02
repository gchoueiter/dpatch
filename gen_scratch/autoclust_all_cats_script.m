% runs autoclust_main for all categories in dataset
%function autoclust_wrapper(scene_cat_ind)%, r_ind)
% scene_cat_ind = str2double(scene_cat_ind);
cd '/home/gen/dpatch/'
load('dataset15.mat');
scene_cats=unique(arrayfun(@(x) x.city,imgs,'UniformOutput', ...
                       false));
for scene_cat_ind = 2:6%7:15        
    %keyboard
    cat_str = scene_cats{scene_cat_ind};    
    disp(sprintf('calling dpatch clustering for %s ...',cat_str));
    autoclust_main_15scene

    %send mail to say that cat finished...
    status= system(['echo "done." | mail -s "dpatches finished for ' cat_str ...
                    '" gen@cs.brown.edu']);
    clear ds
end
