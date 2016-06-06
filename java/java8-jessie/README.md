# Building the image
```docker build -t java8-jessie .```

The image also resides in quay: https://quay.io/repository/trustedanalytics/tap-base-java under `java8-jessie` tag.

# Running the container
## Without kerberos
Just run it in any way convenient to you, for example:
```
docker run -it java8-jessie /bin/bash
```

## With kerberos
First you need to get config files apropriate for the environment you want to run container in: `krb5.conf` and `cacert.pem`.
You can copy them from CDH. There are located in: `/etc/krb5.conf` and `/var/krb5kdc/cacert.pem`.

Then you run the container mounting them as data volumes, for example:
```
docker run -it -v [absolute path]/krb5.conf:/etc/krb5.conf -v [absolute path]/cacert.pem:/var/krb5kdc/cacert.pem java8-jessie /bin/bash
```
