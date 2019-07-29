#!/bin/bash

###############################
## Motif Analysis Pugh Reponse
###############################

## Find Motifs
## ----------

## Create export directory.

mkdir -p "./results/motifs"

## Get summit files.

SUMMIT_FILES=($(find "./summits" -name "*bed"))

## Get corresponding sequences for each summit file.

for SUMMIT in ${SUMMIT_FILES[@]}; do
	findMotifsGenome.pl $SUMMIT ./genome/saccer3_assembly.fasta ./results/motifs
done
