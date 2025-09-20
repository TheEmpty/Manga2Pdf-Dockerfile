# What is this?

A simple docker file and bash script that combines https://github.com/kha-white/mokuro and https://github.com/Kartoffel0/Mokuro2Pdf so I can be lazy and just point it at files without installing a bunch of things.

## Docker example

Mount your raws in `/in` and the pdfs will go into `/out`

`docker run --rm -v "~/Documents/my-raws:/in" -v "~/Documents/manga-pdfs:/out":z -it theempty/manga2pdf`

## Env variables

* `IN_FOLDER`: defaults to `/in`, where to scan for content
* `OUT_FOLDER`: defaults to `/out`, where to put the PDFs
* `KEEP_MOKURO_FILE`: defaults to 0, set to 1 to keep the `.mokuro` file generated.
* `RECYCLE_BIN`: if set, will move sources to this this directory after conversion.

## Kubernetes cluster example

Note since mokuro uses tqdm, you may not see useful logs while it's scanning.

### Single deployment

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

### Cronjob

```
apiVersion: batch/v1
kind: CronJob
metadata:
  name: manga2pdf
spec:
  schedule: "0 * * * *"
  concurrencyPolicy: Forbid
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: manga2pdf
            image: theempty/manga2pdf
            env:
              - name: RECYCLE_BIN
                value: /recycle
            volumeMounts:
              - name: media
                mountPath: /in
                subPath: books/convert/in
              - name: media
                mountPath: /out
                subPath: books/convert/out
              - name: media
                mountPath: /recycle
                subPath: books/convert/recycle
          restartPolicy: OnFailure
          volumes:
          - name: media
            nfs:
              server: mynas.local
              path: /mnt/media
```
