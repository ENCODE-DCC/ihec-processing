#!/bin/bash

set -e

sudo apt-get install trimmomatic -y
sudo apt-get install samtools python-deeptools -y

wget -O- http://neuro.debian.net/lists/focal.us-ca.full | sudo tee /etc/apt/sources.list.d/neurodebian.sources.list
sudo apt-key adv --recv-keys --keyserver hkps://keyserver.ubuntu.com 0xA5D32F012649A5A9 -y
sudo apt-get update && sudo apt-get install singularity-container -y

wget "http://www.epigenomes.ca/data/CEMT/resources/bamstrip.jar"
mv bamstrip.jar postprocess/

singularity pull "docker://quay.io/encode-dcc/chip-seq-pipeline:v1.1.4-sambamba-0.7.1-rev1"
mv *.simg postprocess/

