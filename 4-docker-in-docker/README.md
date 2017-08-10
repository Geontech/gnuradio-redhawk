# Docker-in-Docker -aware GPP

This approach is similar to [#3][docker-aware] except that the runtime environment of the modified GPP is within its own Docker Container.  That Docker Container is linked to a `docker:dind` Container to allow the GPP's Docker instance to control its own host's Docker daemon.  In so doing, the GPP can launch and manage a Component's unique Container from within in _the GPP's own Container_

## Why?

Easily the most complex configuration, it combines the benefits of [#2][docker-based] and [#3][docker-aware] by using the Docker-in-Docker approach.  At the top-level then, the host for this deployment is only required to have Docker and network access to the REDHAWK Domain.

The concept wraps the Docker-aware GPP in its own Docker image.  This reetains the unique properties necessary for locating the extended GPP while removing the host burden of having REDHAWK or GNURadio installed.  When the Domain launches a Waveform, it follows the [#3][docker-aware] path and verifies provisioning before having the GPP execute the Component within its own individual runtime container.

 > Note: Support is TBD.  Proceed at your own risk.

## How?

The Runtime and Development images requirements are identical to [#3][docker-aware-how].  An additional image must be created to extend the [Docker-REDHAWK][docker-redhawk] Runtime image to install the modified [docker-gpp][docker-gpp] with the same features as the [Docker-REDHAWK][docker-redhawk] GPP image (i.e., you can re-use the init script, supervisord, etc.  Just compile and install the Device from source).  The final consideration is running the `docker:dind` container as a daemon, privileged, and linked to your GPP container (`--link` and `-v` for the `/var/lib/docker` path).

## Technical Considerations

**TBD:** Once the modified GPP is extended to support installing (`docker pull`) Component images during load, this method will perhaps sacrifice a small performance degredation for an extremely flexible means of deploying REDHAWK compute resources across a Docker cloud/swarm where no REDHAWK (or GNURadio) is installed.  Until then, this route still has the same provisioning issues as [#3][docker-aware] where the base image and Component images all need to be manually loaded at the host.


[docker-based]: ../2-docker-based/README.md
[docker-aware]: ../3-docker-aware/README.md
[docker-aware-how]: ../3-docker-aware/README.md#how
[docker-gpp]: https://github.com/GeonTech/core-framework/tree/docker-gpp
[docker-redhawk]: https://github.com/GeonTech/docker-redhawk

