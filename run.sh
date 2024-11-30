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

function cbz_file() {
  set -x
  /app/bin/mokuro "${1}" --disable_confirmation --unzip --legacy-html

  cd /app/mokuro2pdf # required for ttf
  PARENT_DIR="$(dirname "${1}")"
  FOLDER="$(basename "${1}")"
  FOLDER="${FOLDER%.*}"
  UNZIPPED="${PARENT_DIR}/${FOLDER}"
  ruby /app/mokuro2pdf/Mokuro2Pdf.rb -u -i "${UNZIPPED}" -o "${PARENT_DIR}/_ocr/${FOLDER}" -w "/out"
  rm -fr "${UNZIPPED}"
}
export -f cbz_file

function raw_folder() {
  echo "Processing RAW ${1}"
  /app/bin/mokuro "${1}" --disable_confirmation --legacy-html

  cd /app/mokuro2pdf # required for ttf
  FOLDER="$(basename "${1}")"
  PARENT_DIR="$(dirname "${1}")"
  ruby /app/mokuro2pdf/Mokuro2Pdf.rb -u -i "${1}" -o "${PARENT_DIR}/_ocr/${FOLDER}" -w "/out"
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
}
export -f 7z_file

echo 'Scanning LEAF DIRECTORIES FIRST'
# find "${IN_FOLDER}" -type d -links 2 -exec bash -c "leaf_dir \"{}\"" \;

echo 'Scanning CBZ/ZIP files'
# find "${IN_FOLDER}" -type f -regex '.+\.\(cbz\|zip\)$' -exec bash -c "cbz_file \"{}\"" \;

echo 'Scanning CBR/RAR/CB7 files'
find "${IN_FOLDER}" -type f -regex '.+\.\(cbr\|rar\|7z\)$' -exec bash -c "7z_file \"{}\"" \;

