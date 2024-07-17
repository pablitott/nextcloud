# Registry docker
## Introduction
Automate storing and retrieve images in [docker registry](https://registry.hub.docker.com/), these images will be used for the nextcloud project.
To use [docker registry](https://registry.hub.docker.com/) to store docker images you have to create a 


Recover images from [docker registry](https://registry.hub.docker.com/)

## build and deploy myawscmd image to docker registry
1. Push awscmd docker image to docker registry 
```bash
   ansible-vault decrypt credentials.vault --vault-password-file .vault_pass
   ansible-vault decrypt docker_token.vault --vault-password-file .vault_pass

   cat  docker_token.vault | docker login --username pablitott --password-stdin

   # build the image
   docker  build -t pablitott/myawscmd:latest .

   # #tag the image:   
   # docker tag myawscmd:latest pablitott/myawscmd:latest

   # test the image
   docker run --rm -ti  -v $(pwd):/aws pablitott/myawscmd:latest s3 ls s3://

   # push the image
   docker push pablitott/myawscmd:latest

   # remove local image
   docker rmi pablitott/myawscmd:latest
```

## Encrypt the files used or revert from git
```bash

   ansible-vault encrypt docker_token.vault --vault-password-file .vault_pass
   ansible-vault encrypt credentials.vault --vault-password-file .vault_pass

```

## Use myawscmd to execute aws commands
Get the list of all the buckets allowed to access by sailoruser
```docker run --rm -ti  -v $(pwd):/aws pablitott/myawscmd:latest s3 ls ```

Download an specific backup
```docker run --rm -ti  -v $(pwd):/aws pablitott/myawscmd:latest s3 cp s3://s3quenchinnovations/backups/LightsailDocker/mydeskweb.com/nc_backup_0.tar ./```

Upload specific file to s3 folder:
```docker run --rm -ti  -v $(pwd):/aws pablitott/myawscmd:latest s3 cp Dockerfile s3://s3quenchinnovations/backups/LightsailDocker/mydeskweb.com/ ```
Note* file to upload must be in the same directory where the command is executed

Get the lightsail name
```docker run --rm -ti  -v $(pwd):/aws pablitott/myawscmd:latest lightsail get-instances --query instances[].name, instances[].arn```

Get the lightsail arn
```docker run --rm -ti  -v $(pwd):/aws pablitott/myawscmd:latest lightsail get-instances --query instances[].arn```

this image can be seen at: [myawscmd](https://registry.hub.docker.com/repository/docker/pablitott/myawscmd/general)



Configure a credential helper to remove this warning. See
[credential helper](https://docs.docker.com/engine/reference/commandline/login/#credential-stores)
