#!/usr/bin/env bash

. config.sh

SOURCES='fs hdfs'
FORMATS='js gz'
EXLUDED_SOURCE='hdfs'
EXLUDED_FORMAT='js'

for SOURCE in $SOURCES; do
  if [ "$SOURCE" == "$EXLUDED_SOURCE" ]; then
    continue
  fi

  for FORMAT in $FORMATS; do
    if [ "$FORMAT" == "$EXLUDED_FORMAT" ]; then
      continue
    fi

    if [ "$SOURCE" == "fs" ]; then
      if [ "$FORMAT" == 'gz' ]; then
        INPUT=file://${FS_GZ_DIR}/part-*.gz
      else
        INPUT=file://${FS_JS_DIR}/part-*.json
      fi
    else
      if [ "$FORMAT" == 'gz' ]; then
        INPUT=${HDFS_GZ_DIR}/part-*.gz
      else
        INPUT=${HDFS_JS_DIR}/part-*.json
      fi
    fi
    for CORES in {1..4} ; do # 2 6 ; do -- {3..5}; do
      echo "${SOURCE} ${FORMAT} ${CORES} " ${INPUT}
      echo ./completeness.sh -i ${INPUT} --cores ${CORES} --source=${SOURCE} --format=${FORMAT} result-${CORES}-${FORMAT}-${SOURCE}.csv
      ./completeness.sh -i ${INPUT} --cores ${CORES} --source=${SOURCE} --format=${FORMAT} result-${CORES}-${FORMAT}-${SOURCE}.csv
    done
  done
done

duration=$SECONDS
hours=$(($duration / (60*60)))
mins=$(($duration % (60*60) / 60))
secs=$(($duration % 60))

elapsed=$(printf "%02d:%02d:%02d" $hours $mins $secs)
echo "FINALLY ${SECONDS} (${elapsed}) elapsed"

