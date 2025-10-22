---
title: What has changed on how we ship the Builders and the base images
date: "2025-10-20T23:25:07+02:00"
slug: builders-stacks-base-images-restructure
author: pacostas
---

## What has changed on how we ship the Builders and the base images.

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

As you may notice:

- We have 5 builders instead of 10.
- We have 3 repositories instead of 10.
- The naming convention of the builders has slighty changed to include the name of the Operating System.

We hope this explanation makes things clear enough on how the structure of the builders and the base images has changed.

If you would like to contribute under the Paketo implementation of CNCF buildpacks, feel free to take a look on the community instructions on how to [get involved](https://github.com/paketo-buildpacks/community?tab=readme-ov-file#how-to-get-involved) or check out [this blog post on the topic](https://blog.paketo.io/posts/paketo-buildpacks-contributors-wanted/).

Happy building !!!
