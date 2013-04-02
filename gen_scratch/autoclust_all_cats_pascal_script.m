% runs autoclust_main for all categories in dataset
%function autoclust_wrapper(scene_cat_ind)%, r_ind)
% scene_cat_ind = str2double(scene_cat_ind);
cd '/home/gen/dpatch/'
load('dataset20.mat');
cats=unique(arrayfun(@(x) x.city,imgs,'UniformOutput', ...
                       false));
for cat_ind = 1:length(cats)        
    %keyboard
    cat_str = cats{cat_ind};    
    disp(sprintf('calling dpatch clustering for %s ...',cat_str));
    autoclust_main_pascal

    %send mail to say that cat finished...
    status= system(['echo "done." | mail -s "dpatches finished for ' cat_str ...
                    '" gen@cs.brown.edu']);
    clear ds
end
