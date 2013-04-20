rank = 3
possible_fnames = {'detsDclust_linear.mat','detsDclust_polynomial.mat', ...
                   'detsDclust_rbf.mat','detsDclust_sigmoid.mat'};
for i =1:4
    detectors_fname = possible_fnames{i};
    make_detectors_file;

end