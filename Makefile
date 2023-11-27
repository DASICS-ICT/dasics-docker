######################################################
# Makefile for DASICS Docker Image
######################################################

# Docker Image Variables
IMG_NAME    := dasics
IMG_VERSION := dev-1.1.0
IMG_TAG     := $(IMG_NAME):$(IMG_VERSION)

# Host Machine Variables
DIR_TOP        := $(shell pwd)
SRC_DOCKERFILE := $(DIR_TOP)/Dockerfile
HOST_DASICS    ?=

# Docker Variables
DOCKER           := docker
DOCKER_VOLUME    := $(if $(HOST_DASICS), -v $(HOST_DASICS):$(HOST_DASICS), )
DOCKER_BUILD_NET := --network host \
	--build-arg http_proxy=$(http_proxy)     --build-arg HTTP_PROXY=$(HTTP_PROXY)     \
	--build-arg https_proxy=$(https_proxy)   --build-arg HTTPS_PROXY=$(HTTPS_PROXY)   \
	--build-arg socks5_proxy=$(socks5_proxy) --build-arg SOCKS5_PROXY=$(SOCKS5_PROXY)
DOCKER_RUN_NET   := --network host --hostname docker \
	-e http_proxy=$(http_proxy)     -e HTTP_PROXY=$(HTTP_PROXY)     \
	-e https_proxy=$(https_proxy)   -e HTTPS_PROXY=$(HTTPS_PROXY)   \
	-e socks5_proxy=$(socks5_proxy) -e SOCKS5_PROXY=$(SOCKS5_PROXY)
DOCKER_RUN_USER  := -e HOST_UID=$(shell id -u $$USER)
DOCKER_RUN_NAME  := --name dasics-$(USER)
DOCKER_RUN_DASICS:= $(if $(HOST_DASICS), -w $(HOST_DASICS) \
	-e NOOP_HOME=$(HOST_DASICS)/xiangshan-dasics \
	-e NEMU_HOME=$(HOST_DASICS)/NEMU \
	-e RISCV_ROOTFS_HOME=$(HOST_DASICS)/riscv-rootfs, )

######################################################
# Makefile Rules
######################################################

.PHONY: all image run

# Default target
all: image

# Build Docker Image
image: $(SRC_DOCKERFILE)
	$(DOCKER) build $(DOCKER_BUILD_NET) --tag $(IMG_TAG) .

# Run Docker Container
run:
	-$(DOCKER) run --rm -it $(DOCKER_RUN_NET) $(DOCKER_RUN_USER) $(DOCKER_RUN_NAME) \
		$(DOCKER_VOLUME) $(DOCKER_RUN_DASICS) $(IMG_TAG)
