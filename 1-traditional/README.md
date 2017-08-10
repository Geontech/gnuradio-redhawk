# Traditional Integration

Traditionally, a Component requiring special libraries, beyond the standard installation, would be deployed with one or more shared library dependency(ies) which would ensure that REDHAWK installed the library(ies) at a GPP before loading and executing the Component.  Something like GNURadio which has a runtime engine requires a different approach.  

One possible path to support this traditional deployment mechanism is to pre-provision the GPP(s) with GNURadio and the associated `redhawk_integration_python` package by directly installing each locally to the GPP host.  Additionally, any end-user package dependencies for the associated Flow Graph would also need to be installed at each GPP.

## Why?

You might choose this route if you only have a single GPP to manage or not many Flow Graphs to integrate.  Such an environment greatly simplifies the provisioning issue since you only have to maintain a single system.  If you're maintaining multiple GPPs in your Domain, provisioning them can become an issue.

## How?

The steps are as direct as it sounds.  Wherever there is a Device Manager with a GPP that will be running in the Domain, install: 

1. GNURadio
2. Any support blocks/libraries required for the superset of the available Flow Graphs that may be deployed
3. `gr-redhawk_integration_python`

 > **Note:** You cannot use a mix of provisionings in this case unless you manually specify each GPP that will be running a specific Component-wrapped Flow Graph.

## Component Generation

A developer's system environment must also include GNURadio and `gr-redhawk_integration_python` so that, once also installed, the `gr-component_converter` can function properly.  Please see the [README.md][gr-cc] for more details on the converter's use cases and limitations.


## Technical Considerations

This use case involves a standard GPP (i.e., from REDHAWK SDR's published RPM).  It has no additional (unique) allocable properties that might indicate the presence of GNURadio or other end-user GNURadio libraries.  Therefore, the deployment requires _all*_ GPPs be provisioned identically since the Component may be deployed to any of them.

 > Note: If you choose to replace a subset of GPPs, you will need to manually specify the target during application deployment.


 [gr-cc]: ../gr-component_converter/README.md