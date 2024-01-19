#!/bin/bash

NAME=$1
IMG=$2

docker run -it --rm \
		   -v /home/$USER/work:/work \
		   --privileged --cap-add=SYS_PTRACE \
		   --name $NAME \
		   $IMG
