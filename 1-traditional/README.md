# Traditional Integration

Traditionally, a Component requiring special libraries, beyond the standard installation, would be deployed with one or more shared library dependency(ies) which would ensure that REDHAWK installed the library(ies) at a GPP before loading and executing the Component.  Something like GNURadio which has a runtime engine requires a different approach.  

One possible path to support this traditional deployment mechanism is to pre-provision the GPP(s) with GNURadio and the associated `redhawk_integration_python` package by directly installing both, locally, to the GPP host.  Additionally, any end-user package dependencies for the associated Flow Graph would also need to be installed at each GPP.

## Why?

You might choose this route if you only have a single GPP to manage or not many Flow Graphs to integrate.  Such an environment greatly simplifies the provisioning issue since you only have to maintain a single system.  If you're maintaining multiple GPPs in your Domain, provisioning them can become an issue.

## How?

The steps are as direct as it sounds.  Wherever there is a Device Manager with a GPP that will be running in the Domain, install: 

1. GNURadio
2. Any support blocks/libraries required for the superset of the available Flow Graphs that may be deployed
3. `gr-redhawk_integration_python`

 > **Note:** You cannot use a mix of provisionings in this case unless you manually specify each GPP that will be running a specific Component-wrapped Flow Graph.

## Technical Considerations

This use case involves a standard GPP (i.e., from REDHAWK SDR's published RPM).  It has no additional (unique) allocable properties that might indicate the presence of GNURadio or other end-user GNURadio libraries.  Therefore, the deployment requires _all*_ GPPs be provisioned identically since the Component may be deployed to any of them.

 > Note: If you choose to replace a subset of GPPs, you will need to manually specify the target GPP, for the Flow Graph Components, during application deployment.

## Installation

In each of these cases, the user will need root-level permissions in order to install the Source and Sink blocks from the [integration package][gr-rip].

### On a GPP Host

Install the integration package:

```bash
make rip
make install-rip
```

 > Note: Please see [the note](#pybombs) about whether or not root permissions are required for installing the REDHAWK Integration Package (a.k.a., `rip`, above).

### On a Development Host

Install both the integration package and the conversion tool:

```bash
sudo make install-cc
make rip
make install-rip
```

 > Note: The Component Converter has nothing to compile, but does get installed in `OSSIEHOME`, hence you may need root-level permissions (thus, `sudo`, above).

 > Note: Please see [the note](#pybombs) about whether or not root permissions are required for installing the REDHAWK Integration Package (a.k.a., `rip`, above).

Then proceed to [component generation](#component-generation).

### Pybombs

If Pybombs is used for installation of GNURadio, please note verify you are installing a supported version for the REDHAWK Integration Package ([see here][gr-rip-reqs]).  

Compiling and installing the REDHAWK Integration Package, as well as running the REDHAWK GPP that may run GNURadio-integrated Components, requires first sourcing the Pybombs environment script so that its paths are available in the environment.

If your user does not have write access to the GNURadio installation, you will need to use `su` or some other means when installing the REDHAWK Integration Package (i.e., if owned by root, `sudo make install-rip`).

## Component Generation

Please see the [README.md][gr-cc] for more details on the converter's use cases and limitations.  The short form of usage is as follows:

```bash
# From gr-component_converter
./run.py path/user.grc [output_path]
```

 > Note: if not provided, `output_path` will be the current working directory.

The resulting `output_path` will have the Component, ready to install in the `SDRROOT/dom/components` location by running `build.sh install` from the system hosting the Domain's SDRROOT path.



 [gr-cc]: https://github.com/Geontech/gr-redhawk_integration_python/gr-component_converter/README.md
 [gr-rip]: https://github.com/Geontech/gr-redhawk_integration_python/blob/master/README.md
 [gr-rip-reqs]: https://github.com/Geontech/gr-redhawk_integration_python/blob/master/README.md#requirements