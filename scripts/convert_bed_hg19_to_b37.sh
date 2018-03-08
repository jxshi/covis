#!/usr/bin/env bash

set -euo pipefail
bed_gz=$1

zcat $bed_gz  | \
    sed -e 's/^chr//' | \
    sed -e 's/^M/MT/' | \
    grep -v '_gl' | \
    sort -k1,1V -k2,2n | \
    gzip
