Magma AGW (LTE + 5G) Docker on Ubuntu 24.04

===========================================

This repository contains a **Docker setup for Magma Access Gateway (AGW)** supporting LTE and 5G services, running on Ubuntu 24.04.

The container includes:

-   Python 3.10 virtual environment

-   LTE gateway services

-   Optional 5G core services

-   All dependencies installed automatically

-   Startup script for automatic initialization

* * * * *

Prerequisites

-------------

-   Ubuntu 24.04 host (or any system with Docker installed)

-   Docker >= 24

-   `git` installed (if cloning the repo)


Quick Start


### 1\. Clone repository (or use local copy)

`git clone https://github.com/<your-repo>/magma-agw-docker.git

cd magma-agw-docker/docker/ubuntu24`

> If you already have the Magma source code, place it in the `/magma` directory.


### 2\. Build Docker image

`docker build -t magma-agw:24.04 .`

-   This installs all dependencies, sets up Python virtual environment, and prepares LTE/5G scripts.

-   The image is named `magma-agw:24.04`.


### 3\. Run the container

`docker run --privileged

    -v /home/magma:/home/magma

    -it

    --name magma-agw

    magma-agw:24.04`

-   `--privileged` allows network operations and IP forwarding.

-   `/home/magma` is mounted to persist logs and data.

-   The container will start LTE and 5G services automatically.

-   It keeps running (`tail -f /dev/null`) so you can enter anytime.


### 4\. Access the container

`docker exec -it magma-agw /bin/bash`

-   Check running services:

`ps aux | grep -E "python3|amf|smf|upf" | grep -v grep`


### 5\. Stopping and Removing Container

`docker stop magma-agw

docker rm magma-agw`

-   To remove the image:

`docker rmi magma-agw:24.04`
