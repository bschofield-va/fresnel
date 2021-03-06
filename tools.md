# Tools

Fresnel provided tools support help with `-h` and `--help` options.
Consult each tool for usage details, except macOs work-alike tools.

```
deployment-status Print deployment status for applications in the DVP environment
dtk               Deployment Unit management
kibana-proxy      An HTTP over SOCKS proxy for API Gateway Kibana access
mrs               Print maintenance requests
prs               Print interesting GitHub Pull Requests
repos             GitHub repository management
run-app           Build and run Java applications
script-template   Generate a template for a new script
secrets           Manage development secrets
```


## Host-bin Tools

Fresnel provided tools that run on the host, but made accessible to
containerized environment. Host-bin tools require a certain level
of compatibility on the host, e.g. host-bin tools written for macOs
cannot run on Windows.

```
bah               Booz Allen Hamilton related tools
```


## macOs Work-alike Tools

Work-alike tools require special configuration. See [README.md]

```
open / xdg-open
pbcopy
pbpaste
```
