---
title: Paketo Node.js Buildpacks updates default to Node.js 24
date: "2026-01-08T12:32:49+01:00"
slug: default-version-bump-node-24
author: pacostas
---

**Node.js 24 entered active status** in October 2025 according to the Node.js [release schedule](https://nodejs.org/en/about/previous-releases).
We are excited to announce that it is now the default version for the [Paketo Node.js buildpacks](https://github.com/paketo-buildpacks/nodejs)!
This means that if no Node.js version is specified via the `package.json` file, `.node-version` file, `.nvmrc` file or through the `BP_NODE_VERSION` environment variable, the selected Node.js version will default to 24!

Although Node.js 24 has been available on Paketo Buildpacks since **November 4th, 2025**, via the [node-engine buildpack](https://github.com/paketo-buildpacks/node-engine/pull/1356), we had to ensure that all the Paketo Node.js buildpacks have been tested against it throught their testing suite, before setting it as default. This ensures that the current behavior of the Paketo Node.js Buildpacks implementation remains stable.

Aside from setting Node.js 24 as the default, nothing else has changed. Older versions of Node.js **will remain available**, even if they have reached End-Of-Life (EOL) status from the Node.js Project.

If you would like to **contribute to** the Node.js Buildpacks or the Paketo implementation of CNCF buildpacks in general, feel free to take a look on the community instructions on how to [get involved](https://github.com/paketo-buildpacks/community?tab=readme-ov-file#how-to-get-involved) or check out [this blog post on the topic](https://blog.paketo.io/posts/paketo-buildpacks-contributors-wanted/).

Happy building !!!
