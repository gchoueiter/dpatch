#!/bin/bash
matlabpath=/local/bin/matlab-r2011b

echo "EXECUTING COMMAND: svm_one_vs_all_grid_wrapper( " $1 " , " $2 ")"

# Set matlab's location on the grid machines
export LD_LIBRARY_PATH=/home/gen/dpatch/

# EXECUTE
cd /home/gen/dpatch/scene_classifier
$matlabpath -nodisplay -nojvm -r "svm_one_vs_all_grid_wrapper $1 $2"