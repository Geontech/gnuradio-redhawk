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
#
FROM geontech/gnuradio-redhawk-runtime:2.2.1
LABEL name="GNURadio and REDHAWK SDR Development (Ubuntu)" \
    description="REDHAWK SDR with GNURadio w/ Development Environments"

# Internal process' user's UID and GID (initial)
ENV PUID 54321
ENV PGID 54321

# Install GNURadio & Geon's data ports and tooling
WORKDIR /root
COPY integ/ /root/
COPY common/ development/ /
RUN apt-get update && \
    apt-get install -qy --no-install-recommends \
        dbus \
        packagekit-gtk3-module \
        libcanberra-gtk-module \
        xvfb && \
    rm -rf /var/lib/apt/lists/* && \
    ./ide.sh && \
    #
    # Setup internal user and group
    #
    mkdir -p /home/user && \
    groupmod -g 1000 users && \
    useradd --system \
        --uid $PUID \
        --shell /bin/bash \
        --groups redhawk \
        user && \
    groupmod -g $PGID user && \
    #
    # Install component converter
    # (Tool installs to user's directory /home/user/converter)
    #
    ./gr-component-converter-install.sh

# Exposed volumes
VOLUME /var/redhawk/sdr
VOLUME /home/user/workspace

WORKDIR /home/user

ENTRYPOINT [ "/root/entrypoint.sh" ]

