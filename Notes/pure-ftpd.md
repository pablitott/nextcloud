# pure-ftpd docker image

notes from 
   [pure-ftpd](https://hub.docker.com/r/stilliard/pure-ftpd/)<br/>
and 
   [ftpd-virtual users](https://download.pureftpd.org/pure-ftpd/doc/README.Virtual-Users)
## Add users
In docker-compose configure the user volumes
```
    volumes: # remember to replace /folder_on_disk/ with the path to where you want to store the files on the host machine
    #      - "/folder_on_disk/data:/home/username/"
      - /nextcloud/www/questinnovations.net:/home/ftpusers/ptrujillo
      - /nextcloud/www/paveltrujillo.info:/home/ftpusers/pavelt

```
Create an ftp user: e.g. bob with chroot access to .home/ftpusers/bob
```
    docker exec -it <pure-ftp image> sh
    pure-pw useradd ptrujillo -f /etc/pure-ftpd/passwd/pureftpd.passwd -m -u ftpuser -d /home/ftpusers/ptrujillo
    pure-pw useradd pavelt -f /etc/pure-ftpd/passwd/pureftpd.passwd -m -u ftpuser -d /home/ftpusers/pavelt

    where:
            User Name: bob
        Paswword file: /etc/pure-ftpd/passwd/pureftpd.passwd
        user folder: /home/ftpusers/bob
system will prompt for password twice
```
no restart is needed

### Change pureftp user password
```
    pure-pw passwd bob -f /etc/pure-ftpd/passwd/pureftpd.passwd -m
```

In general to add a new user using pw
```
To add a new user, use the following syntax:

    pure-pw useradd <login> [-f <passwd file>] -u <uid> [-g <gid>]
                    -D/-d <home directory> [-c <gecos>]
                    [-t <download bandwidth>] [-T <upload bandwidth>]
                    [-n <max number of files>] [-N <max Mbytes>]
                    [-q <upload ratio>] [-Q <download ratio>]
                    [-r <allow client ip>/<mask>] [-R <deny client ip>/<mask>]
                    [-i <allow local ip>/<mask>] [-I <deny local ip>/<mask>]
                    [-y <max number of concurrent sessions>]
                    [-C <max number of concurrent login attempts>]
                    [-M <total memory (in MB) to reserve for password hashing>]
                    [-z <hhmm>-<hhmm>] [-m]

```
for connecting using Windows
