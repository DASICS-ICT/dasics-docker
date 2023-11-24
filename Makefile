IMG_NAME = dasics-docker
IMG_TAG  = 1.0.0

DIR_TOP  = $(shell pwd)

SRC_DOCKERFILE = $(DIR_TOP)/Dockerfile

HOST_PORT   ?= 5678
HOST_DASICS ?=

.PHONY: all image run

all: image

image: $(SRC_DOCKERFILE)
	sudo docker build --network host --tag $(IMG_NAME):$(IMG_TAG)							\
		--build-arg http_proxy=$(http_proxy)     --build-arg HTTP_PROXY=$(HTTP_PROXY)		\
		--build-arg https_proxy=$(https_proxy)   --build-arg HTTPS_PROXY=$(HTTPS_PROXY)		\
		--build-arg socks5_proxy=$(socks5_proxy) --build-arg SOCKS5_PROXY=$(SOCKS5_PROXY) .

run:
ifdef HOST_DASICS
	sudo docker run -it -p $(HOST_PORT):8000 -v $(HOST_DASICS):/workspace/dasics $(IMG_NAME):$(IMG_TAG)
else
	@echo "WARNING: HOST_DASICS is not defined, thus not map user's directory to the container!"
	sudo docker run -it -p $(HOST_PORT):8000 $(IMG_NAME):$(IMG_TAG)
endif
