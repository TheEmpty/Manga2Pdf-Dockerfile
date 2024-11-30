#!/bin/bash

set -ex

IN_FOLDER='/in'
OUT_FOLDER='/out'

function leaf_dir() {
  set -x
  echo "${1}" | grep -q '_ocr'
  IN_OCR=$?
  if [ $IN_OCR -eq 0 ] ; then
    echo "Skipping OCR folder: ${1}"
    return 1
  fi

  echo "Starting on ${1}"
  ls "${1}" | grep -q '\.\(cbz\|zip\)$'
  HAS_CBZ=$?
  if [ ${HAS_CBZ} -eq 0 ] ; then
    cbz_folder "${1}"
  else
    raw_folder "${1}"
  fi
  echo "Finshed on ${1}"
  echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
}
export -f leaf_dir

function cbz_folder() {
  cd /app/mokuro2pdf # required for ttf
  find "${1}" -type f -print0 | while IFS= read -r -d $'\0' FILE; do
    /app/bin/mokuro "${FILE}" --disable_confirmation --unzip --legacy-html
    PARENT_DIR="$(dirname "${1}")"
    FOLDER="$(basename "${1}")"
    FOLDER="${FOLDER%.*}"
    ruby /app/mokuro2pdf/Mokuro2Pdf.rb -u -i "${FILE}" -o "${PARENT_DIR}/_ocr/${FOLDER}" -w "/out"
  done
}
export -f cbz_folder

function raw_folder() {
  echo "Processing RAW ${1}"
  /app/bin/mokuro "${1}" --disable_confirmation --legacy-html

  cd /app/mokuro2pdf # required for ttf
  FOLDER="$(basename "${1}")"
  PARENT_DIR="$(dirname "${1}")"
  ruby /app/mokuro2pdf/Mokuro2Pdf.rb -u -i "${1}" -o "${PARENT_DIR}/_ocr/${FOLDER}" -w "/out"
}
export -f raw_folder

find "${IN_FOLDER}" -type d -links 2 -exec bash -c "leaf_dir \"{}\"" \;

