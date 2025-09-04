# Use a Debian/Ubuntu base
FROM ubuntu:24.04

# Set environment
ENV DEBIAN_FRONTEND=noninteractive

# Install tools
RUN apt-get update && apt-get install -y \
    build-essential \
    linux-headers-generic \
    git \
    vim \
    curl \
    bison \
    flex \
    && apt-get clean

# Create workspace
RUN useradd -m pwn && \
    echo "pwn ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir -p /home/pwn/workspace && \
    chown -R pwn:pwn /home/pwn && \
    chmod -R 755 /home/pwn



USER pwn

WORKDIR /home/pwn/workspace

RUN apt-get upgrade
# By default, keep the container alive
CMD ["bash"]
