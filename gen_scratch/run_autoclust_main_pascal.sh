#!/bin/bash 

matlabpath=/local/bin/matlab-r2011b

echo "EXECUTING COMMAND: autoclust_wrapper_pascal( " $1 ")"

# Set matlab's location on the grid machines
export LD_LIBRARY_PATH=/home/gen/dpatch/gen_scratch

# EXECUTE autoclust for pascal
cd /home/gen/dpatch/gen_scratch
$matlabpath -nodesktop -nosplash -r "autoclust_wrapper_pascal $1 "