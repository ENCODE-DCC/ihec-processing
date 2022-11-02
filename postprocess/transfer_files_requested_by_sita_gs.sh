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
TMP_ORIGINAL_OUTPUT="$TMP_EXPERIMENT/macs2"
mkdir -p "$TMP_POSTPROCESS" "$TMP_EXPERIMENT" "$TMP_CONTROL" "$TMP_ORIGINAL_OUTPUT"

SH_SCRIPT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)
cd "$SH_SCRIPT_DIR"

echo "$(date): Localizing outputs..."
gsutil cp -r -n "$GS_URI_WORKFLOW_ROOT/call-macs2" "$TMP_WORKFLOW/"

echo "$(date): Localizing call-cached outputs if exist..."
find "$TMP_WORKFLOW" -name call_caching_placeholder.txt -exec bash -c "ORG=\$(cat {} | grep -Po '(gs://.*)') && DEST=\$(dirname \$(dirname {})) && gsutil rsync -r \$ORG \$DEST" \;

echo "$(date): Running post-processing code... can take 20-40 mins"

mkdir -p "$TMP_POSTPROCESS"

echo "$(date): Transferring postprocessed outputs to gs://"
find "$TMP_WORKFLOW/call-macs2" -name "*.pval.signal.bigwig" -exec cp {} "$TMP_ORIGINAL_OUTPUT/" \;
find "$TMP_WORKFLOW/call-macs2" -name "*.fc.signal.bigwig" -exec cp {} "$TMP_ORIGINAL_OUTPUT/" \;
find "$TMP_WORKFLOW/call-macs2" -name "*.pval0.01.500K.narrowPeak.gz" -exec cp {} "$TMP_ORIGINAL_OUTPUT/" \;
find "$TMP_WORKFLOW/call-macs2" -name "*.pval0.01.500K.bfilt.narrowPeak.gz" -exec cp {} "$TMP_ORIGINAL_OUTPUT/" \;
sleep 5
gsutil rsync -r "$TMP_POSTPROCESS" "$GS_URI_OUTPUT"

echo "$(date): Deleting temp files..."
rm -rf "$TMP_WORKFLOW"

