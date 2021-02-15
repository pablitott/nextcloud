from:
1. [setup docker Swarm Cluster on Ubuntu 18.04](https://tuneit.me/docker/set-up-docker-swarm-cluster-on-ubuntu-18-in-azure/#Install_GlusterFS)
2. [Deploy Nextcloud 18.0.1 in docker swarm](https://tuneit.me/docker/deploy-nextcloud-18-0-1-in-docker-swarm)
3. [Installing GlusterFS - a Quick Start Guide](https://docs.gluster.org/en/latest/Quick-Start-Guide/Quickstart/)
4. [High-availability storage with glusterFS on ubuntu 18.04](https://www.howtoforge.com/tutorial/high-availability-storage-with-glusterfs-on-ubuntu-1804/)
5. [Traefik 2.0: Cloud Native Edge Router for Containers](https://tuneit.me/docker/traefik-cloud-native-edge-router-for-container-services/)


Since Trefik is a tool for load balancer. but I'm using nginx to publish Nextcloud, review this [Using nginx as HTTP Load balancer](https://nginx.org/en/docs/http/load_balancing.html)

use [Installing GlusterFS - a Quick Start Guide](https://docs.gluster.org/en/latest/Quick-Start-Guide/Quickstart/) to create the shared mounted disk




This article is based to create Nextcloud on a raspberry Pi, so far I will create on Oracle Virtual Box before by Pi

It is use Traefik in front of applications as a Reverse Proxy or Load Balancer

## Install gluster
Gluster allows to cretae a shared hard drive to be used by all the docker nextcloud-mydeskweb