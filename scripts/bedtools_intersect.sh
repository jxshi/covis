#!/usr/bin/env bash

set -euo pipefail

mosdepth_bed=$1
exon_bed=$2

bedtools intersect -wa -wb \
    -a $mosdepth_bed \
    -b $exon_bed \
    | bgzip
