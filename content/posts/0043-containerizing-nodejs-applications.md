---
title: Containerizing and Optimizing Node.js Applications with Paketo Buildpacks
date: "2026-08-21T14:48:19+02:00"
slug: containerizing-nodejs-apps
author: pacostas
---

Recently we introduced Ubuntu Noble and Resolute builders, which change how we containerize applications.
This post shows how to containerize and optimize a **Node.js** application with Paketo Buildpacks on Ubuntu and Red Hat Universal Base Image (UBI) builders.

#### Prerequisites:

- [Pack CLI](https://buildpacks.io/docs/for-platform-operators/how-to/integrate-ci/pack/#install)
- [Podman](https://podman.io/docs/installation) or [Docker](https://docs.docker.com/engine/install/). If you use Podman, follow the [build-on-Podman instructions](https://buildpacks.io/docs/for-app-developers/how-to/special-cases/build-on-podman/).
- [git](https://git-scm.com/install/)

You also need a Node.js application. If you do not have one, clone the Paketo Buildpacks samples repository:

```sh
git clone https://github.com/paketo-buildpacks/samples
```

## Containerize with Ubuntu Noble builders

With buildpacks, it is as simple as this command:

```sh
pack build noble-nodejs-container-image \
    --path samples/nodejs/npm \
    --builder paketobuildpacks/ubuntu-noble-builder
```

After a successful build, the logs should include:

```
Successfully built image noble-nodejs-container-image
```

Run the application with `docker` or `podman`:

```sh
docker run -d --rm --name noble-nodejs-container -p 8080:8080 noble-nodejs-container-image
```

Validate that the application responds with `curl`, or open the URL in a browser:

```sh
curl http://localhost:8080
```

Stop and remove the container:

```sh
docker stop noble-nodejs-container
```

In practice, `Pack` used the Noble builder’s image to build the app, then places the result on the builder’s default `run` image. The Noble [builder.toml](https://github.com/paketo-buildpacks/ubuntu-noble-builder/blob/main/builders/builder/builder.toml) specifies the default run image like this:

```toml
  [[run.images]]
    image = "docker.io/paketobuildpacks/ubuntu-noble-run:latest"
```

What if you want to optimize your app, by choosing a smaller run image, such as `ubuntu-noble-run-tiny` instead of the default `paketobuildpacks/ubuntu-noble-run`?

**Note:** See the [full list](https://github.com/paketo-buildpacks/ubuntu-noble-base-images/releases) of available Ubuntu Noble `run` and builder images.

You can either create a new builder that defaults to `paketobuildpacks/ubuntu-noble-run-tiny`, or pass `--run-image` at build time. The second option is much easier:

```sh
pack build noble-nodejs-container-image-optimized \
    --path samples/nodejs/npm \
    --builder paketobuildpacks/ubuntu-noble-builder \
    --run-image paketobuildpacks/ubuntu-noble-run-tiny
```

Run the application (omitting `-d`) to view the logs:

```sh
docker run --rm --name nodejs-container-optimized -p 8080:8080 noble-nodejs-container-image-optimized
```

You'll see it immediately crash with this error:

```
ERROR: failed to launch: path lookup: exec: "sh": executable file not found in $PATH
```

Why this happens: The `tiny` run image does not have a shell, which npm start [script](https://github.com/paketo-buildpacks/npm-start/blob/main/constants.go) relies on by default.

We can bypass the shell by using the [tini buildpack](https://github.com/paketo-buildpacks/tini). Since `tini` doesn't evaluate shell syntax (like && or echo), first simplify the start script in your samples/nodejs/npm/package.json:

```json
"start": "node server.js"
```

Then, rebuild the image using the `BP_LAUNCH_WITH_TINI` variable:

```sh
pack build noble-nodejs-container-image-optimized \
    --path samples/nodejs/npm \
    --builder paketobuildpacks/ubuntu-noble-builder \
    --run-image paketobuildpacks/ubuntu-noble-run-tiny \
    --env BP_LAUNCH_WITH_TINI=true
```

Run the optimized image:

```sh
docker run -d --rm --name nodejs-container-optimized -p 8080:8080 noble-nodejs-container-image-optimized
```

Validate that the application responds:

```sh
curl http://localhost:8080
```

Stop and remove the container:

```sh
docker stop nodejs-container-optimized
```

Comparing the two images shows a reduction of about **92 MB**:

```sh
docker image ls | grep noble-nodejs-container-image
```

| Image                                         | ID           | Disk Usage |
| --------------------------------------------- | ------------ | ---------- |
| noble-nodejs-container-image-optimized:latest | f5f8b343a7d6 | 304MB      |
| noble-nodejs-container-image:latest           | 6778f8ce70a2 | 396MB      |

## Containerize with Ubuntu Jammy builders

The same pattern works on Jammy builders. Keep the simplified `scripts.start` from the Noble section (`node server.js`), then build:

```sh
pack build jammy-base-build-tiny-run-nodejs-container-image \
    --path samples/nodejs/npm \
    --builder paketobuildpacks/builder-jammy-base \
    --run-image paketobuildpacks/run-jammy-tiny \
    --env BP_LAUNCH_WITH_TINI=true
```

Run the application:

```sh
docker run -d --rm --name jammy-nodejs-container-optimized -p 8080:8080 jammy-base-build-tiny-run-nodejs-container-image
```

Validate that the application responds:

```sh
curl http://localhost:8080
```

Stop and remove the container:

```sh
docker stop jammy-nodejs-container-optimized
```

**Note:** Jammy has a tiny builder, but this command fails because that builder does not include the Node.js buildpacks:

```sh
pack build jammy-base-nodejs-container-image \
    --path samples/nodejs/npm \
    --builder paketobuildpacks/builder-jammy-tiny
```

```
ERROR: No buildpack groups passed detection.
```

So in the first Jammy example, we build with the base Jammy builder and use the tiny builder’s run image.

Available Jammy base images:

- [Jammy full](https://github.com/paketo-buildpacks/jammy-full-stack/releases)
- [Jammy base](https://github.com/paketo-buildpacks/jammy-base-stack/releases)
- [Jammy tiny](https://github.com/paketo-buildpacks/jammy-tiny-stack/releases)
- [Jammy static](https://github.com/paketo-buildpacks/jammy-static-stack/releases)

The following table compares results from building with the `full` and `base` builders, with and without `--run-image` pointing at the tiny run image:

| Image                                                           | ID           | Disk Usage |
| --------------------------------------------------------------- | ------------ | ---------- |
| jammy-**full**-build-**full**-run-nodejs-container-image:latest | 1b0396b30edf | 996MB      |
| jammy-**full**-build-**tiny**-run-nodejs-container-image:latest | 3199d20d41bd | 304MB      |
| jammy-**base**-build-**base**-run-nodejs-container-image:latest | 57d2525236ab | 390MB      |
| jammy-**base**-build-**tiny**-run-nodejs-container-image:latest | 3199d20d41bd | 304MB      |

You might notice the following:

1. Image size drops by about **~692 MB** on the full builder and **~92 MB** on the base builder. Both tiny-run outputs are the same size.
1. Those two tiny-run images share the same ID, so the final app image is **exactly** the same whether you used the `full` or `base` builder.

**So why offer different builders if the output can match?**

Sometimes the build needs more packages than usual, for example compiling an npm package with native modules. The base builder does not include Python, so that compilation fails. The full builder provides Python, so the build succeeds.

This example fails because Python is not available during the build:

```sh
pack build jammy-base-build-tiny-run-nodejs-container-image \
    --path samples/nodejs/npm-with-native-modules \
    --builder paketobuildpacks/builder-jammy-base \
    --run-image paketobuildpacks/run-jammy-tiny
```

```
npm error gyp ERR! stack Error: Could not find any Python installation to use
```

The full builder succeeds because its build image provides Python:

```sh
pack build jammy-nodejs-container-image-with-native-full \
    --path samples/nodejs/npm-with-native-modules \
    --builder paketobuildpacks/builder-jammy-full \
    --run-image paketobuildpacks/run-jammy-tiny \
    --env BP_LAUNCH_WITH_TINI=true
```

Paketo Buildpacks for the Noble and later Builders, decided to deprecaate the full builder, therefore, we have to use the `BP_NPM_INCLUDE_BUILD_PYTHON` env variable, to provide Python during build:

```sh
pack build noble-nodejs-container-image-with-native-base \
    --path samples/nodejs/npm-with-native-modules \
    --builder paketobuildpacks/ubuntu-noble-builder \
    --run-image paketobuildpacks/ubuntu-noble-run-tiny \
    --env BP_LAUNCH_WITH_TINI=true \
    --env BP_NPM_INCLUDE_BUILD_PYTHON=true
```

You can use the same approach on the Jammy base builder:

```sh
pack build jammy-nodejs-container-image-with-native-base \
    --path samples/nodejs/npm-with-native-modules \
    --builder paketobuildpacks/builder-jammy-base \
    --run-image paketobuildpacks/run-jammy-tiny \
    --env BP_LAUNCH_WITH_TINI=true \
    --env BP_NPM_INCLUDE_BUILD_PYTHON=true
```

That way you avoid downloading the full Jammy builder, we use less disk space, and builds start faster because the full builder takes longer to download.

## Containerize with Ubuntu Resolute builders

All the aforementioned applies for the Resolute Builders too:

```sh
pack build resolute-nodejs-container-image \
    --path samples/nodejs/npm-with-native-modules \
    --builder paketobuildpacks/ubuntu-resolute-builder \
    --run-image paketobuildpacks/ubuntu-resolute-run-tiny \
    --env BP_LAUNCH_WITH_TINI=true \
    --env BP_NPM_INCLUDE_BUILD_PYTHON=true
```

- `--run-image` — use a tiny run image to reduce final image size
- `BP_LAUNCH_WITH_TINI=true` — required on tiny so the app can start and signals are forwarded
- `BP_NPM_INCLUDE_BUILD_PYTHON=true` — set only when the app builds native modules

Run the application:

```sh
docker run -d --rm --name resolute-nodejs-container -p 8080:8080 resolute-nodejs-container-image
```

Validate that the application responds:

```sh
curl http://localhost:8080
```

Stop and remove the container:

```sh
docker stop resolute-nodejs-container
```

**Note:** See the [full list](https://github.com/paketo-buildpacks/ubuntu-resolute-base-images/releases) of available Ubuntu Resolute `run` and `build` images.

## Containerize with UBI builders

For background on UBI 9 and UBI 10 builders, see [Containerize your Node.js applications with Red Hat UBI 9 & 10 Builders](https://blog.paketo.io/posts/ubi-9-and-10-builders-available).

With UBI builders you do not need the `--run-image` or tini setup above. UBI builders use an extension (another kind of buildpack) that selects the final run image by itself. Their build images also provide Python by default during build.

#### UBI 8

```sh
pack build container-image-nodejs-ubi8 \
    --path samples/nodejs/npm \
    --builder docker.io/paketobuildpacks/builder-ubi8-base
```

**Note:** Related repository: [paketo-buildpacks/builder-ubi8-base](https://github.com/paketo-buildpacks/builder-ubi8-base)

#### UBI 9

```sh
pack build container-image-nodejs-ubi9 \
    --path samples/nodejs/npm \
    --builder docker.io/paketobuildpacks/ubi-9-builder
```

**Note:** Related repository: [paketo-buildpacks/ubi-9-builder](https://github.com/paketo-buildpacks/ubi-9-builder)

#### UBI 10

```sh
pack build container-image-nodejs-ubi10 \
    --path samples/nodejs/npm \
    --builder docker.io/paketobuildpacks/ubi-10-builder
```

**Note:** Related repository: [paketo-buildpacks/ubi-10-builder](https://github.com/paketo-buildpacks/ubi-10-builder)

Run any of the images you built. For example, the UBI 10 image:

```sh
docker run -d --rm --name container-nodejs-ubi10 -p 8080:8080 container-image-nodejs-ubi10
```

Validate that the application responds:

```sh
curl http://localhost:8080
```

Stop and remove the container:

```sh
docker stop container-nodejs-ubi10
```

Optionally, on any UBI builder, start the app with tini instead of the default launch script. Keep `scripts.start` as a single command such as `node server.js` (same as the Noble tiny section):

```sh
pack build container-image-nodejs-ubi10-tini \
    --path samples/nodejs/npm \
    --builder docker.io/paketobuildpacks/ubi-10-builder \
    --env BP_LAUNCH_WITH_TINI=true
```

Run, validate, and stop that image the same way, using `container-image-nodejs-ubi10-tini` as the image name.

`--run-image` does not change the run image for UBI builds. To force a different run image, set `BP_UBI_RUN_IMAGE_OVERRIDE`. That variable exists for testing (for example in integration tests) and is not intended for production use.

**Note:** The following example is for demonstration only. Do not use it in production: it builds an app on UBI 8 and runs it on UBI 10, which can produce an unstable runtime.

```sh
pack build container-nodejs-image-build-ubi8-run-ubi10 \
    --path samples/nodejs/npm \
    --builder docker.io/paketobuildpacks/builder-ubi8-base \
    --env BP_UBI_RUN_IMAGE_OVERRIDE="docker.io/paketobuildpacks/ubi-10-run-nodejs-24-base"
```

Run the application:

```sh
docker run -d --rm --name container-nodejs-build-ubi8-run-ubi10 -p 8080:8080 container-nodejs-image-build-ubi8-run-ubi10
```

Validate that the application responds:

```sh
curl http://localhost:8080
```

Stop and remove the container:

```sh
docker stop container-nodejs-build-ubi8-run-ubi10
```

## Conclusion

On this blog post we covered:

- Building Node.js apps across various Ubuntu (Jammy, Resolute, Noble) and UBI (8, 9, 10) builders.
- Optimizing container sizes by setting in a `tiny` run image using `--run-image`.
- Managing processes with `BP_LAUNCH_WITH_TINI=true` for proper signal handling and shell-less execution on `tiny` images.
- Supporting native modules builds on newer Ubuntu builders by enabling Python at build time with `BP_NPM_INCLUDE_BUILD_PYTHON=true`.
- Leveraging UBI builders, which automatically handle run image selection and include Python by default.

## Contributing

If you would like to contribute to the Paketo implementation of Cloud Native Computing Foundation (CNCF) buildpacks, see the community [get involved](https://github.com/paketo-buildpacks/community?tab=readme-ov-file#how-to-get-involved) guide or [this blog post on contributing](https://blog.paketo.io/posts/paketo-buildpacks-contributors-wanted/).

Happy building!
