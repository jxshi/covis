#!/usr/bin/env bash

set -euo pipefail

sample="HCC2218_tumor"
bam="../data/HCC2218/HCC2218C-sort.bam"
bed="../data/HCC2218/NexteraRapidCapture_Exome_TargetedRegions_v1.2Used.bed.gz"

echo "[$(date)] Start mosdepth"

mosdepth -b $bed $sample $bam

echo "[$(date)] End mosdepth"
