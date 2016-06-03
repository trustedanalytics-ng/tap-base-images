# Building the image
```docker build -t python2.7-jessie .```

The image also resides in quay: https://quay.io/repository/trustedanalytics/tap-base-python under `python2.7-jessie` tag.

# Running the container
First you need to get config files apropriate for the environment you want to run container in: `krb5.conf` and `cacert.pem`.
You can copy them from CDH. There are located in: `/etc/krb5.conf` and `/var/krb5kdc/cacert.pem`.

Then you run the container mounting them as data volumes, for example:
```
docker run -it -v [absolute path]/krb5.conf:/etc/krb5.conf -v [absolute path]/cacert.pem:/var/krb5kdc/cacert.pem python2.7-jessie /bin/bash
```
