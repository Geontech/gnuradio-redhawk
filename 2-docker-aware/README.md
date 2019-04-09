# Docker-aware GPP

In this approach, one replaces the standard GPP with [an extended version][docker-gpp] that has been modified to permit calling on the Docker daemon when Components are loaded.  This new GPP also includes additional, allocable properties that assist Flow Graph Components in being deployed specifically to these GPPs as well as executing the Component within its own, containerized runtime environment.

This is the deployment strategy described at GRCon 2017.

 > Note: This route requires building on [Docker-REDHAWK-Ubuntu images][docker-redhawk-ubuntu].  This currently requires using Docker v17 or better.  Please refer to Docker-REDHAWK-Ubuntu's documentation for more information.

## Why?

By utilizing this modified GPP, the generated Component can have additional deployment requirements (allocable properties) that assist REDHAWK in locating a GPP that has the Component's associated Docker image locally cached.  This means the [traditional][traditional-technical-considerations] no longer apply since we're using more of the REDHAWK infrastructure and automation to our advantage.

**TBD:** In a future release of the [docker-gpp][docker-gpp], the allocation properties for image locating will be replaced with `docker pull...` requests (vs. the current `docker images...` check).  This will allow the GPP to dynamically load the Component's image in preparation for executing the Component's container.  This adds an extra layer of automatic provisioning via Docker that already exists for traditional Components. 

## How?

The process for developing this support was as follows.  These steps have already occurred.  [See installation](#installation).

1. Extend the [Docker-REDHAWK][docker-redhawk] Runtime image to be a new base image with:
   1. GNURadio
   2. `gr-redhawk_integration`

2. Extend this new image similar to the [Docker-REDHAWK][docker-redhawk] Development image definition, but also including:
   1. GNURadio
   2. `gr-redhawk_integration`
   3. `gr-component_converter`
   4. Script or other functionality to support running the GNURadio Companion (like the REDHAWK IDE, rhide.sh, script)

 > Note 1: In this scenario, there's no need to provision the two images with the end user's specific support libraries since each Component will have its own derived image for those needs.

 > Note 2: The Runtime and Development images are derived from [Docker-REDHAWK-Ubuntu][docker-redhawk-ubuntu], which is currently based on Ubuntu 16.04, if that is your preference.

## Technical Considerations

Since every Component has its own Docker image, one might believe this to be extremely expensive (in terms of hard drive space, network usage, etc.), especially once we see the runtime base image is 2 GB.  However once the Runtime image, common to all generated Components, is provisioned to the Docker-aware GPP, the small _delta_ of the derived Component image is the only part actually downloaded (which should be trivially small by comparison).

## Installation



### On a GPP Host

Though it is assumed this host is running a standard REDHAWK SDR installation (RPM-based), it is not required.  In either case, the installed GPP needs to be replaced by our Docker-GPP.  This will extend its functionality 

In order to do this however, please uninstall your existing GPP in `$SDRROOT/dom/devices/GPP`.  Then compile the Docker-GPP and build the runtime image:

```
make gpp
```

Later, you will need to also build your Component container images as you convert flow graphs.  The conversion process will result in a Dockerfile and build script to help this process along.  [See Component Generation](#component-generation).

For whatever user will run the Device Manager instance, add the `docker` group or perform whatever other necessary steps to allow that user access to running the Docker Daemon.

 > Note: At this time, one has to manually provision GPPs with the images.  In the future, the Docker-GPP may be modified to issue `docker pull...` during load requests.

 > Note: If at some point you want to uninstall the Docker-GPP, use `make uninstall-docker-gpp`.


### On a Development Host

The development environment can be instantiated on a Linux-based Docker host.  It provides scripts for running both the GNURadio Companion and the REDHAWK IDE.

```
make development
```

The following scripts are then linked:

|Name|Purpose|
|----|-------|
| rhide | Runs the REDHAWK IDE |
| gnuradio-companion | Runs the GNURadio Companion |
| convert | Converts a GRC to a REDHAWK Component |

Each script has its own `--help` menu describing the features.  For the two development environments, and unlike Docker-REDHAWK on which each are drived, these do not require creating Docker volumes for your workspace or SDRROOT.  Instead it is expected both will be locations on your host OS, if specified.  

For example, the following will start a REDHAWK IDE:

```
./rhide --workspace ./workspace
```

You can then run the GNURadio Companion attached to that same environment:

```
./gnuradio-companion
```

 > Important: Whichever of the above two steps occurred first will be the instance controlling whether or not the container stays running.  So if you start the IDE and then close it while you work in GNURadio Companion, the companion will close as well.

Proceed to [component generation](#component-generation) for converting Flow Graphs to Components.


## Component Generation

First, ensure you have the development image and conversion script available:

```
make convert geontech/gnuradio-redhawk-development
```

You can then convert an existing GRC and set its image name:

```
./convert my_flowgraph.grc --docker-image my_flowgraph
```

The resulting component will be generated into a subdirectory of your current working directory (use `--out` to overwrite this).  The directory has the typical files plus a few for Docker-based deployments:

| File | Purpose | Usage |
| `build.sh` | Installs the Component on the local file system | `./build.sh install` |
| `Dockerfile` | Basic image that installs the Component into the runtime image environment | None unless you have other dependencies |
| `build-image.sh` | Builds the image described in `Dockerfile` | `./build-image.sh` |

 > Note: The `convert` script ignores the running development environment (if present) unless `--use-dev` is added to the command.  In that case, all file locations are treated as relative to the container's workspace (`/home/user/workspace`).

### Component Installation

**Domain and _ANY_ Development System:** run `./build.sh install` to load the Component so that it can be referenced in Waveforms.

**Docker-GPP Hosts:** run `./build-image.sh` or use `docker pull` if the image is stored in a repository.  In the latter case, make certain the image is tagged exactly as described when running `convert`.


[traditional-technical-considerations]: ../1-traditional/README.md#technical-considerations
[docker-gpp]: https://github.com/GeonTech/core-framework/tree/docker-gpp
[docker-redhawk]: https://github.com/GeonTech/docker-redhawk
[docker-redhawk-ubuntu]: https://github.com/GeonTech/docker-redhawk-ubuntu
[gr-cc]: ../gr-component_converter/README.md
