FROM ubuntu:latest
# TODO: not use Ubuntu

RUN apt-get update \
    && apt-get install --no-install-recommends -y ruby-full imagemagick git python3-full python3-pip libgl1 \
    && apt-get clean \
    && rm -fr /var/lib/apt/lists/* \
    && gem install prawn mini_magick \
    && python3 -m venv /app && /app/bin/pip install mokuro \
    && git clone https://github.com/Kartoffel0/Mokuro2Pdf /app/mokuro2pdf

ENV LANG=C.UTF-8

COPY run.sh /run.sh
ENTRYPOINT [ "/run.sh" ]
