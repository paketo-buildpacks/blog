---
title: Reintroducing the PHP Buildpack
date: "2022-05-03"
slug: php-rearchitecture
author: swigmore
---

![New PHP Logo](/images/posts/0009/php_rearchitecture.png)

There's a new and exciting development in the Paketo Buildpacks project! The
[Paketo PHP Buildpack](https://github.com/paketo-buildpacks/php) has been fully
re-architected and is ready to make containerizing PHP applications simple and
transparent. With the rearchitecture, the same base set of functionality is
supported as in the original PHP buildpack, but the buildpacks have been
modernized using the newest Paketo tooling and modularized to separate concerns
into individual buildpacks.

## What's new?

#### Breaking it down
The rearchitecture has made it vastly easier for maintainers and contributors
to add new functionality to the language family in the future, by breaking down
what used to be three larger buildpacks, into 10+ new buildpacks responsible
for single parts of the build process. This may sound like a lot of new
buildpacks, but small lighter-weight buildpacks are actually what we strive
for in the project. This concept is well-described in the [Paketo Buildpacks
Philosophy Part 1 blog
post](https://blog.paketo.io/posts/buildpack-philosophy-part-1/)

TODO: insert gif here


#### API Upgrades
The new buildpacks have also been re-written to leverage the newest Paketo
tooling, such as the [packit
library](https://github.com/paketo-buildpacks/packit). Using the packit library
allows the buildpacks to run on the latest versions of the upstream Cloud
Native Buildpacks specifiction to make sure our buildpacks support the full
range of new features in the buildpacks ecosystem. The new PHP buildpacks are
built on [Buildpack API
0.7](https://github.com/buildpacks/spec/blob/buildpack/v0.7/buildpack.md), as
opposed to the API 0.4 that the old buildpacks used.

#### SBOM support
Because of these improvements, the buildpacks now include [Software Bill of
Materials](https://paketo.io/docs/concepts/sbom/) (SBOM) support. The SBOM
provides metadata about the dependencies associated with your application
image, and can be used for vulnerability scanning. Check out the [Paketo
documentation](https://paketo.io/docs/howto/sbom/) for how to access the SBOM.

#### Maintaining the same use cases
If you're not already acquainted with the previous version of the buildpack PHP
buildpack, the following use cases are supported:

*  Build PHP apps that are served with HTTPD
*  Build PHP apps that are served with Nginx
*  Build PHP apps that are served the PHP Built-in Server
*  Leverage the PHP FastCGI Process Manager (FPM) to run alongside servers
*  Build apps that use Composer as an application level package manager
*  Configure and run PHP session handlers for Redis and Memcached instances

The main difference in the user experience is that support for setting
configuration through a `buildpack.yml` has been removed in favour of
environment variable configuration. The configuration options are now detailed
in the [Paketo PHP How-To documentation](https://paketo.io/docs/howto/php/),
with more in-depth details of buildpack behaviour available in the [Paketo PHP
Buildpack Reference
documentation](https://paketo.io/docs/reference/php-reference/).

#### Accessing the new release
The new PHP buildpack has been released as v1.1.0 (yes, we found a bug in
v1.0.0 😝) is included in the latest [Paketo Full
Builder](https://github.com/paketo-buildpacks/full-builder/releases/tag/v0.2.63).
You can also find it on
[Dockerhub](https://hub.docker.com/r/paketobuildpacks/php) and on the
[Buildpacks
Registry](http://registry.buildpacks.io/buildpacks/paketo-buildpacks/php).

## Demo

TODO

## Learn More
* Want to learn more about using the PHP Buildpack? [Check out our
docs](https://paketo.io/docs/reference/php-reference/).

* Feature request? [Open an
issue](https://github.com/paketo-buildpacks/php/issues).

* Want to chat with maintainers? Join
`#php` in [Paketo slack](https://slack.paketo.io/).

* Want to contribute a bug fix (or buildpack!)? [Learn
  more](https://github.com/paketo-buildpacks/community) about our open source
  community.

Thanks for reading!
