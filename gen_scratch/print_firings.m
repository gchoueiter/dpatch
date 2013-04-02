%img_name = 'MITstreet/image_0001.jpg'
load('/data/hays_lab/15_scene_dataset/images.mat');
scene_cats=unique(cellfun(@(x) x(1:end-15),images,'UniformOutput', ...
                           false));
for cat = 1:length(scene_cats)
    cur_cat_inds = find(cellfun(@(x) strcmp(scene_cats{cat}, x(1:end-15)), images));
    cnt = 0;
for im = cur_cat_inds'
    if(cnt > 10)
        break
    end
    try        
       
img_name = images{im}
% keyboard
            last_stroke = strfind(img_name, '/');
            last_stroke = last_stroke(end);
test_path = '/data/hays_lab/15_scene_dataset';
img = imread(fullfile(test_path, img_name));

load([test_path '/features/dpatch/' img_name(1:end-4) '.mat'])
master_feat = feat;
[fire_inds,~] = find(master_feat > 0); 

flist = dir([test_path '/features/dpatch/' img_name(1:end-4)]);
flist = flist(~cell2mat(arrayfun(@(x) isempty(strfind(x.name, ...
                                                  'dpatch_tmp_feat')), ...
                               flist, 'UniformOutput', false)));


%%% THis is how the  'bow' (not real bow) feature got created from all the indv convolution files
% tmp_feats = cell(length(flist),1);
% for f = 1:length(flist)

%     %the loaded files should contain feat and imsize vars
%     tmp_feats(f) = {load(fullfile([test_path '/features/dpatch/' img_name(1:end-4)], flist(f).name))};
% end

% for pylvl = 1
%     for ft = 1:length(tmp_feats)
%         count = numel(find(tmp_feats{ft}.feat.svmout{pylvl} > -1.002));
%         final_feat(ft) = {struct('feat',count)};
%         if(count >0)
%             keyboard
%         end
%     end
% end

if(~isempty(flist))
    cnt = cnt +1;
end


for i = 1:length(fire_inds)
    load(fullfile([test_path '/features/dpatch/' img_name(1:end-4)], flist(fire_inds(i)).name));       
    for j = 1 %only used first pyramid level in this feat
        % visualization
        % comment this when it is ready to run
%         figure(j);
%         imagesc(feat.svmout{j});
        % hold on;
%         axis image
%         axis off
%         colorbar()
        spacing = size(img)/size(feat.svmout{j});
        [I, J] = find(feat.svmout{j} > -1.002);
        I= spacing*I;
        J= spacing*J;
%         I
        
        if ~isempty(I)
            
            fig1 = figure('Position', [100, 100, 1200, 800]);

            subplot(5,2,1)            
            imshow(imread(detectors.patch_paths{fire_inds(i)}{1}));
            subplot(5,2,3)
            imshow(imread(detectors.patch_paths{fire_inds(i)}{2}));
            subplot(5,2,5)
            imshow(imread(detectors.patch_paths{fire_inds(i)}{3}));
            subplot(5,2,7)
            imshow(imread(detectors.patch_paths{fire_inds(i)}{4}));
            subplot(5,2,9)
            imshow(imread(detectors.patch_paths{fire_inds(i)}{5}));
            subplot(5,2, [2 4 6 8 10])
            imshow(img);
            hold on;
            plot(J, I, 'ro');
        end
        pause(0.1)
        if(~exist(fullfile(test_path,'features/dpatch_figs_firings/', img_name(1:end-4)), 'dir'))
            mkdir(fullfile(test_path,'features/dpatch_figs_firings/', img_name(1:end-4)));
        end
        print(fig1, '-dpng', fullfile(test_path,'features/dpatch_figs_firings/', img_name(1:end-4),[img_name(last_stroke:end-4) '_dp_' num2str(fire_inds(i))]));
        close all
    end
    
end
    catch e
        disp(e.message);
    end
end
end