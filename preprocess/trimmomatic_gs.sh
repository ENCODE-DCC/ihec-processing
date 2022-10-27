#!/bin/bash

set -e

OUTPUT_BUCKET_DIR="gs://input-data-mirrored/input_fastqs/trimmed"

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 FASTGQ_GS_URI BASENAME_OF_TRIMMED_FASTQ" >&2
  echo "Outputs will be written to $OUTPUT_BUCKET_DIR" >&2
  exit 1
fi

FASTQ=$1
LOCAL_FASTQ=$(basename $FASTQ)
TRIMMED=$(basename $2)

echo "$(date): Localizing $FASTQ"
gsutil cp $1 .

echo "$(date): Running Triommomatic..."
java -jar /usr/share/java/trimmomatic.jar SE $LOCAL_FASTQ $2 CROP:36 MINLEN:1
gsutil cp "$TRIMMED" "$OUTPUT_BUCKET_DIR/"
rm -f $LOCAL_FASTQ $TRIMMED

echo "$(date): Done"

