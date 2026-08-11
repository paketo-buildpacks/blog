---
title: Ubuntu 26.04 LTS (Resolute Raccoon) builders are available on Paketo
date: "2026-08-06T15:48:32+02:00"
slug: ubuntu-26.04-resolute-raccoon-on-paketo-buildpacks
author: pacostas
---

You can now build applications with Paketo builders based on Ubuntu 26.04 Long Term Support (LTS), also known as Resolute Raccoon.

Builder source and images live in the [ubuntu-resolute-builder repository](https://github.com/paketo-buildpacks/ubuntu-resolute-builder). See the [releases page](https://github.com/paketo-buildpacks/ubuntu-resolute-builder/releases) for published tags.

Available builders:

- `paketobuildpacks/ubuntu-resolute-builder` (includes buildpacks for Java, Node.js etc.)
- `paketobuildpacks/ubuntu-resolute-builder-buildpackless` (no buildpacks included)

These builders can create application images based on the [Ubuntu Resolute run images](https://github.com/paketo-buildpacks/ubuntu-resolute-base-images). Published run images are listed on the [releases page](https://github.com/paketo-buildpacks/ubuntu-resolute-base-images/releases):

- `paketobuildpacks/ubuntu-resolute-run` *default*
- `paketobuildpacks/ubuntu-resolute-run-tiny`
- `paketobuildpacks/ubuntu-resolute-run-static`

### `no-stacks` base images

- `paketobuildpacks/ubuntu-resolute-build-no-stacks`
- `paketobuildpacks/ubuntu-resolute-run-no-stacks` *default*
- `paketobuildpacks/ubuntu-resolute-run-tiny-no-stacks`
- `paketobuildpacks/ubuntu-resolute-run-static-no-stacks`

Images with the `no-stacks` suffix match the standard base images but omit `io.buildpacks.stack.id` from image metadata. Use them while you test the move from stacks to base images, as stacks are deprecated.

## Using the Resolute builders

You need the [Pack CLI](https://buildpacks.io/docs/for-platform-operators/how-to/integrate-ci/pack/#install) installed.

A sample application

```
git clone https://github.com/paketo-buildpacks/samples
```

To build with the Resolute builder:

```
pack build nodejs-app \
    --path ./samples/nodejs/no-package-manager \
    --builder paketobuildpacks/ubuntu-resolute-builder
```

When the build finishes, the logs should include:

```
Successfully built image nodejs-app
```

Run the application

```
docker run -d -p 8080:8080 nodejs-app
```

Verify the application responds:

```
curl http://localhost:8080
```

If you receive `HTTP/1.1 200 OK`, the application is running.

For a smaller application image, set the `tiny` run image with `--run-image`:

```
pack build nodejs-app \
    --path ./samples/nodejs/no-package-manager \
    --builder paketobuildpacks/ubuntu-resolute-builder \
    --run-image paketobuildpacks/ubuntu-resolute-run-tiny
```

## Conclusion

If you would like to contribute to the Paketo implementation of Cloud Native Computing Foundation (CNCF) buildpacks, see the community instructions on how to [get involved](https://github.com/paketo-buildpacks/community?tab=readme-ov-file#how-to-get-involved) or read [this blog post on the topic](https://blog.paketo.io/posts/paketo-buildpacks-contributors-wanted/).

Happy building!
