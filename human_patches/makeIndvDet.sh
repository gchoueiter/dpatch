#!/bin/bash
matlabpath=/local/bin/matlab-r2011b

echo "EXECUTING COMMAND: makeIndvDet( " $1 " " $2 " " $3 ")"

# Set matlab's location on the grid machines
export LD_LIBRARY_PATH=/home/gen/dpatch/human_patches

# EXECUTE
cd /home/gen/dpatch/human_patches
$matlabpath -nodisplay -nojvm -r "makeIndvDet $1 $2 $3"

