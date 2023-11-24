############################################################
#
# First stage: Build riscv-gnu-toolchain
#
############################################################

FROM ubuntu:22.04 AS builder
LABEL maintainer="xuyibin21b@ict.ac.cn"

WORKDIR /workspace

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
# Second stage: Clone DASICS repositories
#
############################################################

FROM ubuntu:22.04
LABEL maintainer="xuyibin21b@ict.ac.cn"

WORKDIR /workspace

COPY --from=builder /workspace/riscv /opt/riscv

RUN echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://security.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse" >> /etc/apt/sources.list

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
        device-tree-compiler && \
    apt clean && \
    ln -sf /usr/bin/python3 /usr/bin/python

# Clone QEMU-DASICS, riscv-pk, riscv-linux, riscv-rootfs
RUN git clone -b xs-dasics-qemu-8.1.0 https://github.com/DASICS-ICT/QEMU-DASICS.git && \
        cd QEMU-DASICS && \
        git reset --hard 7a1a44528d112e308a200ce49fc4c1fb51b4085e && \
        cd .. && \
    git clone -b dasics-qemu-8.1.0 https://github.com/DASICS-ICT/riscv-pk.git && \
        cd riscv-pk && \
        git reset --hard 05f77eb9a4f6406425f2ad21ba0c1047faf991b4 && \
        cd ..  && \
    git clone -b linux-5.10.167 https://github.com/DASICS-ICT/riscv-linux.git && \
        cd riscv-linux && \
        git reset --hard 8e4d97a0d93fe0aba7dbf76f0e4f817d49d6e24d && \
        cd .. && \
    git clone -b xs-dasics-linux https://github.com/DASICS-ICT/riscv-rootfs.git && \
        cd riscv-rootfs && \
        git reset --hard bb403c07c525f76df4218062d0e94680ebf4bbd0 && \
        cd ..

ENV WORKSPACE=/workspace
ENV RISCV=/opt/riscv
ENV PATH=$RISCV/bin:$PATH
# ENV NEMU_HOME=$WORKSPACE/NEMU
ENV RISCV_ROOTFS_HOME=$WORKSPACE/riscv-rootfs

CMD [ "/bin/bash" ]

EXPOSE 8000
