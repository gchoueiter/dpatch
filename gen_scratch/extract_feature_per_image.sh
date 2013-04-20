#!/bin/bash
matlabpath=/local/bin/matlab-r2011b

echo "EXECUTING COMMAND: extract_feature_GridWrapper( " $1 " , " $2 ", " $3 ")"

# Set matlab's location on the grid machines
export LD_LIBRARY_PATH=/home/gen/dpatch/

# EXECUTE
cd /home/gen/dpatch/gen_scratch
$matlabpath -nodesktop -nosplash -nojvm -r "extract_feature_GridWrapper $1 $2 $3"