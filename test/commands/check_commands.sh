#!/bin/bash
# Copyright (c) 2022, XMOS Ltd, All rights reserved

set -e

# help text
help()
{
   echo "XCORE-VOICE FFD commands test"
   echo
   echo "Syntax: check_commands.sh [-h] input_directory input_list output_directory"
   echo
   echo "options:"
   echo "h     Print this Help."
}

# flag arguments
while getopts h option
do
    case "${option}" in
        h) help
           exit;;
    esac
done

uname=`uname`

# assign command line args
INPUT_DIR=${@:$OPTIND:1}
INPUT_LIST=${@:$OPTIND+1:1}
OUTPUT_DIR=${@:$OPTIND+2:1}

# read input list
INPUT_ARRAY=()
while IFS= read -r line || [[ "$line" ]]; do
    if [[ ${line:0:1} != "#" ]]; then
        INPUT_ARRAY+=("$line")
    fi
done < ${INPUT_LIST}

# discern repository root
SLN_VOICE_ROOT=`git rev-parse --show-toplevel`
source ${SLN_VOICE_ROOT}/tools/ci/helper_functions.sh

# Create output folder
mkdir -p ${OUTPUT_DIR}

# fresh logs
RESULTS="${OUTPUT_DIR}/results.csv"
rm -rf ${RESULTS}

echo "***********************************"
echo "Log file: ${RESULTS}"
echo "***********************************"

for ((j = 0; j < ${#INPUT_ARRAY[@]}; j += 1)); do
    read -ra FIELDS <<< ${INPUT_ARRAY[j]}
    FILE_NAME=${FIELDS[0]}

    OUTPUT_LOG="${OUTPUT_DIR}/${FILE_NAME}.log"
    INPUT_WAV="${INPUT_DIR}/${FILE_NAME}.wav"
    OUTPUT_WAV="${OUTPUT_DIR}/processed_${FILE_NAME}.wav"
    
    # process the input wav
    (bash ${SLN_VOICE_ROOT}/tools/audio/process_wav.sh -c1 ${INPUT_WAV} ${OUTPUT_WAV})

done 

# print results
(cat ${RESULTS})