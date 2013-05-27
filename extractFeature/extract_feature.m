% gen
%calculates dpatch feature

function extract_feature(img_name, img_path, save_path, detectors_fname, ...
                         detection_threshold, njobs, isparallel, log_path)

% there are conflicting versions of some files, so this explicitly
% includes the correct versions
addpath('../');
addpath(genpath('../dswork'));
addpath(genpath('../crossValClustering'));
addpath(genpath('../hog'));
addpath(genpath('../extractFeature'));

%GVARS is a struct that holds variables used in the functions below
global GVARS

if nargin < 5
    njobs = 0;
    isparallel = 0;
    log_path ='.';
end

GVARS.save_path = save_path;

% variable that save busy state of jobs (0-free, 1-busy)
GVARS.rand = sprintf('%8d',floor(rand(1)*1e8));
GVARS.njobs = njobs;
%% TODO: load info about dpatch models
%GVARS.detectors_fname =
%'/data/hays_lab/finder/Discriminative_Patch_Discovery/try2/CALsuburb]/autoclust_main_15scene_out/ds/batch/round6/detectors.mat';
GVARS.detectors_fname = detectors_fname;

% load the dpatch library
load(GVARS.detectors_fname);
GVARS.detectors = detectors;
GVARS.detectionParams = struct( ...
  'selectTopN', false, ...
  'useDecisionThresh', true, ...
  'overlap', 0.4, ...% detections with overlap higher than this are discarded.
  'fixedDecisionThresh', detection_threshold);

%GVARS.img = im2double(imread([img_path img_name]));
GVARS.img_path = img_path;
%if(strcmp(img_name(end-3), '.'))
%    img_name = img_name(1:end-4);
%end
GVARS.img_name = img_name;

GVARS.save_path = fullfile(save_path,img_name(1:end-4),'/');
if(~exist(GVARS.save_path, 'dir'))
    mkdir(GVARS.save_path);
end

last_stroke = strfind(GVARS.img_name, '/');
last_stroke = last_stroke(end);
save_name = fullfile(GVARS.save_path, [GVARS.img_name(last_stroke:end-4) '.mat']);

if(exist(save_name, 'file'))
    disp(['this dpatch feature already calculated- ' save_name]);
    return;
end

GVARS.isparallel = isparallel;
GVARS.njobs = njobs;
GVARS.log_path = log_path;

%params for using spatial pyramid and maxpool or bow
%if GVARS.maxpool is false, then bag of words will be used
GVARS.maxpool = 0;
disp('starting jobs for dpatch extraction...');
run_jobs();

%check that output dir is full
% if there are missing files run calc_patches again.
ispatchescomplete = check_patches_complete();
max_retry = 5;
retry = 1;
while(~ispatchescomplete)
    if(retry > max_retry)
        disp(['extract_feature() failed to complete. Check job log ' ...
              'to determine the recurring error.']);
        return;
    end
    run_jobs();
    ispatchescomplete = check_patches_complete();
    retry = retry + 1;
end
pause(1.5);

disp('dpatch features calculated, packing features...');
%keyboard
%load all features and do maxpool
tmp_feats = load_tmp_feats();

%% TODO: this part should get moved to conv_wrapper
if(GVARS.maxpool)
    final_feats = maxpool(tmp_feats);
else
    final_feats = bow(tmp_feats);
end

%save final feature
feat = pack_feats(final_feats);

%keyboard
 save(save_name, 'feat');
 save(fullfile(save_path,[img_name(1:end-4) '.mat']), 'feat');
 % we're saving the temp files now...%
 %delete temp files
 % delete_tmp_files();

 disp('dpatch feature calculated!');
 end

 function [free_job_stat] = check_jobs_avail()
 global GVARS

 %check qstat for number of jobs running with name ['dp' GVARS.rand]
 %if less than GVARS.njobs, return 1
 [status,running_jobs_str] = unix(['qstat |grep ' ['dp' GVARS.rand] ' |wc -l']);
 running_jobs = str2double(running_jobs_str);
 %[status,running_jobs_str] = unix(['qstat -s p |grep ' ['dp' GVARS.rand] ' |wc -l']);
 %running_jobs = running_jobs + str2double(running_jobs_str);

 free_job_stat = running_jobs < GVARS.njobs;

 end

 function run_jobs()

 global GVARS

 %for all the dpatches, while there are jobs
 %keyboard
