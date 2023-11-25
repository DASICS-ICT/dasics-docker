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

# Install packages for DASICS repositories
RUN apt update && \
    apt install -y gcc \
        g++ \
        make \
        git \
        python3 \
        pip \
        openssh-server \
        ninja-build \
        libpixman-1-dev \
        libglib2.0-dev \
        libncurses5-dev \
        openssl \
        libssl-dev \
        build-essential \
        pkg-config \
        libc6-dev \
        bison \
        flex \
        libelf-dev \
        libtool \
        bc \
        device-tree-compiler \
        curl \
        libsdl2-dev \
        openjdk-11-jre \
        clang \
        time \
        libreadline-dev && \
    apt clean && \
    ln -sf /usr/bin/python3 /usr/bin/python

# Install mill
RUN sh -c "curl -L https://github.com/com-lihaoyi/mill/releases/download/0.10.0-M4/0.10.0-M4 > /usr/local/bin/mill && chmod +x /usr/local/bin/mill" && \
    mill --version

# Install verilator
RUN git clone -b v4.218 https://github.com/verilator/verilator.git && \
    cd verilator && \
    autoupdate && \
    autoconf && \
    ./configure CC=clang CXX=clang++ && \
    make -j`nproc` && \
    make install && \
    cd .. && \
    rm -rf ./verilator

# Set environment variables for DASICS
ENV RISCV=/opt/riscv
ENV PATH=$RISCV/bin:$PATH
ENV DASICS_TOP=/workspace/dasics
ENV RISCV_ROOTFS_HOME=$DASICS_TOP/riscv-rootfs
ENV NEMU_HOME=$DASICS_TOP/NEMU
ENV NOOP_HOME=$DASICS_TOP/xiangshan-dasics

CMD [ "/bin/bash" ]

EXPOSE 8000
