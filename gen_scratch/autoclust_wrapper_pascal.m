function autoclust_wrapper_pascal(cat_ind_str)%, r_ind)
cat_ind = str2double(cat_ind_str);
cd '/home/gen/dpatch/'
load('dataset20.mat');
load('pascal_cats.mat')


cat_str = cats{cat_ind};
% ranking = 1 : overallcounts, ranking = 2 : posterior
ranking=1;%str2double(r_ind);
disp(sprintf('calling dpatch clustering for %s overallcounts...',cat_str));
autoclust_main_pascal
%ranking=2;%str2double(r_ind);
%disp(sprintf('calling dpatch clustering for %s posterior...',cat_str));
%autoclust_main_pascal
end
