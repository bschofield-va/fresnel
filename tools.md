# Tools

Fresnel provided tools support help with `-h` and `--help` options.
Consult each tool for usage details, except macOs work-alike tools.

```
dtk               Deployment Unit management
script-template   Generate a template for a new script
kibana-proxy      An HTTP over SOCKS proxy for API Gateway Kibana access
prs               Print interesting GitHub Pull Requests
repos             GitHub repository management
run-app           Build and run Java applications
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
