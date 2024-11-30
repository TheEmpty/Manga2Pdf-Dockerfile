#!/bin/bash

set -ex

IN_FOLDER="${IN_FOLDER:-/in}"
OUT_FOLDER="${OUT_FOLDER:-/out}"
KEEP_MOKURO_FILE="${KEEP_MOKURO_FILE:-0}"
export KEEP_MOKURO_FILE

function leaf_dir() {
  set -x
  echo "${1}" | grep -q '_ocr'
  IN_OCR=$?
  if [ $IN_OCR -eq 0 ] ; then
    echo "Skipping OCR folder: ${1}"
    return 1
  fi

  echo "Checking leaf for raws: ${1}"
  ls "${1}" | grep -q '\.\(png\|jpg\|jpeg\|webp\|heif\|tiff\)$'
  HAS_RAW=$?
  if [ ${HAS_RAW} -eq 0 ] ; then
    raw_folder "${1}"
  else
    echo "${1} was not a RAW folder"
  fi
  echo "Finshed RAW processing on ${1}"
  echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
}
export -f leaf_dir

function raw_folder() {
  echo "Processing ${1}"
  /app/bin/mokuro "${1}" --disable_confirmation --legacy-html

  cd /app/mokuro2pdf # required for ttf
  FOLDER="$(basename "${1}")"
  PARENT_DIR="$(dirname "${1}")"
  ruby /app/mokuro2pdf/Mokuro2Pdf.rb -u -i "${1}" -o "${PARENT_DIR}/_ocr/${FOLDER}" -w "${OUT_FOLDER}"
  rm -f "${PARENT_DIR}/${FOLDER}.html"
  if [ ${KEEP_MOKURO_FILE} -eq 0 ] ; then
    rm -f "${PARENT_DIR}/${FOLDER}.mokuro"
  fi
}
export -f raw_folder

function 7z_file() {
  set -x
  PARENT_DIR="$(dirname "${1}")"
  FOLDER="$(basename "${1}")"
  FOLDER="${FOLDER%.*}"
  UNZIPPED="${PARENT_DIR}/${FOLDER}"
  rm -fr "${UNZIPPED}"
  7z x "${1}" "-o${UNZIPPED}"
  raw_folder "${UNZIPPED}"
  rm -fr "${UNZIPPED}"
}
export -f 7z_file

mkdir -p $OUT_FOLDER
touch ${OUT_FOLDER}/.test
rm ${OUT_FOLDER}/.test

echo 'Scanning Archive files'
find "${IN_FOLDER}" -type f -regex '.+\.\(cbz\|zip\|cbr\|rar\|7z\)$' -exec bash -c "7z_file \"{}\"" \;

echo 'Scanning for RAWs'
find "${IN_FOLDER}" -type d -links 2 -exec bash -c "leaf_dir \"{}\"" \;

