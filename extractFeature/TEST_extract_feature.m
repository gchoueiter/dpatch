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
%passed...
%launch_dpatch_eval(223, 456);

%disp('this should be 0');
%sum(GVARS.job_stat)

%GVARS.isparallel = 1;
%launch_dpatch_eval(221, 455);
%disp('this should be 0');
%sum(GVARS.job_stat)


%test extract_feature
img_name2 = 'store/image_0151.jpg';
img_path = '/data/hays_lab/15_scene_dataset/';
img_name = 'store/image_0152.jpg';
img_name3 = 'CALsuburb/image_0151.jpg';
% tic
% extract_feature(img_name, img_path, ['/home/gen/dpatch/' ...
%                     'extractFeature/test_out'], 5, 0, ['/home/gen/' ...
%                 'dpatch/extractFeature/test_log/'])
% toc
% tic
% extract_feature(img_name2, img_path, ['/home/gen/dpatch/' ...
%                     'extractFeature/test_out'], 5, 0, ['/home/gen/' ...
%                 'dpatch/extractFeature/test_log/'])
% toc
% tic
% extract_feature(img_name3, img_path, ['/home/gen/dpatch/' ...
%                     'extractFeature/test_out'], 5, 0, ['/home/gen/' ...
%                 'dpatch/extractFeature/test_log/'])
% toc
% check that features for imgs 1 2 3 are not the same
res_path = '/home/gen/dpatch/extractFeature/test_out/';
   last_stroke = strfind(img_name, '/');
   last_stroke = last_stroke(end);
res1 = [res_path img_name(1:end-4) img_name(last_stroke:end-4) ...
        '.mat'];
   last_stroke = strfind(img_name2, '/');
   last_stroke = last_stroke(end);
res2 = [res_path img_name2(1:end-4) img_name2(last_stroke:end-4) ...
        '.mat'];
   last_stroke = strfind(img_name3, '/');
   last_stroke = last_stroke(end);
res3 = [res_path img_name3(1:end-4) img_name3(last_stroke:end-4) ...
        '.mat'];
feat1 = load(res1);
feat2 = load(res2);
feat3 = load(res3);

disp(sprintf('%d dpatches fired on image %s', sum(feat1.feat), ...
             img_name));
disp(sprintf('%d dpatches fired on image %s', sum(feat2.feat), ...
             img_name2));
disp(sprintf('%d dpatches fired on image %s', sum(feat3.feat), ...
             img_name3));

% TODO: sanity check, see what fired where...

% run parallel extraction version, see if the features are the same
res_path = '/home/gen/dpatch/extractFeature/test_out/parallel/';
tic
extract_feature(img_name, img_path, res_path, 300, 1, ['/home/gen/' ...
                'dpatch/extractFeature/test_log/'])
evaltime(1) = toc;

tic
extract_feature(img_name2, img_path, res_path, 300, 1, ['/home/gen/' ...
                'dpatch/extractFeature/test_log/'])
evaltime(2) = toc;
tic
extract_feature(img_name3, img_path, res_path, 300, 1, ['/home/gen/' ...
                'dpatch/extractFeature/test_log/'])
evaltime(3) = toc;
% check that features for imgs 1 2 3 are not the same

   last_stroke = strfind(img_name, '/');
   last_stroke = last_stroke(end);
res1 = [res_path img_name(1:end-4) img_name(last_stroke:end-4) ...
        '.mat'];
   last_stroke = strfind(img_name2, '/');
   last_stroke = last_stroke(end);
res2 = [res_path img_name2(1:end-4) img_name2(last_stroke:end-4) ...
        '.mat'];
   last_stroke = strfind(img_name3, '/');
   last_stroke = last_stroke(end);
res3 = [res_path img_name3(1:end-4) img_name3(last_stroke:end-4) ...
        '.mat'];
feat4 = load(res1);
feat5 = load(res2);
feat6 = load(res3);
disp(sprintf('%d dpatches fired on image %s', sum(feat1.feat), ...
             img_name));
disp(sprintf('%d dpatches fired on image %s', sum(feat2.feat), ...
             img_name2));
disp(sprintf('%d dpatches fired on image %s', sum(feat3.feat), ...
             img_name3));
disp(sprintf('%d dpatches fired on image %s', sum(feat4.feat), ...
             img_name));
disp(sprintf('%d dpatches fired on image %s', sum(feat5.feat), ...
             img_name2));
disp(sprintf('%d dpatches fired on image %s', sum(feat6.feat), ...
             img_name3));
