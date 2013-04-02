% matlab script to launch pascal dpatch 
%matlab -nodesktop -nodisplay -nosplash -r "launch_pascal_dpatch num"
function launch_pascal_dpatch(ind)
	ci = str2num(ind);
	cd ..
	load('pascal_cats.mat')
	cat_str = cats{ci};
	autoclust_main_pascal;
	%send mail to say that cat finished...
   	status= system(['echo "done." | mail -s "dpatches finished for ' cat_str ...
                    '" gen@cs.brown.edu']);

end
