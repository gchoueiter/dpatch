% calculates a kernel 
% feature- struct containing feature name and kernel type
% X - matrix where row i is a feature vector for item i
% sigma - is optional, the sigma parameter for rbf kernel
function [K] = kernel(X, feature, sigma)

% addpath to vl_feat code and setup vl_feat
addpath(genpath('data/hays_lab/people/gen/SUN_source_code_v2/code/vlfeat-0.9.5/'));
vl_setup('noprefix');

K = [];

switch feature.kernel_name
    
    case 'kl1' %hist_intersect
        K = vl_alldist2(X, 'kl1');
    case'kl2'
        K = X' * X ;
    case 'kchi2'
        K = vl_alldist2(X, 'kchi2') ;
    case 'rbf'
        X = X';
        norm1 = sum(X.^2,2);
        norm2 = sum(X.^2,2);
        dist = (repmat(norm1 ,1,size(X,1)) + repmat(norm2',size(X,1),1) - 2*X*X');
        if nargin <= 2
            sigma=sqrt(mean(dist(:))/2);
        end
        K = exp(-0.5/sigma^2 * dist);
end
if ~isempty(find(isnan(K), 1))
    disp('something element is NaN in the K matrix');
    K(isnan(K))=10^20;
end

end