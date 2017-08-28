#!/bin/bash
# This file is protected by Copyright. Please refer to the COPYRIGHT file
# distributed with this source distribution.
#
# This file is part of Geon's GNURadio-REDHAWK.
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

# Detect the script's location
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

# Prints command usage information
function usage () {
    cat <<EOF

Usage: $0 GRC_FILE [OPTIONS]

    [-o|--out]     Output directory for the Component

    [-u|--use-dev] If present, treat all arguments as being run in an the
                   already-running development container.

    DOCKER GPP Support:

    [--docker-image]   Image name to use for the container

    [--docker-volume]  Volume(s) to mount to the Component's container

Examples:
    Wrap my_flowgraph.grc in a Component in the default output directory.
        $0 my_flowgraph.grc 

    Warp my_flowgraph.grc in a Component using 'my_flowgraph' as the
    output directory.
        $0 my_flowgraph.grc --out ./my_flowgraph

EOF
}

if [[ $# -eq 0 ]] || [[ $1 == "--help" ]]; then
    usage
    exit 0
fi

# First argument must be the GRC file
GRC_FILE=${1}
shift

# Parse arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -u|--use-dev)
            USE_DEV=YES
            ;;
        --docker-image)
            if ! [ -z ${DOCKER_IMAGE+x} ]; then
                usage
                echo ERROR: Only one Docker image can be specified.
            fi
            DOCKER_IMAGE="--docker-image ${2:?Missing Docker Image Name}"
            shift
            ;;
        --docker-volume)
            DOCKER_VOLUMES="${DOCKER_VOLUMES} --docker-volume ${2:?Missing Docker Volume Name}"
            shift
            ;;
        -o|--out)
            OUTPUT_DIR="${2:?Missing Output Directory Argument}"
            shift
            ;;
        -p|--print)
            JUST_PRINT=YES
            ;;
        *)
            echo ERROR: Undefined option: $1
            exit 1
            ;;
    esac
    shift # past argument
done

# Sanity check the docker setup
if [ -z ${DOCKER_IMAGE+x} ] && [ ! -z ${DOCKER_VOLUMES+x} ]; then
    echo ERROR: If you specify docker volume\(s\), you must specify an image.
    exit 1
fi

# If not set, default output directory is '.'
OUTPUT_DIR=${OUTPUT_DIR:-.}

# Common vars. and command prefix
DOCKER_CMD=(docker)
DOCKER_USER_HOME=/home/user
DOCKER_USER_WORKSPACE=${DOCKER_USER_HOME}/workspace

if [[ ${USE_DEV} == 'YES' ]]; then
    # Use exec on the container.  Target is the expected
    # container name.  User flags are extended with '-u user'
    # so that exec occurs as the internal user (which has the
    # same ID as the external one)
    DOCKER_CMD+=(exec -it -u user)
    DOCKER_NAME="gnuradio-redhawk-ui"
    DOCKER_GRC_FILE=${DOCKER_USER_WORKSPACE}/${GRC_FILE}
    DOCKER_GRC_FILE=${DOCKER_USER_WORKSPACE}/${OUTPUT_DIR}

    # Make sure it's running
    $DIR/container-running.sh ${DOCKER_NAME}
    if [[ $? -gt 0 ]]; then
        echo "ERROR: The development container, ${DOCKER_NAME}, is not running."
        exit 1
    fi

else

    # GRC file and output directory will be locally mounted
    # Verify the GRC exists.
    GRC_FILE=$(readlink -f ${GRC_FILE})
    if [[ ! -f ${GRC_FILE} ]]; then
        echo "ERROR: GRC File does not exist: ${GRC_FILE}"
        exit 1
    fi

    # Create the output directory if it doesn't exist.
    OUTPUT_DIR=$(readlink -f ${OUTPUT_DIR})
    [[ -d ${OUTPUT_DIR} ]] || mkdir -p ${OUTPUT_DIR}

    # Need to mount the external GRC file and workspace
    DOCKER_GRC_FILE=${DOCKER_USER_HOME}/temp/$(basename ${GRC_FILE})
    DOCKER_OUTPUT_DIR=${DOCKER_USER_HOME}/workspace
    DOCKER_CMD+=(run --rm -it)
    DOCKER_CMD+=(-e PUID=$(id -u))
    DOCKER_CMD+=(-e PGID=$(id -g))
    DOCKER_CMD+=(-v ${GRC_FILE}:${DOCKER_GRC_FILE})
    DOCKER_CMD+=(-v ${OUTPUT_DIR}:${DOCKER_OUTPUT_DIR})

    filename=$(basename "$SOURCE")
    source ${DIR}/image-name.sh
    DOCKER_NAME=$(image_name "${filename%.*}")
fi

# Stitch together the rest of the Docker command and run it.
DOCKER_CMD+=(${DOCKER_NAME})
DOCKER_CMD+=(bash -lc)
DOCKER_CMD+=("xvfb-run /home/user/converter/run.py \
    ${DOCKER_IMAGE} \
    ${DOCKER_VOLUMES} \
    ${DOCKER_GRC_FILE} \
    ${DOCKER_OUTPUT_DIR} \
    ")
"${DOCKER_CMD[@]}"
