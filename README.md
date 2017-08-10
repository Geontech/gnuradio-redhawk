# GNURadio - REDHAWK Integration

 > **Note:** You should clone this repository recursively as it contains submodules.

First: welcome!  You may have seen or heard about this project at the GNURadio Convention 2017 (GRCon 2017).  If you have and want to get involved in the project, please see [Contributions](#contributions).

GNURadio and REDHAWK SDR can be integrated in a number of ways.  In this repository, we provide options for various paths whereby REDHAWK can deploy a Flow Graph as a Component in a Waveform (application) into a REDHAWK Domain.  Each path makes use of the `gr-redhawk_integration_python` ([readme][1]) and `gr-component_converter` ([readme][2]) packages.

## Special Thanks

A very special thanks to Drew Cormier and Chris Conover of Geon Technologies, LLC, for their invaluable kick-start efforts that resulted in the `gr-redhawk_integration_python` and `gr-component_converter` packages.

## Getting Started

Please see the associated deployment method for more information:

 1. [Traditional](1-traditional/README.md)
 2. [Docker-Based](2-docker-based/README.md)
 3. [Docker-Aware](3-docker-aware/README.md)
 4. [Docker-in-Docker](4-docker-in-docker/README.md)

 > **Note:** Not all deployment methods are supported at this time.  The Why/How are provided in lieu of an implementation in the event there is an interested party wanting to jump straight into enabling a deployment path.

## Contributions

This is a community effort.  Contributions are always welcome.  Please see the Milestones and Issues lists to see what needs work and where the team sees this project heading.  Please feel free to fork and submit pull requests.

Or, if you're interested in joining in the development of this capability as a contributor, please contact the team through this repository's contact information.


[gr-rip]: ./gr-redhawk_integration_python/README.md
[gr-cc]: ./gr-component_converter/README.md
[docker-gpp]: https://github.com/GeonTech/core-framework/tree/docker-gpp
[docker-redhawk]: https://github.com/GeonTech/docker-redhawk
[docker-redhawk-ubuntu]: https://github.com/GeonTech/docker-redhawk-ubuntu
