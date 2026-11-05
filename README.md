# Valenor Studio · version feed

Public version list for Valenor Studio RedM resources. Every Valenor release ships a small
server-side `versionChecker.lua` that reads [`versions.json`](versions.json) and, when your copy is
older than the latest release, prints a notice in the server console at start and then every hour:

```
==============================================================
  VALENOR STUDIO  |  v-example is outdated
  Installed: 1.0.0    Latest: 1.0.1
  What is new:
    - ...
  Please download the update from the Cfx.re Portal: https://portal.cfx.re/assets/granted-assets
==============================================================
```

**Updating:** download the new version from the
[Cfx.re Portal → Granted Assets](https://portal.cfx.re/assets/granted-assets) and replace the resource folder.

The checker only sends one GET request to `raw.githubusercontent.com` (no server data, no keys).
This repository is maintained automatically by Valenor's release tool; please do not open pull requests.

Support: [discord.gg/valenorstudio](https://discord.gg/valenorstudio)
