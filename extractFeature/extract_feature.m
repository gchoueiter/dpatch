% gen
%calculates dpatch feature

function extract_feature(img, save_path, njobs, isparallel)

%GVARS is a struct that holds variables used in the functions below
global GVARS

%variable that save busy state of jobs (0-free, 1-busy)
GVARS.job_stat = zeros(njobs,1);
GVARS.njobs = njobs;
%% TODO: load info about where dpatches are and how many there are
GVARS.npatches = 1;
GVARS.patch_path = '.';

run_jobs(img, save_path, njobs, isparallel);

%check that output dir is full
% if there are missing files run calc_patches again.
isjobscomplete = check_jobs_complete(save_path, njobs);
while(~isjobscomplete)
    run_jobs(img, save_path, njobs, isparallel);
    isjobscomplete = check_jobs_complete(save_path, njobs);
end

%load all features and do maxpool

%save final feature

%delete temp files

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

function run_jobs(img, save_path, njobs, isparallel)

%for all the dpatches, while there are jobs
for p = 1:npatches
   cur_job = check_jobs_avail();
   while(cur_job == 0)
       sleep(5); % TODO: is this a good amount of time?
       cur_job = check_jobs_avail();
   end
   
% do the conv. func
% save to output dir
launch_dpatch_eval(img, save_path, p, cur_job, isparallel);

end

end