FROM ubuntu:16.04

ENV DEBIAN_FRONTEND=noninteractive

# Install build tools and dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    wget curl file\
    git vim nano sudo \
    p7zip-full netcat-traditional \
    nasm binutils \
    gcc gcc-multilib g++ g++-multilib \
    make socat \
    libgmp-dev libmpfr-dev libmpc-dev \
    strace ltrace patchelf unzip \
    libbz2-dev libreadline-dev libsqlite3-dev \
    libffi-dev libncurses5-dev libgdbm-dev liblzma-dev \
    zlib1g-dev ca-certificates software-properties-common \
    libnss3-dev \
    && rm -rf /var/lib/apt/lists/*

# Build OpenSSL 1.1.1 (required for Python 3.10+ SSL support)
WORKDIR /usr/src
RUN wget https://www.openssl.org/source/openssl-1.1.1w.tar.gz && \
    tar xzf openssl-1.1.1w.tar.gz && \
    cd openssl-1.1.1w && \
    ./config --prefix=/usr/local/openssl --openssldir=/usr/local/openssl shared zlib && \
    make -j$(nproc) && make install && \
    echo "/usr/local/openssl/lib" > /etc/ld.so.conf.d/openssl.conf && ldconfig

# Build Python 3.10 with OpenSSL support
RUN wget https://www.python.org/ftp/python/3.10.13/Python-3.10.13.tgz && \
    tar xzf Python-3.10.13.tgz && \ 
    cd Python-3.10.13 && \
    LDFLAGS="-L/usr/local/openssl/lib -Wl,-rpath=/usr/local/openssl/lib" \
    CPPFLAGS="-I/usr/local/openssl/include" \
    ./configure --enable-optimizations --with-openssl=/usr/local/openssl && \
    make -j$(nproc) && \
    make altinstall

# Setup pip and symlinks
RUN ln -sf /usr/local/bin/python3.10 /usr/bin/python3 && \
    ln -sf /usr/local/bin/python3.10 /usr/bin/python && \
    python3.10 -m ensurepip && \
    python3.10 -m pip install --upgrade pip && \
    ln -sf /usr/local/bin/pip3.10 /usr/bin/pip3 && \
    ln -sf /usr/local/bin/pip3.10 /usr/bin/pip


# Install GDB 14 from source
# Download and build GDB 14.2
RUN cd /tmp && \
    wget https://ftp.gnu.org/gnu/gdb/gdb-14.2.tar.gz && \
    tar -xzf gdb-14.2.tar.gz && \
    cd gdb-14.2 && \
    ./configure --prefix=/opt/gdb-14 --with-python=python3 && \
    make -j$(nproc) && \
    make install && \
    ln -sf /opt/gdb-14/bin/gdb /usr/local/bin/gdb && \
    ln -sf /opt/gdb-14/bin/gdb /usr/bin/gdb && \
    cd / && rm -rf /tmp/gdb-14.2*

# Install Radare2
RUN git clone https://github.com/radareorg/radare2.git /opt/radare2 && \
    cd /opt/radare2 && ./sys/install.sh && cd -

        # Create user
RUN useradd -m hacker && \
    echo "hacker ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
    


USER hacker

# Install GEF
RUN wget -q -O /home/hacker/.gdbinit-gef.py https://gef.blah.cat/py && \
    echo "source /home/hacker/.gdbinit-gef.py" >> /home/hacker/.gdbinit && \
    chown -R hacker:hacker /home/hacker && chmod 644 /home/hacker/.gdbinit*

# Install pwntools and ROPgadget
RUN pip3 install --no-cache-dir pwntools ROPgadget

WORKDIR /home/hacker/workspace

RUN curl -sSLo exploit_template.py "https://github.com/tibane0/ctf-pwn/blob/main/exploit_template.py" \
    && chmod +x exploit_template.py

CMD ["/bin/bash"]