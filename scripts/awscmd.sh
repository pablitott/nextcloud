#!/bin/bash

# this function allows you run aws commands without install aws cli functions
# [TODO]: create an image with the credentials file inside
function awscmd(){  
  if [[ ! -f ~/.aws/credentials  ]]; then 
    echo "aws credentials does not exists"
    return 1
  fi

  docker run --rm -ti -v ~/.aws:/root/.aws -v $(pwd):/aws amazon/aws-cli $*
}