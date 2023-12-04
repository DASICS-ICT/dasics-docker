############################################################
#
# First stage: Build riscv-gnu-toolchain
#
############################################################

FROM ubuntu:22.04 AS builder
LABEL maintainer="xuyibin21b@ict.ac.cn"

WORKDIR /workspace

# For Chinese users, change the default apt source to THU mirrors
RUN echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://security.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse" >> /etc/apt/sources.list

# Install packages to build riscv-gnu-toolchain
RUN apt update && \
    apt install -y gcc \
        g++ \
        make \
        git \
        autoconf \
        automake \
        autotools-dev \
        curl \
        python3 \
        libmpc-dev \
        libmpfr-dev \
        libgmp-dev \
        gawk \
        build-essential \
        bison \
        flex \
        texinfo \
        gperf \
        libtool \
        patchutils \
        bc \
        zlib1g-dev \
        libexpat-dev && \
    apt clean

# Build riscv-gnu-toolchain
RUN git clone -b toolchain-bkp https://github.com/OpenXiangShan/riscv-gnu-toolchain.git && \
    cd riscv-gnu-toolchain && \
    git reset --hard 2f92042b145e0ad0bdbe0d2d4b0602fc50ac38d2 && \
    ./configure --prefix=/workspace/riscv && \
    make -j`nproc` && \
    make linux -j`nproc` && \
    cd ..

############################################################
#
# Second stage: Set up DASICS environment
#
############################################################

FROM ubuntu:22.04
LABEL maintainer="xuyibin21b@ict.ac.cn"

WORKDIR /workspace

COPY --from=builder /workspace/riscv /opt/riscv

# For Chinese users, change the default apt source to THU mirrors
RUN echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://security.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse" >> /etc/apt/sources.list

# Install packages for verilator, mill and docker-entrypoint.sh
RUN apt update && \
    apt install -y gcc \
        g++ \
        make \
        git \
        gosu \
        sudo \
        help2man \
        perl \
        perl-doc \
        python3 \
        pip \
        clang \
        curl \
        autoconf2.69 \
        bison \
        flex \
        ccache \
        openjdk-11-jre && \
    apt clean && \
    ln -sf /usr/bin/python3 /usr/bin/python

# Install verilator
RUN git clone -b v4.218 https://github.com/verilator/verilator.git && \
    cd verilator && \
    autoconf2.69 && \
    ./configure CC=clang CXX=clang++ && \
    make -j`nproc` && \
    make install && \
    cd .. && \
    rm -rf ./verilator

# Install mill
RUN sh -c "curl -L https://github.com/com-lihaoyi/mill/releases/download/0.9.8/0.9.8 > /usr/local/bin/mill && chmod +x /usr/local/bin/mill" && \
    mill --version

# Install packages for DASICS repositories
RUN apt install -y ninja-build \
        libpixman-1-dev \
        libglib2.0-dev \
        libncurses5-dev \
        openssl \
        libssl-dev \
        build-essential \
        pkg-config \
        libc6-dev \
        libelf-dev \
        libtool \
        bc \
        device-tree-compiler \
        libsdl2-dev \
        time \
        libreadline6-dev \
        sqlite3 \
        libsqlite3-dev \
        zlib1g-dev && \
    apt clean

# Install additional auxiliary packages
RUN apt install -y openssh-server \
        vim \
        tmux \
        inetutils-ping && \
    apt clean

# Add toolchain to $PATH
ENV RISCV=/opt/riscv
ENV PATH=$RISCV/bin:$PATH

# Set the entrypoint script for creating new user with the same uid as host user
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod a+x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh", "/bin/bash"]

EXPOSE 8000
