#!/bin/bash

# this function allows you run aws commands without install aws cli functions
# [TODO]: create an image with the credentials file inside
function awscmd(){  
  docker run --rm -ti  -v $(pwd):/aws pablitott/myawscmd:latest $*
}