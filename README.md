# GNURadio - REDHAWK Integration

GNURadio and REDHAWK SDR can be integrated in a number of ways.  In this repository, we provide options for various paths whereby REDHAWK can deploy a Flow Graph as a Component in a Waveform (application) into a REDHAWK Domain.  Each path makes use of the `gr-redhawk_integration_python` ([readme][1]) and `gr-component_converter` ([readme][2]) packages.

 > **Note:** You should clone this repository recursively as it contains submodules.

## 1. Traditional Integration <span id="traditional"></span>

Traditionally, a Component requiring special libraries, beyond the standard installation, would be deployed with one or more shared library dependency(ies) which would ensure that REDHAWK installed the library(ies) at a GPP before loading and executing the Component.  Something like GNURadio which has a runtime engine requires a different approach.  

One possible path to support this traditional deployment mechanism is to pre-provision the GPP(s) with GNURadio and the associated `redhawk_integration_python` package by directly installing each locally to the GPP host.  Additionally, any end-user package dependencies for the associated Flow Graph would also need to be installed at each GPP.

### Why?

You might choose this route if you only have a single GPP to manage or not many Flow Graphs to integrate.  Such an environment greatly simplifies the provisioning issue since you only have to maintain a single system.  If you're maintaining multiple GPPs in your Domain, provisioning them can become an issue.

### How?

The steps are as direct as it sounds.  Wherever there is a Device Manager with a GPP that will be running in the Domain, install: 

1. GNURadio
2. Any support blocks/libraries required for the superset of the available Flow Graphs that may be deployed
3. `gr-redhawk_integration_python`

 > **Note:** You cannot use a mix of provisionings in this case unless you manually specify each GPP that will be running a specific Component-wrapped Flow Graph.

### Component Generation <span id="traditional-component-generation"></span>

A developer's system environment must also include GNURadio and `gr-redhawk_integration_python` so that, once also installed, the `gr-component_converter` can function properly.  Please see the [README.md][2] for more details on the converter's use cases and limitations.


### Technical Considerations <span id="traditional-technical-considerations"></span>

