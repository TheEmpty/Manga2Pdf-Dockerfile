#!/bin/sh

set -ex

docker build . -t manga-to-pdf
docker run --rm -v "/mnt/media/books/convert/in:/in" -v "/mnt/media/books/convert/out:/out" --entrypoint /bin/bash -it manga-to-pdf 
