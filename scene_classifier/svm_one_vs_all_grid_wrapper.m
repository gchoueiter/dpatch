function svm_one_vs_all_grid_wrapper(load_file,save_file);
%    keyboard
addpath(genpath('/home/gen/libsvm-mat-3.0-1'));
addpath(genpath('/home/gen/dpatch'));
    load(load_file);
    score_test = svm_one_vs_all(K,K_test,class_train,num_classes);        
    save(save_file,'score_test','-v7.3');
end