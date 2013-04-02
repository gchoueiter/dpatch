#!/bin/bash
matlabpath=/local/bin/matlab-r2011b

# Set matlab's location on the grid machines
export LD_LIBRARY_PATH=/home/gen/dpatch/

# EXECUTE
cd /home/gen/dpatch/gen_scratch
#i=1
#while [ "$i" -ne 6 ]
#do

    $matlabpath -nodesktop -nosplash -nojvm -r "extract_feature_CheckAndRelaunch 1" | mail -s "features completed for ranking 1" "gen@cs.brown.edu"
    $matlabpath -nodesktop -nosplash -nojvm -r "extract_feature_CheckAndRelaunch 2" | mail -s "features completed for ranking 2" "gen@cs.brown.edu"
#    i=i+1
#    sleep 4000
#done
