#!/bin/bash

set -ex

IN_FOLDER='/in'
OUT_FOLDER='/out'

function manga2pdf() {
  echo "Starting on ${1}"
  echo '---'
  /app/bin/mokuro "${1}" --disable_confirmation --unzip --legacy-html
  FOLDER="$(basename "${1}")"
  PARENT_DIR="$(dirname "${1}")"
  cd /app/mokuro2pdf # required for ttf
  ruby /app/mokuro2pdf/Mokuro2Pdf.rb -u -i "${1}" -o "${PARENT_DIR}/_ocr/${FOLDER}" -w "/out"
  echo '---'
  echo "Finshed on ${1}"
  echo '+++'
}
export -f manga2pdf

FOLDERS=$(find "${IN_FOLDER}" -type d -links 2 -exec bash -c "manga2pdf \"{}\"" \;)

