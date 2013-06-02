#!/bin/bash 
#$ -S /bin/sh 
#$ -cwd 
# ------ attach job number
#$ -j n
# ------ attach task number
#$ -t 1
# ------ send to particular queue {short,long,vlong}
#$ -l short
# ------ can use up to 4GB of memory
#$ -l vf=4G
# put stdout and stderr files in the right place for your system.
#$ -o /data/hays_lab/people/gen/grid_output/SPM/$JOB_ID.$TASK_ID.out
#$ -e /data/hays_lab/people/gen/grid_output/SPM/$JOB_ID.$TASK_ID.err

# ================= RUN GRID JOB ================

matlabpath=/local/bin/matlab-r2011b
echo "EXECUTING COMMAND: makeVisEntDetFeatures_GridWrapper( " $3 " , "$1", "$2" )"

# Set matlab's location on the grid machines
export LD_LIBRARY_PATH=/home/gen/dpatch/gen_scratch

# EXECUTE classify_attributes!
cd /home/gen/dpatch/gen_scratch
$matlabpath -nodesktop -nodisplay -nosplash -r "makeVisEntDetFeatures_GridWrapper $3 $1 $2"