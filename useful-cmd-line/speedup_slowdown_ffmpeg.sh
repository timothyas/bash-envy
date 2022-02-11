#!/bin/bash

# Thanks to this Stack Exhchange post...
# https://superuser.com/a/1676402

# Arguments
FILE_RAW=$1
SPEED_FACTOR=${2:-1.0} # Default is 1.0 X speed

# Prepare variables
BASE_PATH=$(dirname $(readlink -f $FILE_RAW))
FILENAME_EXT="$(basename "${FILE_RAW}")"
FILENAME_ONLY="${FILENAME_EXT%.*}"
EXT_ONLY="${FILENAME_EXT#*.}"
FILENAME_ONLY_PATH="${BASE_PATH}/${FILENAME_ONLY}"

# Speed up/slow down video
ffmpeg -i "${FILENAME_ONLY_PATH}.${EXT_ONLY}" -vf "setpts=(PTS-STARTPTS)/${SPEED_FACTOR}" -af atempo=$SPEED_FACTOR "${FILENAME_ONLY_PATH}_${SPEED_FACTOR}X.${EXT_ONLY}"
