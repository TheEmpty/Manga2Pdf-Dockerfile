#!/bin/sh

set -ex

docker build . -t theempty/manga2pdf:latest
docker push theempty/manga2pdf:latest
