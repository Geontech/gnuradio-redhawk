#!/bin/bash
# This file is protected by Copyright. Please refer to the COPYRIGHT file
# distributed with this source distribution.
#
# This file is part of GNURadio-REDHAWK.
#
# GNURadio-REDHAWK is free software: you can redistribute it and/or modify it under
# the terms of the GNU Lesser General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option) any
# later version.
#
# GNURadio-REDHAWK is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more
# details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see http://www.gnu.org/licenses/.
#
# Detect the script's location
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

source ${DIR}/image-name.sh
IMAGE_NAME=$(image_name "${TARGET_CMD}")

# Check if the image is installed yet, if not, build it.
$DIR/image-exists.sh ${IMAGE_NAME}
if [ $? -gt 0 ]; then
    echo "${IMAGE_NAME} was not built yet, building now"
    make -C $DIR/..  ${IMAGE_NAME} || { \
        echo Failed to build ${IMAGE_NAME}; exit 1;
    }
fi

# Prints the status for all containers inheriting from this image
function print_status() {
    docker ps -a \
        --filter="ancestor=${IMAGE_NAME}"\
        --format="table {{.Names}}\t{{.Mounts}}\t{{.Status}}"
}

# Try to detect the omniserver
OMNISERVER="$($DIR/omniserver-ip.sh)"

# Prints command usage information
function usage () {
    cat <<EOF

Usage: ${TARGET_CMD} [OPTIONS]
    [-s|--sdrroot   SDRROOT_VOLUME] SDRROOT (host filesystem path)
    [-w|--workspace WORKSPACE]      Workspace (host filesystem path)
    [-o|--omni      OMNISERVER]     IP to an OmniNames & Events Server
    [-p|--print]                    Just print resolved settings
    [--status]                      Print status of container(s)
    [-h|--help]                     This message.

Examples:
    Start with a workspace on your ~/redhawk_workspace path:
        ${TARGET_CMD} --workspace \${HOME}/redhawk_workspace

    Status of the locally-running ${IMAGE_NAME} instance:
        ${TARGET_CMD} --status

SECURITY NOTE:
    The resulting container will mount and chown the workspace with your
    current user's ID.  By using this script you accept this potential
    security risk.

EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -s|--sdrroot)
            SDRROOT_VOLUME="${2:?Missing SDRROOT_VOLUME Argument}"
            shift
            ;;
        -w|--workspace)
            WORKSPACE="${2:?Missing WORKSPACE Argument}"
            shift
            ;;
        -o|--omni)
            OMNISERVER="${2:?Missing OMNISERVER Argument}"
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        -p|--print)
            JUST_PRINT=YES
            ;;
        --status)
            print_status
            exit 0
            ;;
        *)
            echo ERROR: Undefined option: $1
            exit 1
            ;;
    esac
    shift # past argument
done

if ! [ -z ${JUST_PRINT+x} ]; then
    cat <<EOF
Resolved Settings:
    SDRROOT_VOLUME: ${SDRROOT_VOLUME:-None Specified}
    WORKSPACE:      ${WORKSPACE:-None Specified}
    OMNISERVER:     ${OMNISERVER:-None Specified}
EOF
    exit 0
fi

CONTAINER_NAME="gnuradio-redhawk-ui"

# Enforce required options
if [ -z ${WORKSPACE+x} ]; then
    WORKSPACE_CMD=""
else
    # Verify it's either a folder or volume name.
    if [ ! -d "$WORKSPACE" ]; then
        usage
        echo ERROR: WORKSPACE ${WORKSPACE} Does not exist as a directory.
        exit 1
    else
        WORKSPACE_CMD="-v $(readlink -f ${WORKSPACE}):/home/user/workspace"
    fi
fi

if [ -z ${SDRROOT_VOLUME+x} ]; then
    SDRROOT_CMD=""
else
    if [ ! -d "$SDRROOT_VOLUME" ]; then
        usage
        echo ERROR: SDRROOT_VOLUME ${SDRROOT_VOLUME} Does not exist as a directory.
        exit 1
    else
        SDRROOT_CMD="-v $(readlink -f ${SDRROOT_VOLUME}):/var/redhawk/sdr"
    fi
fi

# Check if we know where the OmniORB server is.
if [[ $OMNISERVER == "" ]]; then
    echo WARNING: No omniserver running or OmniORB Server IP specified
fi

# Check if such a workspace container exists
$DIR/container-running.sh ${CONTAINER_NAME}
case $? in
    1)
        echo UI Container for ${CONTAINER_NAME} has stopped.
        echo Use 'docker rm ${CONTAINER_NAME}' if you are finished with it.
        exit 1
        ;;
    0)
        echo UI Container \(${CONTAINER_NAME}\) is already running.  Joining...
        echo NOTE: If the initiating container stops, this one will close too.
        docker exec -d ${CONTAINER_NAME} ${TARGET_CMD} &> /dev/null
        ;;
    2)
        # Does not exist (good, let's make it)
        X11_UNIX=/tmp/.X11-unix
        docker run --rm -d \
            -e PUID=$(id -u) \
            -e PGID=$(id -g) \
            -e OMNISERVICEIP=${OMNISERVER} \
            -e DISPLAY=$DISPLAY \
            ${SDRROOT_CMD} \
            ${WORKSPACE_CMD} \
            -v $X11_UNIX:$X11_UNIX \
            --net host \
            --name ${CONTAINER_NAME} \
            ${IMAGE_NAME} \
            ${TARGET_CMD} &> /dev/null
        ;;
    *)
        echo ERROR: Unknown container state for ${CONTAINER_NAME}: $?
        exit 1
        ;;
esac
