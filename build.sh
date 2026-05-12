#!/usr/bin/env bash

set -xeu

# defaults
containerfile="Containerfile"
name="fedora-bootc-minimal"
rel="43"
ts="main"

while getopts ":c:d:n:r:s:" opt; do
    case ${opt} in
        c)
            containerfile="$OPTARG"
            ;;
        d)
            registry="$OPTARG"
            ;;
        n)
            name="$OPTARG"
            ;;
        r)
            rel="$OPTARG"
            ;;
        s)
            # tag suffixes
            tss+=("$OPTARG")
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Missing argument: -$OPTARG" >&2
            exit 2
            ;;
    esac
done

# construct image names with suffixed tags
if [ -v tss ]; then
    for t in "${tss[@]}"; do
        tagged_names+=("${name}:${rel}-${t}")
    done
else
    tagged_names+=("${name}:${rel}-${ts}")
fi

# construct array of tag opts for podman build
for n in "${tagged_names[@]}"; do
    tag_opts+=("-t" "${n}")
done

# build the container
podman build --security-opt=label=disable --cap-add=all --device /dev/fuse --build-arg RELEASE="${rel}" "${tag_opts[@]}" -f "${containerfile}" .

# push if a registry was specified
if [ -v registry ]; then
    for n in "${tagged_names[@]}"; do
        podman push "${n}" "${registry}/${n}"
    done
fi
