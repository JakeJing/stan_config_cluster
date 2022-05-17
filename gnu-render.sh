#!/usr/bin/env bash

# seq 51 1 100
seq 1 1 100 | parallel -j 15 -I% --max-args 1 "./render.sh %"

#rm out*.pdf
#rm out*.log