for p = 1%:length(GVARS.detectors.firstLevModels.info)
   if(GVARS.isparallel)
       job_avail = check_jobs_avail();
       while(job_avail == 0)
           pause(0.5); % TODO: is this a good amount of time?
           job_avail = check_jobs_avail();
       end
    end   
       % do the conv. func
       % save to result 
       launch_dpatch_eval(); 
end

end


function [status] = check_patches_complete()
global GVARS

num_patches_complete = sum(~(cell2mat(arrayfun(@(x) isempty(strfind(x.name, 'dpatch_tmp_feat')), ...
                        dir(GVARS.save_path), 'UniformOutput', ...
                                            false))));

if(num_patches_complete == length(GVARS.detectors.firstLevModels.info))
    status = 1;
else
    status = 0;
end

end


function [tmp_feats] = load_tmp_feats()
global GVARS

flist = dir(GVARS.save_path);
flist = flist(~cell2mat(arrayfun(@(x) isempty(strfind(x.name, ...
                                                  'dpatch_tmp_feat')), ...
                               flist, 'UniformOutput', false)));
tmp_feats = cell(length(flist),1);
for f = 1:length(flist)

    %the loaded files should contain feat and imsize vars
    try
        tmp_feats(f) = {load(fullfile(GVARS.save_path, flist(f).name))};
    catch e
        disp(e.message);
        disp(e.stack.name);
        disp(e.stack.line);
        % I'm assuming this temp file is corrupted. 
        unix(['rm -f ' fullfile(GVARS.save_path, flist(f).name)]);
        extract_feature(GVARS.img_name, GVARS.img_path, GVARS.save_path, GVARS.detectors_fname, ...
                        0, 0, '');
        return;
    end
end

end

%% TODO: this function is all kinds of messed up
%% for now, I'm using simple bow instead, will come back to fix this
function [final_feats] = maxpool(tmp_feats)
global GVARS
mp_dim = 2;
final_feats = cell(length(tmp_feats),1);
for ft = 1:length(tmp_feats)
    rows = tmp_feats{ft}.imsize(1);
    cols = tmp_feats{ft}.imsize(2);
    mp_feat = zeros((rows-mp_dim+1),(cols-mp_dim+1));

    %NOTE to Tsung-Yi: I don't know if this makes sense, I'm
    %expecting the feature to be a row vector of size
    %[rows*cols,1], so for convenience I'm reshaping it. This may
    %not be a fast operation, so maybe I'll change it later.
    %%TODO: change this bc the output of conv_func isn't quite like
    %%this
    %keyboard
    cur_feat = reshape(tmp_feats{ft}.feat, tmp_feats{ft}.imsize);
    for r = 1:rows-mp_dim+1
        for c = 1:cols-mp_dim+1
            mp_feat(r,c) = max(max(cur_feat(r:r+mp_dim-1, c:c+mp_dim-1)));
        end
    end
    %keyboard
    mp_feat = reshape(mp_feat,(rows-mp_dim+1)*(cols-mp_dim+1),1);
    final_feats(ft) = {struct('feat',mp_feat)};
end
end


% Simple Bag of Words with no spatial pyramid
function [final_feat] = bow(tmp_feats)
global GVARS

for pylvl = 1
    for ft = 1:length(tmp_feats)
        count = numel(find(tmp_feats{ft}.feat.svmout{pylvl} > GVARS.detectionParams.fixedDecisionThresh));
        final_feat(ft) = {struct('feat',count)};
    end
end
end

function [feat] = pack_feats(final_feats)
global GVARS

ftlen = length(final_feats{1}.feat);
feat = zeros(length(final_feats)*ftlen,1);
for ft = 0:length(final_feats)-1

    feat(ft*ftlen+1:(ft+1)*ftlen) = final_feats{ft+1}.feat;
end

end

function delete_tmp_files()
global GVARS

rm_cmd = ['rm -f ' GVARS.save_path '*dpatch_tmp_feat*'];
unix(rm_cmd); 
%sometimes everything doesn't get deleted
[~,r] = unix(['ls ' GVARS.save_path '* | wc -l']);
r = str2double(r);
while(r > 1)
    unix(rm_cmd);
    [~,r] = unix(['ls ' GVARS.save_path '* | wc -l']);
    r = str2double(r);
end
%rm_cmd = ['rm -f ' GVARS.params_fname];
unix(rm_cmd);
%TODO: move final result file up on level and delete the dir
end
