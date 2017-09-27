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
VERSION := 2.0.6

.PHONY: all rip-src rip install-rip cc-src cc install-cc install

# REDHAWK Integration Package and Component Converter locations
GR_RIP := ../gr-redhawk_integration_python
GR_CC  := ../gr-component_converter

all: rip cc

install:
	$(error Please use install-rip and install-cc individually.)

install-rip: rip
	$(MAKE) -C $(GR_RIP) install

install-cc: cc
	$(MAKE) -C $(GR_CC) install

rip-src: $(GR_RIP)/Makefile

rip: rip-src
	$(MAKE) -C $(GR_RIP)


cc-src: $(GR_CC)/Makefile

cc: cc-src
