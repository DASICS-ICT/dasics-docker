# DASICS Docker Development Environment

This repository provides a Docker-based development environment for DASICS (Dynamic in-Address-Space Isolation by Code Segments), including riscv-gnu-toolchain and some other packages.

## Prerequisites

Before using this Docker environment, ensure that you have Docker installed on your system, and you have been added to docker group.

## Building the Docker Image

To build the Docker image, use the provided Makefile. If you need to use a proxy during the build process, ensure that the proxy is configured on your local machine before initiating the build.

Open a terminal and navigate to the repository directory. Run the following command:

```bash
make image
```

This command will build the Docker image using the specified Dockerfile and tag it with the name `dasics-docker`. Additionally, it accepts proxy settings as build arguments. If a proxy is required during the build process, make sure that your local machine has the proxy configured before running the command.

## Running the Docker Container

To run the Docker container, use the following command:

```bash
make run [HOST_DASICS=<path/to/host/dasics>]
```

- `HOST_DASICS`: Specify the host directory to be mounted inside the Docker container. If not provided, the user's directory will not be mapped to the container.
- If a proxy is necessary during the container's runtime, ensure that your local machine has the proxy configured before executing the command.