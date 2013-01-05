% gen
%calculates dpatch feature

function extract_feature(img_name, save_path, njobs, isparallel, log_path)

%GVARS is a struct that holds variables used in the functions below
global GVARS

if nargin < 5
    log_path ='.';
end

% variable that save busy state of jobs (0-free, 1-busy)
GVARS.job_stat = zeros(njobs,1);
GVARS.njobs = njobs;
%% TODO: load info about where dpatches are and how many there are
GVARS.npatches = 10;
GVARS.patch_path = '.';

if(strcmp(img_name(end-3), '.'))

    img_name = img_name(1:end-4);
end
GVARS.img_name = img_name;
GVARS.save_path = fullfile(save_path,img_name,'/');
if(~exist(GVARS.save_path, 'dir'))
    mkdir(GVARS.save_path);
end
GVARS.isparallel = isparallel;
GVARS.njobs = njobs;
GVARS.log_path = log_path;

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

disp('dpatch features calculated, maxpooling...');

%load all features and do maxpool
tmp_feats = load_tmp_feats();
final_feats = maxpool(tmp_feats);

%save final feature
feat = pack_feats(final_feats);
save_name = fullfile(GVARS.save_path, [img_name '.mat']);
%keyboard
save(save_name, 'feat');

%delete temp files
delete_tmp_files();


end

function [free_job_id] = check_jobs_avail()
global GVARS

if(sum(GVARS.job_stat) >= GVARS.njobs)
    free_job_id = 0;
else
    free_inds = find(GVARS.job_stat == 0);
    free_job_id = free_inds(1);
end


end

function run_jobs()

global GVARS

%for all the dpatches, while there are jobs
for p = 1:GVARS.npatches
   cur_job = check_jobs_avail();
   while(cur_job == 0)
       sleep(0.5); % TODO: is this a good amount of time?
       cur_job = check_jobs_avail();
   end
   
   % do the conv. func
   % save to result
   launch_dpatch_eval( p, cur_job);

end

end


function [status] = check_patches_complete()
global GVARS

num_patches_complete = sum(~(cell2mat(arrayfun(@(x) isempty(strfind(x.name, 'dpatch_tmp_feat')), ...
                        dir(GVARS.save_path), 'UniformOutput', ...
                                            false))));

if(num_patches_complete == GVARS.npatches)
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
    tmp_feats(f) = {load(fullfile(GVARS.save_path, flist(f).name))};
end

end

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
    cur_feat = reshape(tmp_feats{ft}.feat, tmp_feats{ft}.imsize);
    for r = 1:rows-mp_dim+1
        for c = 1:cols-mp_dim+1
            mp_feat(r,c) = max(max(cur_feat(r:r+mp_dim-1, c:c+mp_dim-1)));
        end
    end
    %11    keyboard
    mp_feat = reshape(mp_feat,(rows-mp_dim+1)*(cols-mp_dim+1),1);
    final_feats(ft) = {struct('feat',mp_feat)};
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

end