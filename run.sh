#!/bin/bash

image_name="pwn-env"

docker run -it --rm --privileged --cap-add=SYS_PTRACE \
  --security-opt seccomp=unconfined \
  -v $(pwd):/home/hacker/workspace $image_name
