
[docker secrets](https://docs.docker.com/engine/swarm/secrets/)
Create a container to store secrets
1. Initialize docker swarm to use docker as a service
    > docker swarm init <br/>
```
    Swarm initialized: current node (4f49oakg5v4sr9figpiasgmxg) is now a manager.
```
2. Add a secret to Docker. The docker secret create command reads standard input because the last argument, which represents the file to read the secret from, is set to -.<br/>
    _Following command creates a file named my_secret_data with the "This is a secret" as a content_
>  printf "This is a secret" | docker secret create my_secret_data -<br/>
```
      6nb3uklvc2rtikqedkz8p5q6d
```
3. Create a redis service and grant it access to the secret. By default, the container can access the secret at /run/secrets/<secret_name>, but you can customize the file name on the container using the target option.
    > docker service  create --name redis --secret my_secret_data redis:alpine
4. Verify that the task is running without issues using docker service ps. If everything is working, the output looks similar to this:
```
    docker service ps redis

ID              NAME       IMAGE          NODE  DESIRED       STATE    CURRENT STATE     ERROR       PORTS
c07j4syhs680    redis.1    redis:alpine   ip-172-26-15-250    Running  Running 13 seconds ago
```
5. get the docker ID to be used later
```
 docker ps --filter name=redis -q <br/>
    76cb5bb1dafa
 docker container exec $(docker ps --filter name=redis -q) ls -l /run/secrets
    -r--r--r--    1 root     root            16 Oct 23 12:04 my_secret_data
```
6. Read the secret content
```
 docker container exec $(docker ps --filter name=redis -q) cat /run/secrets/my_secret_data
 This is a secret
```
7. Verify that the secret is not available if you commit the container.
```
    > docker commit $(docker ps --filter name=redis -q) committed_redis
    > docker run --rm -it committed_redis cat /run/secrets/my_secret_data
    > no return value 
    >  or 
    > cat: can't open '/run/secrets/my_secret_data': No such file or directory
```
8. Try removing the secret. The removal fails because the redis service is running and has access to the secret.
```
    > docker secret ls<br/>
    ID                          NAME                DRIVER              CREATED             UPDATED
6nb3uklvc2rtikqedkz8p5q6d   my_secret_data                          About an hour ago   About an hour ago
    > docker secret rm my_secret_data
Error response from daemon: rpc error: code = InvalidArgument desc = secret 'my_secret_data' is in use by the following service: redis
```
9. Remove access to the secret from the running redis service by updating the service.
```
$ docker service update --secret-rm my_secret_data redis
```
10. Repeat steps 4 and 5 again, verifying that the service no longer has access to the secret. The container ID is different, because the service update command redeploys the service.
```
$ docker container exec -it $(docker ps --filter name=redis -q) cat /run/secrets/my_secret_data
  
 cat: can't open '/run/secrets/my_secret_data': No such file or directory
```
11. Stop and remove the service, and remove the secret from Docker.
```
$ docker service rm redis
 
$ docker secret rm my_secret_data
```