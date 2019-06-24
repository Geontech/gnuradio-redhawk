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

# Dependencies
apt-get update
apt-get -y install git-core cmake g++ python-dev swig \
pkg-config libfftw3-dev libboost-all-dev libcppunit-dev libgsl0-dev \
libusb-dev libsdl1.2-dev python-wxgtk3.0 python-numpy \
python-cheetah python-lxml doxygen libxi-dev python-sip \
libqt4-opengl-dev libqwt-dev libfontconfig1-dev libxrender-dev \
python-sip python-sip-dev python-qt4 python-sphinx libusb-1.0-0-dev \
libcomedi-dev libzmq-dev build-essential python-docutils python-mako \
libusb-1.0-0-dev python-setuptools python-gtk2

# Clone
git clone git://github.com/EttusResearch/uhd.git
git clone -b maint-3.7 --recursive git://github.com/gnuradio/gnuradio.git

## UHD ##
pushd /root/uhd/host
mkdir build && cd build
cmake ..
make
make install
ldconfig
popd

## GNURADIO ##
pushd /root/gnuradio
mkdir build && cd build
cmake .. -DENABLE_GR_AUDIO=ON -DENABLE_GR_BLOCKS=ON -DENABLE_GR_DIGITAL=ON -DENABLE_GR_FEC=ON -DENABLE_GR_FFT=ON -DENABLE_GR_FILTER=ON -DENABLE_GR_QTGUI=ON -DENABLE_GR_UHD=ON -DENABLE_PYTHON=ON -DENABLE_VOLK=ON -DENABLE_GRC=ON
make
make install
popd



# Build and install Geon's CORBA Ports
. /etc/profile
pushd /root/gr-redhawk_integration
mkdir -p build && cd build
cmake ..
make install

# Clean up.
tiny-apt clean
