# What is this?

A simple docker file and bash script that combines https://github.com/kha-white/mokuro and https://github.com/Kartoffel0/Mokuro2Pdf so I can be lazy and just point it at files without installing a bunch of things.

## Docker example

Mount your raws in `/in` and the pdfs will go into `/out`

`docker run --rm -v "~/Documents/my-raws:/in" -v "~/Documents/manga-pdfs:/out" -it theempty/manga2pdf`

## Kubernetes cluster example

Note since mokuro uses tqdm, you won't see useful logs while it's scanning.

```
apiVersion: v1
kind: Pod
metadata:
  name: manga2pdf
spec:
  containers:
  - name: manga2pdf
    image: theempty/manga2pdf
    volumeMounts:
      - name: media
        mountPath: /in
        subPath: books/convert/in
      - name: media
        mountPath: /out
        subPath: books/convert/out
  restartPolicy: Never
  volumes:
  - name: media
    nfs:
      server: mynas.local
      path: /mnt/media
```
