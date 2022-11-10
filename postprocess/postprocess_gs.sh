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
mkdir -p "$TMP_WORKFLOW"

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

echo "$(date): Localizing call-cached outputs if exist..."
find "$TMP_WORKFLOW" -name call_caching_placeholder.txt -exec bash -c "ORG=\$(cat {} | grep -Po '(gs://.*)') && DEST=\$(dirname \$(dirname {})) && gsutil rsync -r \$ORG \$DEST" \;

echo "$(date): Running post-processing code... can take 20-40 mins"

python3 postprocess.py "$SINGULARITY_IMAGE" "$TMP_WORKFLOW" > "$TMP_WORKFLOW/run.sh"
cat "$TMP_WORKFLOW/run.sh"
bash "$TMP_WORKFLOW/run.sh" > "$TMP_WORKFLOW/run.log" 2>&1

echo "$(date): remove unnecessary files"
find "$TMP_WORKFLOW" -type f ! \
\( -name "*.noseq.bam" -o \
-name "*.bigwig" -o \
-name "*.pval0.01.500K.bfilt.narrowPeak.gz" -o \
-name "*.pval0.01.500K.narrowPeak.gz" -o \
-name "qc.json" -o \
-name "qc.html" -o \
-name "run.sh" -o \
-name "run.log" -o \
-name "*.qc" \) -delete
find "$TMP_WORKFLOW" -type d -empty -exec rm -rf {} \; || echo

echo "$(date): rsync to gs://"
gsutil rsync -r "$TMP_WORKFLOW" "$GS_URI_OUTPUT"

echo "$(date): Deleting temp files..."
rm -rf "$TMP_WORKFLOW"

