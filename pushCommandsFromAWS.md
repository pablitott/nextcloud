# Push Commands for nextcloud

Make sure that you have the latest version of the AWS CLI and Docker installed. For more information, see Getting Started with Amazon ECR .
Use the following steps to authenticate and push an image to your repository. For additional registry authentication methods, including the Amazon ECR credential helper, see [Registry Authentication](http://docs.aws.amazon.com/AmazonECR/latest/userguide/Registries.html#registry_auth) .

1. Retrieve an authentication token and authenticate your Docker client to your registry.
Use the AWS CLI:
> aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin `690049365056.dkr.ecr.us-east-1.amazonaws.com`

**Note:** If you receive an error using the AWS CLI, make sure that you have the latest version of the AWS CLI and Docker installed.

2. Build your Docker image using the following command. For information on building a Docker file from scratch see the instructions [here](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/docker-basics.html) . You can skip this step if your image is already built
 
> docker build -t nextcloud .

3. After the build completes, tag your image so you can push the image to this repository:
> docker tag nextcloud:latest 690049365056.dkr.ecr.us-east-1.amazonaws.com/nextcloud:latest
4. Run the following command to push this image to your newly created AWS repository:

>docker push 690049365056.dkr.ecr.us-east-1.amazonaws.com/nextcloud:latest
