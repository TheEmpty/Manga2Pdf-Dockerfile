#!/bin/bash

set -ex

IN_FOLDER='/in'
OUT_FOLDER='/out'

function manga2pdf() {
  echo "Starting on ${1}"
  echo '---'
  /app/bin/mokuro "${1}" --disable_confirmation --unzip --legacy-html
  ruby /app/mokuro2pdf/Mokuro2Pdf.rb -i "${1}" -o "${1}/../_ocr" -w "/out"
  echo '---'
  echo "Finshed on ${1}"
  echo '+++'
}
export -f manga2pdf

FOLDERS=$(find "${IN_FOLDER}" -type d -links 2 -exec bash -c "manga2pdf \"{}\"" \;)