This use case involves a standard GPP (i.e., from REDHAWK SDR's published RPM).  It has no additional (unique) allocable properties that might indicate the presence of GNURadio or other end-user GNURadio libraries.  Therefore, the deployment requires _all*_ GPPs be provisioned identically since the Component may be deployed to any of them.

 > Note: If you choose to replace a subset of GPPs, you will need to manually specify the target during application deployment.


## 2. Docker-based GPP <span id="docker-based"></span>

This approach is similar to [Traditional](#traditional) except that rather than running the GPP directly on the host, one uses the GPP image derived from [Docker-REDHAWK] to instantiate the GPP.  This approach carries with it many of the same provisioning issues but simplifies the deployment by way of a common Docker image

 > Note: Support is TBD.  Proceed at your own risk.

### Why?

This route is helpful if you have a host with Docker installed, but do not want to install GNURadio or REDHAWK directly on the host.  Instead, you can use it as a compute resource compatible with running your Flow Graph(s) as Components in Waveforms within a standard Domain.

### How?

The following steps are required to implement this:

1. Extend the Docker-REDHAWK GPP image to include:
   1. GNURadio
   2. Any support blocks/libraries required for the superset of the available Flow Graphs that may be deployed
   3. `gr-redhawk_integration_python`
2. Extend the Docker-REDHAWK Development image to include:
   1. GNURadio
   2. Any support blocks/libraries required for the superset of the available Flow Graphs that may be deployed
   3. `gr-redhawk_integration_python`
   4. `gr-component_converter`
   5. Script or other functionality to support running the GNURadio Companion (like the REDHAWK IDE, rhide.sh, script)

On any host where you want this GPP+GNURadio, run the related image connected back to a REDHAWK Domain (see the `gpp.sh` script for an example).

Development would follow the Traditional [component generation](#traditional-component-generation) routine.  These Components will be compatible with the Traditional deployment as well with the same caveats related to deployment.

### Component Generation

Component generation is the same as [traditional](#traditional-component-generation).

### Technical Considerations

As with [the traditional approach](#traditional), this GPP is a standard GPP wrapped with a Docker container.  It is still subject to the same [Technical Considerations](#traditional-technical-considerations).  The exception is that in this case, the GPP can execute from a system that only has Docker installed (no REDHAWK at all).


## 3. Docker-aware GPP <span id="docker-aware"></span>

In this approach, one replaces the standard GPP with [an extended version][3] that has been modified to permit calling on the Docker daemon at runtime.  This new GPP also includes additional, allocable properties that assist Flow Graph Components in being deployed specifically to these GPPs as well as executing the Component within its own, containerized runtime environment. 

 > Note: Support is TBD.  Proceed at your own risk.

### Why?

By utilizing this modified GPP, the generated Component can have additional deployment requirements (allocable properties) that assist REDHAWK in locating a GPP that has the Component's associated Docker image locally cached.  This means the [traditional](#traditional-technical-considerations) no longer apply since we're using more of the REDHAWK infrastructure and automation to our advantage.

**TBD:** In a future release of the [docker-gpp][3], the allocation properties for image locating will be replaced with `docker pull...` requests (vs. the current `docker inspect` check).  This will allow the GPP to dynamically load the Component's image in preparation for executing the Component's container.  This adds an extra layer of automatic provisioning via Docker that already exists for traditional Components. 

### How? <span id="docker-aware-how"></span>

The following modifications must take place:

1. Extend the [Docker-REDHAWK][4] Runtime image to be a new base image with:
   1. GNURadio
   2. `gr-redhawk_integration_python`
2. Extend this new image similar to the [Docker-REDHAWK][4] Development image definition, but also including:
   1. GNURadio
   2. `gr-redhawk_integration_python`
   3. `gr-component_converter`
   4. Script or other functionality to support running the GNURadio Companion (like the REDHAWK IDE, rhide.sh, script)

 > Note 1: In this scenario, there's no need to provision the two images with the end user's specific support libraries since each Component will have its own derived image for those needs.

 > Note 2: The Runtime and Development images can be derived from [Docker-REDHAWK-Ubuntu][5], which is currently based on Ubuntu 16.04, if that is your preference.

### Component Generation

Components generated using the [Component Converter][2] need the **TBD** flag set to generate a Docker-aware GPP -compatible implementation.  This will instantiate the allocable property relationships to ensure the Component is only ever executed on a Docker-aware GPP.

Recall, in this method, the GPP executes a Component within a Docker Container.  Therefore once the Component project is created, one must deploy a Docker image, derived from the above new Runtime image, that has the Component installed in the SDRROOT _of the image_.

Moreover, this Component also needs to be installed in the Domain's SDRROOT.  This will allow you to create Waveforms that reference the Component as well as allow the Domain to launch Waveforms containing this Component.

### Technical Considerations <span id="docker-aware-technical-considerations"></span>

Since every Component has its own Docker image, one might believe this to be extremely expensive (in terms of hard drive space, network usage, etc.).  However once the Runtime image, common to all generated Components, is provisioned to the Docker-aware GPP, the small _delta_ of the derived Component image is the only part actually downloaded (which should be trivially small by comparison).


## 4. Docker-in-Docker -aware GPP

This approach is similar to [#3] except that the runtime environment of the modified GPP is within its own Docker Container.  That Docker Container is linked to a `docker:dind` Container to allow the GPP's Docker instance to control its own host's Docker daemon.  In so doing, the GPP can launch and manage a Component's unique Container from within in _the GPP's own Container_

### Why?

Easily the most complex configuration, it combines the benefits of [#2](#docker-based) and [#3](#docker-aware) by using the Docker-in-Docker approach.  At the top-level then, the host for this deployment is only required to have Docker and network access to the REDHAWK Domain.

The concept wraps the Docker-aware GPP in its own Docker image.  This reetains the unique properties necessary for locating the extended GPP while removing the host burden of having REDHAWK or GNURadio installed.  When the Domain launches a Waveform, it follows the [#3](#docker-aware) path and verifies provisioning before having the GPP execute the Component within its own individual runtime container.

 > Note: Support is TBD.  Proceed at your own risk.

### How?

The Runtime and Development images requirements are identical to [#3](#docker-aware-how).  An additional image must be created to extend the [Docker-REDHAWK][4] Runtime image to install the modified [docker-gpp][3] with the same features as the [Docker-REDHAWK][4] GPP image (i.e., you can re-use the init script, supervisord, etc.  Just compile and install the Device from source).  The final consideration is running the `docker:dind` container as a daemon, privileged, and linked to your GPP container (`--link` and `-v` for the `/var/lib/docker` path).

### Technical Considerations

**TBD:** Once the modified GPP is extended to support installing (`docker pull`) Component images during load, this method will perhaps sacrifice a small performance degredation for an extremely flexible means of deploying REDHAWK compute resources across a Docker cloud/swarm where no REDHAWK (or GNURadio) is installed.  Until then, this route still has the same provisioning issues as [#3](#docker-aware) where the base image and Component images all need to be manually loaded at the host.


[1]: ./gr-redhawk_integration_python/README.md
[2]: ./gr-component_converter/README.md
[3]: https://github.com/GeonTech/core-framework/tree/docker-gpp
[4]: https://github.com/GeonTech/docker-redhawk
[5]: https://github.com/GeonTech/docker-redhawk-ubuntu