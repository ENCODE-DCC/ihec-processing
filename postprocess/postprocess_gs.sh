#!/bin/bash

set -e 

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 GS_URI_WORKFLOW_ROOT GS_URI_OUTPUT" >&2
  exit 1
fi

GS_URI_WORKFLOW_ROOT=$1
GS_URI_OUTPUT=$2

WORKFLOW_ID=$(basename "$GS_URI_WORKFLOW_ROOT")

CWD=$(pwd)
TMP_ROOT="$CWD/tmp"
TMP_WORKFLOW="$TMP_ROOT/$WORKFLOW_ID"
TMP_POSTPROCESS="$TMP_WORKFLOW/postprocess_output"
TMP_EXPERIMENT="$TMP_POSTPROCESS/experiment"
TMP_CONTROL="$TMP_POSTPROCESS/control"
mkdir -p "$TMP_POSTPROCESS" "$TMP_EXPERIMENT" "$TMP_CONTROL"

SH_SCRIPT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)
SINGULARITY_IMAGE="$SH_SCRIPT_DIR/chip-seq-pipeline-v1.1.4-sambamba-0.7.1-rev1.simg"
cd "$SH_SCRIPT_DIR"

echo "$(date): Localizing outputs..."
gsutil cp -r -n "$GS_URI_WORKFLOW_ROOT/call-qc_report" "$TMP_WORKFLOW/"
gsutil cp -r -n "$GS_URI_WORKFLOW_ROOT/call-macs2" "$TMP_WORKFLOW/"
gsutil cp -r -n "$GS_URI_WORKFLOW_ROOT/call-filter" "$TMP_WORKFLOW/"
gsutil cp -r -n "$GS_URI_WORKFLOW_ROOT/call-filter_ctl" "$TMP_WORKFLOW/"
gsutil cp -r -n "$GS_URI_WORKFLOW_ROOT/call-bwa" "$TMP_WORKFLOW/"
gsutil cp -r -n "$GS_URI_WORKFLOW_ROOT/call-xcor" "$TMP_WORKFLOW/"

echo "$(date): Running post-processing code... can take 20-40 mins"

mkdir -p "$TMP_POSTPROCESS"
python3 postprocess.py "$SINGULARITY_IMAGE" "$TMP_WORKFLOW" > "$TMP_POSTPROCESS/run.sh"
cat "$TMP_POSTPROCESS/run.sh"
bash "$TMP_POSTPROCESS/run.sh" > "$TMP_POSTPROCESS/log.txt" 2>&1

echo "$(date): Transferring postprocessed outputs to gs://"
find "$TMP_WORKFLOW/call-filter" -name "*.noseq*" -exec cp {} "$TMP_EXPERIMENT/" \;
find "$TMP_WORKFLOW/call-filter" -name "*.raw.bigwig" -exec cp {} "$TMP_EXPERIMENT/" \;
find "$TMP_WORKFLOW/call-filter_ctl" -name "*.noseq*" -exec cp {} "$TMP_CONTROL/" \;
sleep 5
gsutil rsync -r "$TMP_POSTPROCESS" "$GS_URI_OUTPUT"

echo "$(date): Deleting temp files..."
rm -rf "$TMP_WORKFLOW"

