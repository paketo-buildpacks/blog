---
title: What is the Build Plan Buildpack and why should I care?
date: "2021-02-09"
slug: build-plan-buildpack-exploration
author: feckhardt
---
The [Build Plan buildpack](https://github.com/paketo-community/build-plan)
gives you very precise control over what buildpacks will run in during the
build phase and whether or not a buildpacks dependencies will end up in the
final image or not. It gives you the ability to force most buildpacks to pass
detection even if their normal detection criteria are not present. Let's talk
about how it works and why/when you would utilize this kind of functionality.

## Brief summary of the Build Plan

The Build Plan is a part of the Cloud Native Buildpacks (CNB) Specification
that is the format for how buildpacks communicate during the detect phase of
the lifecycle. Buildpacks essentially write out a Build Plan that outlies the
dependency that the buildpack will either provide or require during its build
phase. Buildpacks may both require and provide any number of dependencies. For
detection to pass a buildpacks must have all of the dependencies it requires,
provided by a buildpack that comes before it in the build order and it needs to
have all of the dependencies that it provides, required by buildpacks that come
later in the build order. If either of these conditions is not satisfied
detection will fail for that buildpack. A more in-depth breakdown of the Build
Plan can be found in the [CNB
Spec](https://github.com/buildpacks/spec/blob/main/buildpack.md).

## How does the Build Plan buildpack work?

The Build Plan buildpack works by adding a `plan.toml`, which mirrors the
[requires portion of Build
Plan](https://github.com/buildpacks/spec/blob/main/buildpack.md#build-plan-toml),
to the root of your app. The buildpack will read the `plan.toml` and make all
of the requirements listed in it for you. This means that if you add a
`plan.toml` to the root of your app and then adds the Build Plan buildpack to
the end of your  buildpack group, you will be able to make any arbitrary
requirement that you want. Furthermore, if you are using the Build Plan
buildpack with Paketo Buildpacks the Build Plan buildpack will allow you to
specify when you want the dependency to be present whether that be during
build, at launch, or both. You can specify this for Paketo Buildpacks because
we respect two flags that go in the `metadata` field of a requirement. Those
two flags are `build` and `launch`, `build` makes the dependency available
during the build phase of subsequent buildpacks in the order, and `launch`
makes the dependency available in the final running image.

## Why would I want this?

The place where the Build Plan buildpack is used heavily right now is during
the integration testing of dependency buildpacks. Let's use a [Go Dist
buildpack integration
app](https://github.com/paketo-buildpacks/go-dist/tree/main/integration/testdata/default_app)
as an example. The `plan.toml` for that app looks as follow:
```
[[requires]]
  name = "go"

  [requires.metadata]
    launch = true
```
The Build Plan buildpack is used here so that we don't need to use either the
Go Mod Vendor or the Go Build buildpacks to require the `go` dependency and we
can force the `go` dependency, which in this case is the Go compiler, to be
present in the final running image, which it normally is absent from, so that
we can run `go run` because a binary wasn't produced due to the absence of the
Go Build buildpack.

There are other applications where the use of the Build Plan buildpack would
enable a build that would be hard if not impossible to detect automatically, or
to make an image as small as possible. A great example of this would be
something like an app that has a simple Nodejs frontend and has a Go backend.
You could add the Node Engine and Build Plan buildpack to the order grouping of
your build and write a `plan.toml` that required the node engine during launch.
This would force the Node Engine buildpack's detection to pass and the build
phase would install the node engine into the image and make it available during
build.

There are obviously countless different scenarios that you could propose that
are either made possible by using the Build Plan buildpack, so we encourage
everyone to check it out, play with it, and see what you can do with it. If you
have any questions you can always feel free to ask us using any of the
platforms listed below and we would be more than happy to try and help you.

# Links to talk to us
