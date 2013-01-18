#!/bin/bash
matlabpath=/local/bin/matlab-r2011b

echo "EXECUTING COMMAND: conv_wrapper( " $1 " " $2 " " $3 " " $4 " " $5 " " $6  ")"

# Set matlab's location on the grid machines
export LD_LIBRARY_PATH=/home/gen/dpatch/

# EXECUTE
cd /home/gen/dpatch/extractFeature
$matlabpath -nodesktop -nosplash -nojvm -r "conv_wrapper $1 $2 $3 $4 $5 $6"

