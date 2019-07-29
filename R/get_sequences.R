#!/usr/bin/env Rscript

library("tidyverse")
library("Rsamtools")
library("GenomicRanges")
library("GenomicFeatures")
library("Biostrings")
library("rtracklayer")
library("BSgenome")

################################
## Get Sequences Around Summits
################################

## Load BEDs
## ----------

## Get bed file paths and names.

bed.files <- list.files(file.path("..", "summits"), pattern=".*\\.bed")
bed.names <- str_replace(bed.files, "_summits.bed", "")
bed.files <- file.path("..", "summits", bed.files)

## Import bed files as GRanges.

beds <- map(bed.files, ~import(., "bed")) %>%
	setNames(bed.names)

## Load Genome Assembly
## ----------

## Import genome assembly.

genome.assembly <- FaFile(file.path("..", "genome", "sacCer3.fasta"), "fasta")

assembly <- getSeq(genome.assembly)
names(assembly) <- assembly %>%
	names %>% str_extract("\\bchr[A-Za-z]+\\b")

## Get chromosome lengths.

chr.ranges <- genome.assembly %>%
	getSeq %>% names %>%
	str_extract("\\bchr[A-Za-z0-9-:]+\\b") %>%
	enframe %>% dplyr::select(-name) %>%
	separate(value, c("seqnames", "range"), sep=":") %>%
	separate(range, c("start", "end"), sep="-") %>%
	makeGRangesFromDataFrame

## Extend Summits
## ----------

## Extend summits 100 bp in both directions.

beds.extended <- map(beds,
	~resize(., width=100, fix="start") %>%
	resize(width=width(.)+100, fix="end")
)

## Remove ranges that run out of chromosome bounds.

beds.cleaned <- map(beds.extended, ~subsetByOverlaps(., chr.ranges, type="within"))

## Get Sequences
## ----------

## Get sequences from assembly.

bed.sequences <- map(beds.cleaned, ~getSeq(assembly, .))

## Export sequences as FASTA file.

dir.create(file.path("..","results", "sequences"))

export.fasta <- function(x) {
	bed <- bed.sequences[[x]]
	names(bed) <- sprintf("PEAK_%s", 1:length(bed))
	filename <- file.path("..", "results", "sequences", paste0(x, "_sequences.fasta"))
	writeXStringSet(bed, filename, format="fasta")
}

map(names(bed.sequences), ~export.fasta(.))
