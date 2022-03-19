# Encrypted Data

To protect the repository from crawlers, the data portion is zipped and encrypted. To use it, you'll need to do a few easy steps.

The password for both encryption and decryption is `slavaukraini`.

## Decompressing

Decrypt the `data.zip.enc` file by issuing the command

```
openssl enc -aes-256-cbc -d -in data.zip.enc -out data.zip
```

Then unzip

```
unzip data.zip
```

## Compressing

Create `data.zip` by running

```
find data -iname '*.yaml' | xargs zip data.zip
```

Then encrypt it

```
openssl enc -aes-256-cbc -salt -in data.zip -out data.zip.enc
```
