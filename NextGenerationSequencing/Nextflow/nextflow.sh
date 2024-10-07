#!/bin/bash
#
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --time=12:00:00
#SBATCH --mem=16GB
#SBATCH --job-name=nextflow
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=na2318@nyu.edu

module load nextflow/23.04.1

nextflow run main.nf


