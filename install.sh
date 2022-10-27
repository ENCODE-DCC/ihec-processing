#!/bin/bash

set -e

wget "http://www.epigenomes.ca/data/CEMT/resources/bamstrip.jar"
mv bamstrip.jar postprocess/

singularity pull "docker://quay.io/encode-dcc/chip-seq-pipeline:v1.1.4-sambamba-0.7.1-rev1"
mv *.simg postprocess/

