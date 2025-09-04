#!/bin/bash
image_name="pwn-env"

docker run -it --rm --privileged --cap-add=SYS_PTRACE \
  --security-opt seccomp=unconfined \
  -v "$(pwd)":/home/pwn/workspace \
  $image_name bash -c 'cp /usr/local/bin/exploit_template.py /home/hacker/workspace/ && exec bash'
