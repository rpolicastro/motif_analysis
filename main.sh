#!/bin/bash

###############################
## Motif Analysis Pugh Reponse
###############################

## Prepare Singularity Container
## ----------

CONTAINER="library://rpolicastro/default/motif_analysis:1.0.0"
CONTAINER_NAME=$(basename $CONTAINER | tr ":" "_")".sif"

## Download container if it doesn't exist.

if [ ! -f "singularity/${CONTAINER_NAME}" ]; then
	singularity pull -U $CONTAINER
	mv $CONTAINER_NAME singularity
fi

## Get Sequences Around Summits
## ----------

singularity exec \
-eCB $PWD -H $PWD \
singularity/$CONTAINER_NAME \
Rscript ./R/get_sequences.R
