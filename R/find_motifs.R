#!/usr/bin/env Rscript

library("tidyverse")
library("rGADEM")
library("Biostrings")

###################
## Motif Discovery
###################

## Loading Fasta Files
## ----------

fasta.files <- list.files(file.path("results", "sequences"), pattern=".+\\.fasta")
fasta.names <- str_replace(fasta.files, "_sequences.fasta", "")
fasta.files <- file.path("results", "sequences", fasta.files)

fastas <- map(fasta.files, ~readDNAStringSet(., format="fasta")) %>%
	setNames(fasta.names)

## Find Motif
## ----------

motifs <- map(fastas, ~GADEM(., verbose=1, maskR=1, nmotifs=5))
