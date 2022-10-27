# How to run


## Prepocessing

Output filename will be suffixed with `.trimmed` and outputs will be stored on `gs://input-data-mirrored/input_fastqs/trimmed`.

```bash
$ preprocess/trimmomatic_gs.sh [FASTQ_GS_URI] [BASENAME_OF_TRIMMED_FASTQ]
```

## Processing

Find a template JSON `process/sample.json`

```bash
$ caper submit process/chip.ihec.docker.wdl -i INPUT_JSON
```

Check workflow's status. You can also get `WORKFLOW_ID`, which will be used for post-processing.
```bash
$ caper list
```

## Postprocessing

Based on [this code](https://github.com/IHEC/integrative_analysis_chip/tree/dev-organize-output/encode-wrapper/postprocess)
 
Deidentify PET (experiments) BAMs and control BAMS. Then make a `bamCoverage` signal track for PET BAMs. This script will find all PET/control BAMs on `WORKFLOW_ROOT_GS_URI` and store postprocessed outputs on `OUTPUT_DIR_GS_URI`. **NO TRAILING SLASH ALLOWED FOR GS URI!**

```bash
$ cd postprocess # will make tmp directory inside it
$ ./postprocess_gs.sh [WORKFLOW_ROOT_GS_URI] [OUTPUT_DIR_GS_URI]
```

