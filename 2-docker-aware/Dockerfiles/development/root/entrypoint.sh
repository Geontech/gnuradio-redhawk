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

# Update user's ID

if [ ! "$(id -u user)" -eq "$PUID" ]; then usermod -o -u "$PUID" user ; fi
if [ ! "$(id -g user)" -eq "$PGID" ]; then groupmod -o -g "$PGID" user ; fi

chown -R user:user /home/user

# Generate machine ID for containerized GUI support.
dbus-uuidgen > /etc/machine-id

function switch-run () {
    exec su -c "$@" --login user 
}

function gnuradio-companion () {
    # Run the GNURadio Companion
    pushd /home/user/workspace
    switch-run 'gnuradio-companion'
}

function rhide () {
    # Run the IDE
    switch-run 'rhide -data ~/workspace'
}

switch-run "$@"
