#!/bin/bash
#
docker run -it --rm  --privileged --cap-add=SYS_PTRACE \
  --security-opt seccomp=unconfined \
  -v "$(pwd)":/home/pwn/workspace kernel-dev

