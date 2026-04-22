---
title: Containerize your Node.js applications with Red Hat UBI 9 & 10 Builders
date: "2026-04-21T16:27:10+02:00"
slug: ubi-9-and-10-builders-available
author: pacostas
---

Over the past year, builders based on [Universal Base Image (UBI)](https://www.redhat.com/en/blog/introducing-red-hat-universal-base-image) 9 and UBI 10 have been published to Paketo Buildpacks. You can build applications on Red Hat Enterprise Linux (RHEL) 9 and RHEL 10 using Paketo buildpacks.

In this post we show where those builders live on GitHub and Docker Hub, and we build a sample Node.js application with the UBI 9 and UBI 10 builders.

## Repositories and container images

### For UBI 9

All UBI 9 builder source code lives in [github.com/paketo-buildpacks/ubi-9-builder](https://github.com/paketo-buildpacks/ubi-9-builder). Published images on Docker Hub are:

- `paketobuildpacks/ubi-9-builder` (includes the buildpacks and extensions needed to build an application; currently only Node.js is supported)
- `paketobuildpacks/ubi-9-builder-buildpackless` (no buildpacks included)

You can find the base images that each builder uses in the [release notes](https://github.com/paketo-buildpacks/ubi-9-base-images/releases) of the [ubi-9-base-images](https://github.com/paketo-buildpacks/ubi-9-base-images) repository.

### For UBI 10

UBI 10 follows the same pattern: builder source code is in [github.com/paketo-buildpacks/ubi-10-builder](https://github.com/paketo-buildpacks/ubi-10-builder), and published images are on Docker Hub:

- `paketobuildpacks/ubi-10-builder` (includes the buildpacks and extensions needed to build an application; currently only Node.js is supported)
- `paketobuildpacks/ubi-10-builder-buildpackless` (no buildpacks included)

[UBI 10 base images](https://github.com/paketo-buildpacks/ubi-10-base-images) are listed in the ubi-10-builder [release notes](https://github.com/paketo-buildpacks/ubi-10-builder/releases).

## Build a Node.js application with Podman/Docker and UBI 9 or 10 builders

We assume the host operating system is Fedora Linux; the steps are the same on other supported OSes, and links are included where installation differs.

Before we build our application, we want to ensure the following tools are installed and configured. The instructions for configuring Podman where we describe below, are based on the [instructions](https://buildpacks.io/docs/for-app-developers/how-to/special-cases/build-on-podman/) from the Cloud Native Buildpacks (CNB) project.

### Installing and configuring Podman

Use Podman version 5.1.0 or newer.

**Note:** To install Podman on another OS, follow the [Podman installation instructions](https://podman.io/docs/installation).

Expose the service using systemd:

```
systemctl enable --user podman.socket
systemctl start --user podman.socket
```

Route the Docker CLI to Podman:

```
export DOCKER_HOST="unix://$(podman info -f "{{.Host.RemoteSocket.Path}}")"
```

#### Installing Docker

If you use Docker Engine instead of Podman, install it from the [Docker Engine install documentation](https://docs.docker.com/engine/install/). No further configuration is needed beyond what that documentation describes.

### Installing and configuring Pack CLI

On Fedora:

```
dnf install pack
```

**Note:** To install the Pack CLI on another OS, follow the CNB project instructions under [Install pack](https://buildpacks.io/docs/for-platform-operators/how-to/integrate-ci/pack/#install).

Enable experimental options in the Pack CLI when using UBI builders; the Node.js extension is still experimental.

```
pack config experimental true
```

### Building a Node.js application

You need a builder and an application. This walkthrough uses the Paketo samples repo; any Node.js application will work.

```
git clone https://github.com/paketo-buildpacks/samples
```

Build with `pack` and the UBI 9 builder:

```
pack --docker-host=inherit build nodejs-app \
--builder index.docker.io/paketobuildpacks/ubi-9-builder \
--path ./samples/nodejs/npm
```

To use the UBI 10 builder instead, pass `--builder index.docker.io/paketobuildpacks/ubi-10-builder`.

When the build finishes, the logs should include:

```
Successfully built image nodejs-app
```

You should then see your Node.js app image in your Podman or Docker image list.

Run the application with Podman

```
podman run -d -p 8080:8080 nodejs-app`
```
or Docker (pick one) 

```
docker run -d -p 8080:8080 nodejs-app`
```

Verify the application responds:

```
curl http://localhost:8080
```

If you receive `HTTP/1.1 200 OK`, the application is running.

## Conclusion

If you would like to contribute under the Paketo implementation of CNCF buildpacks, feel free to take a look on the community instructions on how to [get involved](https://github.com/paketo-buildpacks/community?tab=readme-ov-file#how-to-get-involved) or check out [this blog post on the topic](https://blog.paketo.io/posts/paketo-buildpacks-contributors-wanted/).

Happy building!