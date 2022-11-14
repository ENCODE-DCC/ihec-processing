#!/bin/bash

set -e
# rerun duplicate
./postprocess_gs.sh gs://ihec-output/caper_out/chip/b22009db-e34c-4edd-8979-c2d4e08d46d6 gs://ihec-postprocessed-output/v2/IHECRE00001046.7_Histone_H3K9me3

./postprocess_gs.sh gs://ihec-output/caper_out/chip/0515fd32-b5d8-4033-bfc9-ac1e5b7df17e gs://ihec-postprocessed-output/v2/IHECRE00001046.7_Histone_H3K27me3


