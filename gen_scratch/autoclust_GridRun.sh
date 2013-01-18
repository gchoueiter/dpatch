#!/bin/bash 
#$ -S /bin/sh 
#$ -cwd 
# ------ attach job number
#$ -j n
# ------ attach task number
#$ -t 1-15
# ------ send to particular queue {short,long,vlong}
#$ -l vlong
# ------ can use up to 4GB of memory
#$ -l vf=8G
# put stdout and stderr files in the right place for your system.
#$ -o /home/gen/dpatch/gen_scratch/grid_out/$JOB_ID.$TASK_ID.out
#$ -e /home/gen/dpatch/gen_scratch/grid_out/$JOB_ID.$TASK_ID.err

# ================= RUN GRID JOB ================

matlabpath=/local/bin/matlab-r2011b

echo "EXECUTING COMMAND: autoclust_wrapper( " $SGE_TASK_ID ")"

# Set matlab's location on the grid machines
export LD_LIBRARY_PATH=/home/gen/dpatch/gen_scratch

# EXECUTE autoclust for 15 scenes
cd /home/gen/dpatch/gen_scratch
$matlabpath -nodesktop -nosplash -r "autoclust_wrapper $SGE_TASK_ID"
