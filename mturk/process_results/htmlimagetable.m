function [html]=htmlimagetable(img_list)

html=['<html><body><table>'];

str1 = '/home/gen/www/nn_patches/';
str2 = '/cluster_imgs/';
str3 = '/selectedPatches_22KZVXX2Q45U8SJ48UEI11NUMISQ8C.jpg';
str4 ='http://www.cs.brown.edu/~gen/nn_patches/';

for(i=1:numel(img_list))
  
  cat_clust = strrep(img_list{i}(length(str1)+1:end-length(str3)) , str2, ...
                     ' : ');
  html=[html '<tr><td> ' cat_clust ' <img src="' [str4 img_list{i}(length(str1)+1:end)] '"></td></tr>'];
          
end

html=[html '</table></body></html>'];

end