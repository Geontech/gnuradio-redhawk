# Docker-based GPP

This approach is similar to [Traditional][traditional] except that rather than running the GPP directly on the host, one uses the GPP image derived from [Docker-REDHAWK][docker-redhawk] to instantiate the GPP.  This approach carries with it many of the same provisioning issues but simplifies the deployment by way of a common Docker image

 > Note: Support is TBD.  Proceed at your own risk.

## Why?

This route is helpful if you have a host with Docker installed, but do not want to install GNURadio or REDHAWK directly on the host.  Instead, you can use it as a compute resource compatible with running your Flow Graph(s) as Components in Waveforms within a standard Domain.

## How?

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
   5. Script or other functionality to support running the GNURadio Companion (like the REDHAWK IDE, `rhide.sh`, script)

On any host where you want this GPP+GNURadio, run the related image connected back to a REDHAWK Domain (see the `gpp.sh` script for an example).

Development would follow the Traditional [component generation][traditional-component-generation] routine.  These Components will be compatible with the Traditional deployment as well with the same caveats related to deployment.

## Component Generation

Component generation is the same as [traditional][traditional-component-generation].

## Technical Considerations

As with [the traditional approach][traditional], this GPP is a standard GPP wrapped with a Docker container.  It is still subject to the same [Technical Considerations][traditional-technical-considerations].  The exception is that in this case, the GPP can execute from a system that only has Docker installed (no REDHAWK at all).

[traditional]: ../1-traditional/README.md
[traditional-component-generation]: ../1-traditional/README.md#component-generation
[traditional-technical-considerations]: ../1-traditional/README.md#technical-considerations
[docker-redhawk]: https://github.com/GeonTech/docker-redhawk