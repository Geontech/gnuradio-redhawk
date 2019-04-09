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
#

set -e

# Install git, curl
tiny-apt add curl git

# Install pip
curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
chmod +x get-pip.py
./get-pip.py && rm get-pip.py

# Install cmake (and gnuradio, which should already be installed)
#tiny-apt add cmake gnuradio
pip install git+https://github.com/gnuradio/pybombs.git
pybombs auto-config
pybombs recipes add-defaults
pybombs prefix init ~/prefix -a myprefix -R gnuradio-default
source ~/prefix/setup_env.sh

# Build and install Geon's CORBA Ports
. /etc/profile
pushd /root/gr-redhawk_integration
mkdir -p build && cd build
cmake ..
make install

# Clean up.
#tiny-apt clean
