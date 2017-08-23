# Docker-aware GPP

In this approach, one replaces the standard GPP with [an extended version][docker-gpp] that has been modified to permit calling on the Docker daemon when Components are loaded.  This new GPP also includes additional, allocable properties that assist Flow Graph Components in being deployed specifically to these GPPs as well as executing the Component within its own, containerized runtime environment.

This is the deployment strategy described at GRCon 2017.

## Why?

By utilizing this modified GPP, the generated Component can have additional deployment requirements (allocable properties) that assist REDHAWK in locating a GPP that has the Component's associated Docker image locally cached.  This means the [traditional][traditional-technical-considerations] no longer apply since we're using more of the REDHAWK infrastructure and automation to our advantage.

**TBD:** In a future release of the [docker-gpp][docker-gpp], the allocation properties for image locating will be replaced with `docker pull...` requests (vs. the current `docker inspect` check).  This will allow the GPP to dynamically load the Component's image in preparation for executing the Component's container.  This adds an extra layer of automatic provisioning via Docker that already exists for traditional Components. 

## How?

The following modifications must take place:

1. Extend the [Docker-REDHAWK][docker-redhawk] Runtime image to be a new base image with:
   1. GNURadio
   2. `gr-redhawk_integration_python`

2. Extend this new image similar to the [Docker-REDHAWK][docker-redhawk] Development image definition, but also including:
   1. GNURadio
   2. `gr-redhawk_integration_python`
   3. `gr-component_converter`
   4. Script or other functionality to support running the GNURadio Companion (like the REDHAWK IDE, rhide.sh, script)

 > Note 1: In this scenario, there's no need to provision the two images with the end user's specific support libraries since each Component will have its own derived image for those needs.

 > Note 2: The Runtime and Development images can be derived from [Docker-REDHAWK-Ubuntu][docker-redhawk-ubuntu], which is currently based on Ubuntu 16.04, if that is your preference.

## Component Generation

Components generated using the [Component Converter][gr-cc] need the **TBD** flag set to generate a Docker-aware GPP -compatible implementation.  This will instantiate the allocable property relationships to ensure the Component is only ever executed on a Docker-aware GPP.

Recall, in this method, the GPP executes a Component within a Docker Container.  Therefore once the Component project is created, one must deploy a Docker image, derived from the above new Runtime image, that has the Component installed in the `SDRROOT` _of the image_.

Moreover, this Component also needs to be installed in the Domain's SDRROOT.  This will allow you to create Waveforms that reference the Component as well as allow the Domain to launch Waveforms containing this Component.

## Technical Considerations

Since every Component has its own Docker image, one might believe this to be extremely expensive (in terms of hard drive space, network usage, etc.).  However once the Runtime image, common to all generated Components, is provisioned to the Docker-aware GPP, the small _delta_ of the derived Component image is the only part actually downloaded (which should be trivially small by comparison).


[traditional-technical-considerations]: ../1-traditional/README.md#technical-considerations
[docker-gpp]: https://github.com/GeonTech/core-framework/tree/docker-gpp
[docker-redhawk]: https://github.com/GeonTech/docker-redhawk
[docker-redhawk-ubuntu]: https://github.com/GeonTech/docker-redhawk-ubuntu
[gr-cc]: ../gr-component_converter/README.md
