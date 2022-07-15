#!/bin/bash
# Usage: ./runCovidSim.sh <No. of simulations> <reference sequence>


count=$1
for i in $(seq $count); do
    #echo $(( $RANDOM % 600 + 400 ))
    art_illumina -ss HS25 -sam -i $2 -p -l 150 -f 200 -m 200 -s 10 -nf 0 -o paired_dat_"$i"
    megahit -1 paired_dat_"$i"1.fq -2 paired_dat_"$i"2.fq --out-prefix $i -o out"$i"
done
