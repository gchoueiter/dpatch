% gen
% script for testing output of extract_feature
global GVARS

GVARS.job_stat = zeros(500,1);
GVARS.patch_path = '.';
GVARS.isparallel = 0;
GVARS.img_name = 'test_img';
GVARS.save_path = '/home/gen/dpatch/extractFeature/test_out/';
GVARS.log_path = '/home/gen/dpatch/extractFeature/test_log/';

%test launch_dpatch_eval

launch_dpatch_eval(223, 456);

disp('this should be 0');
sum(GVARS.job_stat)

GVARS.isparallel = 1;
launch_dpatch_eval(221, 455);
disp('this should be 0');
sum(GVARS.job_stat)


%test extract_feature
extract_feature('imtest', '/home/gen/dpatch/extractFeature/test_out', 5, 0)
ls test_out/imtest
extract_feature('imtest2', '/home/gen/dpatch/extractFeature/test_out', 5, 0)
ls test_out/imtest2
