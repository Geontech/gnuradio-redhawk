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

VERSION := $(shell ./scripts/version.sh)
IMAGE_PREFIX := $(shell ./scripts/image-prefix.sh)
IMAGE_BUILD = docker build --rm \
		-f ./Dockerfiles/$(subst $(IMAGE_PREFIX),,$1).Dockerfile \
		-t $1:$(VERSION) \
		./Dockerfiles \
		&& \
	docker tag $@:$(VERSION) $@:latest

RUNTIME_IMAGE := $(IMAGE_PREFIX)runtime
DEVELOPMENT_IMAGE := $(IMAGE_PREFIX)development
ALL_IMAGES := $(RUNTIME_IMAGE) $(DEVELOPMENT_IMAGE)
LINKED_SCRIPTS := gnuradio-companion rhide convert

REQUIRED_SUBMODS := gr-component_converter gr-redhawk_integration_python
SUBMOD_DST_DIR := ./Dockerfiles/integ/
SUBMOD_SRC_DIR := ../

# Docker GPP Related
DOCKER_GPP_REPO := -b docker-gpp git://github.com/GeonTech/core-framework
CF_DIR := CF
GPP_BUILD_DIR := $(CF_DIR)/GPP
GPP_BUILD_TARGET := $(GPP_BUILD_DIR)/cpp/GPP
GPP_INSTALL_DIR := $(SDRROOT)/dev/devices/GPP
GPP_INSTALL_TARGET:= $(GPP_INSTALL_DIR)/cpp/GPP
GPP_MAKE_TARGETS := docker-gpp uninstall-docker-gpp

.PHONY: all pull deliver clean helper_scripts $(REQUIRED_SUBMODS) $(GPP_MAKE_TARGETS)

all: $(ALL_IMAGES) $(LINKED_SCRIPTS) gpp

pull: $(LINKED_SCRIPTS)
	$(foreach image,$(ALL_IMAGES),\
		$(shell docker pull $(image):$(VERSION)) \
		$(shell docker tag $(image):$(VERSION) $(image):latest) \
		)

$(REQUIRED_SUBMODS):
	@$(eval SUBMOD_DST := $(addprefix $(SUBMOD_DST_DIR),$@))
	@$(eval SUBMOD_SRC := $(addprefix $(SUBMOD_SRC_DIR),$@))
	@[ -d $(SUBMOD_DST_DIR) ] || mkdir -p $(SUBMOD_DST_DIR)
	@if [ ! -d "$(SUBMOD_DST)" ]; then \
		cp -r $(SUBMOD_SRC) $(SUBMOD_DST); \
	fi;

$(ALL_IMAGES): $(REQUIRED_SUBMODS)
	$(call IMAGE_BUILD,$@)

helper_scripts: $(LINKED_SCRIPTS)

$(LINKED_SCRIPTS):
	@ln -s scripts/$@.sh ./$@
	@chmod a+x ./$@


$(GPP_BUILD_DIR):
	@[ -f `which git` ] || { echo "Install git."; exit 1; }
	git clone $(DOCKER_GPP_REPO) $(CF_DIR)

$(GPP_BUILD_TARGET): $(GPP_BUILD_DIR)
	pushd $(GPP_BUILD_DIR) && ./build.sh && popd

docker-gpp: $(GPP_INSTALL_TARGET)

$(GPP_INSTALL_TARGET): $(GPP_BUILD_TARGET)
ifeq ($(shell yum list installed GPP &> /dev/null; echo $$?),0)
	$(error Standard GPP is installed (you need to remove it))
else
	$(info Installing)
	@pushd $(GPP_BUILD_DIR) && ./build.sh install && popd;
endif

uninstall-docker-gpp:
ifeq ($(shell [[ -d $(GPP_INSTALL_DIR) ]]; echo $$?),0)
ifeq ($(shell yum list installed GPP &> /dev/null; echo $$?),1)
	$(info Removing Docker-GPP)
	rm -r $(GPP_INSTALL_DIR)
else
	$(info The installed GPP is the default.  Exiting.)
endif
else
	$(info No GPP is installed.)
endif


# Cleaning
remove_container = $(shell docker rm -f $1)
remove_image = $(shell docker rmi $1)
list_containers = $(shell docker ps -qa --filter="ancestor=$1")
for_each_container = $(foreach container,$(call list_containers,$1),\
	$(call remove_container,$(container)) \
	$(info --> Removed $(container)) \
	)
for_each_image = $(foreach image,$1,\
	$(info Checking $(image):$(VERSION)...) \
	$(if $(call image_check,$(image):$(VERSION)),\
		$(call for_each_container,$(image)) \
		$(call remove_image,$(image):$(VERSION)) \
		$(call remove_image,$(image):latest) \
		$(info Removed with $(image):$(VERSION) and latest), \
		$(info Nothing to do for $(image):$(VERSION)) \
		)\
	)

clean:
	@$(eval result := $(call for_each_image,$(ALL_IMAGES)))
	@rm -f $(LINKED_SCRIPTS)
	@$(eval result := $(foreach mod,$(REQUIRED_SUBMODS),\
		$(eval SUBMOD_DST := $(addprefix $(SUBMOD_DST_DIR),$(mod))) \
		$(shell rm -rf $(SUBMOD_DST)) \
		))
	@[ -d CF ] && rm -rf CF
