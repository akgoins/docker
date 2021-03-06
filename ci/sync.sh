#!/bin/bash

set -e

DIR_ICI=$(rospack find industrial_ci)
source $DIR_ICI/src/util.sh
source $DIR_ICI/src/docker.sh

DIR_THIS="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
HEADER="# DO NOT EDIT!\n# This file  was auto-generated with ./sync.sh at $(LC_ALL=C date)\n"
INJECT_MAINTAINER="/^FROM/a LABEL MAINTAINER \"$(git config --get user.name)\" <$(git config --get user.email)>"

function export_dockerfile {
    ROS_DISTRO=$1
    ROS_REPO=$2
    UBUNTU_OS_CODE_NAME=
    OS_CODE_NAME=
    DOCKER_BASE_IMAGE=

    source $DIR_ICI/src/env.sh
    OS_CODE_NAME=${3:-$OS_CODE_NAME}
    DOCKER_BASE_IMAGE=${4:-$DOCKER_BASE_IMAGE}

    local path=$DIR_THIS/$ROS_DISTRO-${5:-$OS_CODE_NAME}${ROS_REPO#ros}
    mkdir -p "$path"

    echo -e "$HEADER" > $path/Dockerfile
    ici_generate_default_dockerfile | sed "$INJECT_MAINTAINER" >> $path/Dockerfile
}

for r in ros ros-shadow-fixed; do
    for d in hydro indigo jade kinetic lunar; do
        export_dockerfile $d $r
    done
    export_dockerfile kinetic $r jessie debian:jessie
    export_dockerfile lunar $r yakkety
    export_dockerfile lunar $r zesty
    export_dockerfile lunar $r stretch debian:stretch
done

