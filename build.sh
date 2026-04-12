#!/usr/bin/env bash

name="fedora-bootc-minimal"
release="43"
tag="main"

while getopts ":n:r:t:" opt; do
    case ${opt} in
        n)
            name="$OPTARG"
            ;;
        r)
            release="$OPTARG"
            ;;
        t)
            tag="$OPTARG"
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 100
            ;;
        :)
            echo "Missing argument: -$OPTARG" >&2
            exit 120
            ;;
    esac
done

podman build --security-opt=label=disable --cap-add=all --device /dev/fuse --build-arg RELEASE="${release}" -t "${name}":"${release}"-"${tag}" -f Containerfile
