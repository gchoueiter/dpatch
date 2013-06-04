initPatches = load('/gpfs/data/hays_lab/finder/Discriminative_Patch_Discovery/15_scene_patches/overallcounts/bedroom/autoclust_main_15scene_out/ds/initPatches.mat')
initPatches
load('/gpfs/data/hays_lab/finder/Discriminative_Patch_Discovery/15_scene_patches/overallcounts/bedroom/autoclust_main_15scene_out/ds/initFeats.mat')
initFeats = load('/gpfs/data/hays_lab/finder/Discriminative_Patch_Discovery/15_scene_patches/overallcounts/bedroom/autoclust_main_15scene_out/ds/initFeats.mat')
load('/gpfs/data/hays_lab/finder/Discriminative_Patch_Discovery/15_scene_patches/overallcounts/bedroom/autoclust_main_15scene_out/ds/initFeatsOrig.mat')
initFeatsOrig = load('/gpfs/data/hays_lab/finder/Discriminative_Patch_Discovery/15_scene_patches/overallcounts/bedroom/autoclust_main_15scene_out/ds/initFeatsOrig.mat')
load('/gpfs/data/hays_lab/finder/Discriminative_Patch_Discovery/15_scene_patches/overallcounts/bedroom/autoclust_main_15scene_out/ds/assignedClust.mat')
ds.assignedClust = data;
data(1:10)
size(assignedClust
size(ds.assignedClust)
ds.assignedClust = [1:1875];
ds.initPatches = initPatches.data;
correspimg=[ds.initPatches.imidx];
currdets=simplifydets(ds.initPatches,correspimg,ds.assignedClust);
cd /home/gen/dpatch
addpath(genpath('.'))
currdets=simplifydets(ds.initPatches,correspimg,ds.assignedClust);
ds.dispoutpath
ds.dispoutpath = '/home/gen/dpatch_test/bedroom/'
mkdir(ds.dispoutpath)

