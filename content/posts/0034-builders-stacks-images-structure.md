---
title: What has changed on how we ship the Builders and the base images
date: "2025-10-20T23:25:07+02:00"
slug: builders-stacks-base-images-restructure
author: pacostas
---

## What has changed on how we ship the Builders and the base images

We recently finished implementing the [core builder RFC](https://github.com/paketo-buildpacks/rfcs/blob/main/text/0061-core-builder.md). This means quite a few changes across the Paketo Buildpacks organization, so we would like to walk you through the new structure (noble/UBI9) by comparing it with the old structure (jammy/UBI8) to highlight the differences.

## Changes to Base images (former stacks)

For Ubuntu Jammy, each repository publishes the build and the run image, as follows:

- [Jammy-full-stack](https://github.com/paketo-buildpacks/jammy-full-stack)

  1. docker.io/paketobuildpacks/build-jammy-full
  1. docker.io/paketobuildpacks/run-jammy-full

- [Jammy-base-stack](https://github.com/paketo-buildpacks/jammy-base-stack)

  1. docker.io/paketobuildpacks/build-jammy-base
  1. docker.io/paketobuildpacks/run-jammy-base

- [Jammy-tiny-stack](https://github.com/paketo-buildpacks/jammy-tiny-stack)

  1. docker.io/paketobuildpacks/build-jammy-tiny
  1. docker.io/paketobuildpacks/run-jammy-tiny

- [Jammy-static-stack](https://github.com/paketo-buildpacks/jammy-static-stack)

  1. docker.io/paketobuildpacks/build-jammy-static
  1. docker.io/paketobuildpacks/run-jammy-static

Following the new structure based on the [core builder RFC](https://github.com/paketo-buildpacks/rfcs/blob/main/text/0061-core-builder.md), all the images will be published from a single repository. For Ubuntu Noble this results in:

[Ubuntu-noble-base-images](https://github.com/paketo-buildpacks/ubuntu-noble-base-images)

1. docker.io/paketobuildpacks/ubuntu-noble-build
1. docker.io/paketobuildpacks/ubuntu-noble-run
1. docker.io/paketobuildpacks/ubuntu-noble-run-tiny
1. docker.io/paketobuildpacks/ubuntu-noble-run-static

The key differences between Noble and Jammy are:

- The repository inclues the `images` keyword instead of `stack`.
- There is only one build image.
- The `base` build and run image do not have the `base` keyword.
- The `full` run and build images have been deprecated.

There are no changes for the [UBI8-base-stack](https://github.com/paketo-buildpacks/ubi8-base-stack) and [UBI-9-base-images](https://github.com/paketo-buildpacks/ubi-9-base-images) repositories, except the name of the repositories, as the images are being published as they used to, preserving the same naming convention as before.

## Changes to Builders

In addition to base/stack images, we have also made changes to the builders.

So far for the Ubuntu Jammy and UBI8 builders, each builder is being published by a separate repository:

- [Builder-jammy-java-tiny](https://github.com/paketo-buildpacks/builder-jammy-java-tiny)

  1. docker.io/paketobuildpacks/builder-jammy-java-tiny

- [Builder-jammy-tiny](https://github.com/paketo-buildpacks/builder-jammy-tiny)

  1. docker.io/paketobuildpacks/builder-jammy-tiny

- [Builder-jammy-base](https://github.com/paketo-buildpacks/builder-jammy-base)

  1. docker.io/paketobuildpacks/builder-jammy-base

- [Builder-jammy-full](https://github.com/paketo-buildpacks/builder-jammy-full)

  1. docker.io/paketobuildpacks/builder-jammy-full

- [Builder-jammy-buildpackless-tiny](https://github.com/paketo-buildpacks/builder-jammy-buildpackless-tiny)

  1. docker.io/paketobuildpacks/builder-jammy-tiny

- [Builder-jammy-buildpackless-static](https://github.com/paketo-buildpacks/builder-jammy-buildpackless-static)

  1. docker.io/paketobuildpacks/builder-jammy-buildpackless-static

- [Builder-jammy-buildpackless-base](https://github.com/paketo-buildpacks/builder-jammy-buildpackless-base)

  1. docker.io/paketobuildpacks/builder-jammy-buildpackless-base

- [Builder-jammy-buildpackless-full](https://github.com/paketo-buildpacks/builder-jammy-buildpackless-full)

  1. docker.io/paketobuildpacks/builder-jammy-buildpackless-full

- [Builder-ubi8-base](https://github.com/paketo-buildpacks/builder-ubi8-base)

  1. docker.io/paketobuildpacks/builder-ubi8-base

- [Builder-ubi8-buildpackless-base](https://github.com/paketo-buildpacks/builder-ubi8-buildpackless-base)

  1. docker.io/paketobuildpacks/builder-ubi8-buildpackless-base

Based on the [core builder RFC](https://github.com/paketo-buildpacks/rfcs/blob/main/text/0061-core-builder.md) the structure of the repositories for the Ubuntu Noble buiders and UBI9 builders has changed to the following:

- [Ubuntu-noble-builder](https://github.com/paketo-buildpacks/ubuntu-noble-builder)

  1. docker.io/paketobuildpacks/ubuntu-noble-builder
  1. docker.io/paketobuildpacks/ubuntu-noble-builder-buildpackless

- [Builder-noble-java-tiny](https://github.com/paketo-buildpacks/builder-noble-java-tiny)

  1. docker.io/paketobuildpacks/builder-noble-java-tiny

- [Ubi-9-builder](https://github.com/paketo-buildpacks/ubi-9-builder)

  1. docker.io/paketobuildpacks/ubi-9-builder
  1. docker.io/paketobuildpacks/ubi-9-builder-buildpackless

What does this mean for you?

- If you are presently using the Jammy `paketobuildpacks/builder-jammy-base` builder, then you should switch to using the `paketobuildpacks/ubuntu-noble-builder` builder. This is a direct swap of the builder.

- If you are presently using the Jammy `paketobuildpacks/builder-jammy-java-tiny` builder then you will switch to `paketobuildpacks/builder-noble-java-tiny`. This one is a direct swap.

- If you are presently using the Jammy `paketobuildpacks/builder-jammy-tiny` builder (or the static builder), then you would switch to using the `paketobuildpacks/ubuntu-noble-builder` builder as well, but you would include the `--run-image` flag with your build command and specify `paketobuildpacks/ubuntu-noble-run-tiny` (or the `static` run image listed above) as your run image. This will use the base build image, but then create an application image based on the run image that you specify. If you are using a tool besides `pack` cli, check it's documentation. Most tools have a way to specify an alternative run image.

- If you are presently using the Jammy `paketobuildpacks/builder-jammy-full` builder, then you will need to switch to using the `paketobuildpacks/ubuntu-noble-builder` builder. This is going to be a more impactful change though, because we are not offering a full builder or full base images with Noble. What you need to do instead is to find what packages are required by your application, that are not available on the base image and use the [Apt buildpack](https://github.com/dmikusa/apt-buildpack) to install those packages so that they are available for your application. We believe that this should work for many users, but if you're having issues or perhaps have a use case that's not supported, please reach out on our [discussion page](https://github.com/orgs/paketo-buildpacks/discussions).

- If you are presently using the UBI 8 `paketobuildpacks/builder-ubi8-base` builder, then you can switch to using the `paketobuildpacks/ubi-9-builder` builder. This is a direct swap of the builder. With UBI builders, there is no need to select the run image, as the extension (which is included on the ubi builders), it always selects the optimal run image for you. However, if you would like to experiment with a different run image (for example during development), you can override it using the [BP_UBI_RUN_IMAGE_OVERRIDE](https://github.com/paketo-buildpacks/ubi-nodejs-extension?tab=readme-ov-file#setting-explicitly-a-run-image-bp_ubi_run_image_override) environment variable.

If you would like to contribute under the Paketo implementation of CNCF buildpacks, feel free to take a look on the community instructions on how to [get involved](https://github.com/paketo-buildpacks/community?tab=readme-ov-file#how-to-get-involved) or check out [this blog post on the topic](https://blog.paketo.io/posts/paketo-buildpacks-contributors-wanted/).

Happy building !!!
