#!/bin/bash
#SBATCH --job-name=Naveen_Extract_subsequences
#SBATCH --output=slurm_job_%j.out
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=40
#SBATCH --mem=128GB
#SBATCH --partition=compute #Partition/queue in which run the job.
echo "SLURM_JOBID="$SLURM_JOBID
echo "SLURM_JOB_NODELIST"=$SLURM_JOB_NODELIST
echo "SLURM_NNODES"=$SLURM_NNODES
echo "SLURMTMPDIR="$SLURMTMPDIR
echo "Date = $(date)"
echo "Hostname = $(hostname -s)"
echo ""
echo "Number of Nodes Allocated = $SLURM_JOB_NUM_NODES"
echo "Number of Tasks Allocated = $SLURM_NTASKS"
echo "Number of Cores/Task Allocated = $SLURM_CPUS_PER_TASK"
echo "Working Directory = $(pwd)"
echo "working directory = "$SLURM_SUBMIT_DI
eval "$(conda shell.bash hook)"
conda activate SEVA
#<Add commands or scripts to run here>
# Note to add the commands along with their paths.
/bin/hostname |tee result
