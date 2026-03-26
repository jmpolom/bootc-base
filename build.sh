#!/usr/bin/bash

podman build --security-opt=label=disable --cap-add=all --device /dev/fuse -t fedora-bootc-minimal:latest -f Containerfile
