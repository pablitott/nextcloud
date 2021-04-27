# docker-cron
> Review the Dockerfile in [nextcloud with docker](https://github.com/nextcloud/docker/blob/master/.examples/dockerfiles/cron/apache/Dockerfile)<br/>

An example of running cron job in a docker container to [how to run a cron job inside a docker container](https://stackoverflow.com/questions/37458287/how-to-run-a-cron-job-inside-a-docker-container) with very good comments to run cron, how to manage cron, noit just in docker

[supervisor](https://www.xspdf.com/resolution/50963875.html)

[Review following code](https://help.nextcloud.com/t/docker-setup-cron/78547/5)
```yml
  cron:
    image: nextcloud:apache
    restart: always
    volumes:
      - nextcloud:/var/www/html
      - /path/to/your/cron.sh:/crons.sh:ro
    entrypoint: /cron.sh
    depends_on:
      - db
      - redis
```
in the same page 
```yml
cron:
    image: nextcloud:apache
    restart: always
    volumes:
      - nextcloud:/var/www/html
      - ./mycronfile:/var/spool/cron/crontabs/www-data
    entrypoint: /cron.sh
    depends_on:
      - db
      - redis
```
while the content of mycronfile could be something like

>*/5 * * * * php -f /var/www/html/cron.php <br/>
>0   0 * * 0 php -f /var/www/html/occ fulltextsearch:index

which will additionally index your NC instance once a week on sunday night at 0:00.

```bash
      #!/bin/bash
      docker exec redis redis-cli -a <your-redis-password> FLUSHALL
      docker exec --user www-data nextcloud php occ files:scan --all
      docker exec --user www-data nextcloud php occ files:scan-app-data
      exit 0
```
use this script as cronjob. **_do not try to enable cron inside the contaier_**. **_inside any container._**

so you just add docker exec --user www-data nextcloud php occ preview:pre-generate assuming that your container name is nextcloud and www-data the web server user.

the way to enable crond inside a container.
```bash
#!/bin/sh
set -eu

exec busybox crond -f -l 0 -L /dev/stdout
```
exec executes everything you use as the first argument. e.g. a shell skript has no +x bit. exec that-skript is your friend. and busybox crond just starts the cron daemon inside the container.

nevertheless after i wrote the comment above i found [this article in german](https://www.projekt-rootserver.de/cron-events-in-docker-containern-zum-laufen-bringen/2019/09/) it says: don’t do it with busybox. not a good idea. the authors advice: use the host cron + docker exec

i think last link above is the best article to run cron for docker 



[here is an example to configure cron](https://github.com/nextcloud/docker/tree/488378f8e88071a68bec5c0f846c294fb61ddd76/18.0/apache)

current cron lines, to edit cron file use:
> sudo crontab -e -u ubuntu
```
# m h  dom mon dow   command
SHELL=/bin/bash
PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
NICKNAME=LightsailDocker
USER=ubuntu
HOMEDIR=/home/ubuntu/nextcloud

*/10 *  *  *  * docker exec -u www-data mydeskweb.com php -f /var/www/html/cron.php
*/15 *  *  *  * docker exec -u www-data quenchinnovations.net php -f /var/www/html/cron.php


*/30  *  *  *  * docker exec -u www-data quenchinnovations.net php occ files:scan --all
*/40  *  *  *  * docker exec -u www-data quenchinnovations.net php occ files:scan-app-data

57  23 *  *  *  /home/ubuntu/nextcloud/backup_nextcloud.sh mydeskweb.com
50  23 *  *  *  /home/ubuntu/nextcloud/backup_nextcloud.sh quenchinnovations.net
```