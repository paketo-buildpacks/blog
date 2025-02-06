---
title: Paketo UBI stack moving to paketo-buildpacks from paketo-community
date: "2025-02-15"
slug: paketo-ubi-stack-move-from-community-to-buildpacks
author: mhdawson
---

The Paketo community has been working on [UBI](https://www.redhat.com/en/blog/introducing-red-hat-universal-base-image)
support over the last few years after agreeing on the direction in
[0056-ubi-based-stacks.md](https://github.com/paketo-buildpacks/rfcs/blob/main/text/0056-ubi-based-stacks.md).

Typically suport for new components starts in the
[paketo-community](https://github.com/paketo-community) organization and then is moved to the
[paketo-buildpacks](https://github.com/paketo-buildpacks) organization once it matures.

It's now time to move the [ubi-base-stack](https://github.com/paketo-community/ubi-base-stack) over
to the packet-buildpacks organization.

We are publishing this blog post because this will impact users who have been specifying the stack container
images on the command line or in their toml files (we expect this is a small number). If you are
using the builders no changes are needed yet, we'll let you know when they are moved over.
For those using the builders, you can continue to follow the instructions in
[Build applications with Paketo Buildpacks and Red Hat UBI container images](https://developers.redhat.com/articles/2024/06/18/build-applications-paketo-buildpacks-and-red-hat-ubi-container-images).

If you have specified the build or run container images specifically you will need to move from the following
container images:

* paketocommuntiy/build-ubi-base
* paketocommuntiy/run-ubi-base
* paketocommunity/run-nodejs-16-ubi-base
* paketocommunity/run-nodejs-18-ubi-base
* paketocommunity/run-nodejs-20-ubi-base
* paketocommunity/run-java-8-ubi-base
* paketocommunity/run-java-11-ubi-base
* paketocommunity/run-java-17-ubi-base
* paketocommunity/run-java-21-ubi-base

over to:

* paketobuildpacks/build-ubi-base
* paketobuildpacks/run-ubi-base
* paketobuildpacks/run-nodejs-16-ubi-base
* paketobuildpacks/run-nodejs-18-ubi-base
* paketobuildpacks/run-nodejs-20-ubi-base
* paketobuildpacks/run-java-8-ubi-base
* paketobuildpacks/run-java-11-ubi-base
* paketobuildpacks/run-java-17-ubi-base
* paketobuildpacks/run-java-21-ubi-base


That's it. We'll let you know when the builders move over and until then let us know if you
have any questions.
