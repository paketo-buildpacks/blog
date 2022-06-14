---
title: Paketo Buildpacks Hot Topic at Cloud Foundry Summit
date: "2020-06-30"
slug: paketo-buildpacks-hot-topic-at-cf-summit
author: kvedurmudi
---

![Logo](/images/posts/0002/logo.jpg)

Paketo Buildpacks were a hot topic at the recently concluded [Cloud Foundry
Summit](https://www.cloudfoundry.org/events/summit/na-virtual-2020/), the first
**virtual Summit run by the Cloud Foundry Foundation**. The Summit featured project
updates, particularly in the Kubernetes space, including a talk on Paketo
Buildpacks. Dan Thornton, an engineer contributing to the Paketo Buildpacks
project, maintained that they are the ideal tool for transforming app source
code into container images.

So, we wanted to share Dan’s talk here and dive into a Q&A of all of the
questions we didn’t get to answer during this session. A comprehensive list of
other sessions can be found on the Cloud Foundry [YouTube
channel](https://www.youtube.com/channel/UC0ZYS0Y7b5oiVLvxGf4magw).

{{< youtube id="JVUh9OuA5N4" class="youtube" title="Paketo Buildpacks, From Source Code to Application Images - Daniel Thornton, VMWare" >}}

## Q&A

**Q**: What is the state of the CNB ([Cloud Native
Buildpacks](https://buildpacks.io/)) project in the CNCF? CNCF TOC suggested
that there weren’t enough end users to promote it.\
**A**: The decision to move into incubation is still open. Currently CNB is a
sandbox project. CNB’s proposal for incubation listed platforms integrating CNB
in production as end-users of the CNB project. The CNCF TOC has yet to
determine if platforms qualify as end-users of the project. If platforms do not
qualify, CNB will work to identify users that meet the TOC’s requirements.

**Q**: Will it be easier to see which buildpack versions are in use by
particular applications? We often find people using outdated buildpack
versions, so visibility would greatly help.\
**A**: Yes! It is much easier to view this buildpack specific metadata on your
app image than it has been with previous buildpack iterations (Cloud Foundry
buildpacks). Most CNB platforms such as pack and kpack allow you to view this
metadata. With the [pack CLI](https://github.com/buildpacks/pack), you can run
`pack inspect-image <image name>` to view this.

**Q**: One challenge with buildpacks is time. Is there a way to “lock in”
buildpack versions major/minor/patch?\
**A**: This is a bit outside the scope of the buildpacks themselves, and more
about the platform that is running these buildpacks. One such platform is
**kpack**. This platform does let you lock onto a current version of a buildpack
but this is a bit antithetical to the process we are looking to encourage.
Paketo reduces cost and risk associated with building new application images
and promotion of the image from development into production. This should enable
users to take advantage of the secure & up to date dependencies Paketo
Buildpacks provide.

**Q**: What is ABI compatibility ? Is this the concept of “rebasable” images
layers?\
**A**:
[https://en.wikipedia.org/wiki/Application_binary_interface](https://en.wikipedia.org/wiki/Application_binary_interface)
It is the contract provided by OS vendors that guarantees that software doesn’t
need to be rebuilt when security patches are applied to the OS layers. It makes
“rebasable” image layers safe to rebase.

**Q**: Does Openshift use the same buildpack to make their source to image?\
**A**: No

**Q**: Does building images using Paketo require a docker daemon as a
prerequisite? Can it run with any alternative such as podman?\
**A**: Paketo only requires a Docker daemon when you build with pack, which is
designed to work on operating systems like macOS and Windows that don’t
natively support containers. Paketo buildpacks work without the Docker daemon
(or any privileges) on container platforms like Tekton or on any K8s via kpack.
(The CNB lifecycle can build container images entirely in userland, and export
them directly to a docker registry.)

**Q**: Can buildpacks be combined?\
**A**: Yes they can. In the example build from the talk, the “node-engine” and
“npm” buildpacks provided dependency layers in our app image. Any group of
buildpacks can be combined into a “meta buildpack”. This meta buildpack
provides an ordering you would expect the buildpacks to run in. The Paketo
project provides meta buildpacks that cover common use cases but allows users
to define their own. For an example of this, see the Node.js meta Paketo
Buildpack [order
definition](https://github.com/paketo-buildpacks/nodejs/blob/ea4d2cde1fd3932454e952e2ce1fb51c359d7106/buildpack.toml#L36-L51),
which contains both the “node-engine” and “npm” buildpacks.

**Q**: What about the multistage builds that are resulting of scratch image
with binary and a bunch of config files inside (golang usual)?\
**A**: All builds are effectively multi-stage builds. The buildpack runs in a
container, but then selectively chooses what to add to the layers in the image
that it is contributing to. Therefore, nothing that isn’t explicitly added by a
buildpack will be in the final image. The Go buildpack already uses a rich
build image to compile applications and adds only the compiled binary to the
final image. We use a base image called
[tiny](https://github.com/paketo-buildpacks/stacks#tiny) which is effectively
distroless rather than scratch, for the same reasons that Google created
[distroless](https://github.com/GoogleContainerTools/distroless) in the first
place.

**Q**: Do you plan to add a Quarkus buildpack to have a light image?\
**A**: Quarkus is not the only way to get a native-image Java application and
light images. We support building [Spring Boot native
images](https://github.com/paketo-buildpacks/java-native-image) and would
welcome contributions to build native-images from other projects.

**Q**: How would Paketo Buildpacks work if you have dependencies that link into
the OS layer with handling “lift and shift”?\
**A**: Given you use a ABI compatible image, ABI compatibility guarantees that
the links a dependency has into the underlying OS will not be broken. The
Paketo project currently supports 3 ABI compatible images named **tiny**,
**base**, and **full**. So it’s possible to lift all application & dependency
bits off of an old **base** layer and place them atop a new one with no
breakages.

**Q**: How is the java buildpack coming on?\
**A**: Complete and ready for production. Get started
[here](https://github.com/paketo-buildpacks/java).

**Q**: What’s the name of this CLI tool for digging into layers? Is that pack
itself?
**A**: [dive](https://github.com/wagoodman/dive)

## Learn more!

* [Get to know Paketo Buildpacks](/posts/get-to-know-paketo-buildpacks)
* Website — [https://paketo.io](https://paketo.io)
* Slack — [https://slack.paketo.io](https://slack.paketo.io)
* GitHub — [https://github.com/paketo-buildpacks](https://github.com/paketo-buildpacks)
