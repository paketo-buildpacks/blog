---
title: What is the Build Plan Buildpack and why should I care?
date: "2021-04-08"
slug: build-plan-buildpack-exploration
author: feckhardt
---
The [Build Plan buildpack](https://github.com/paketo-community/build-plan)
gives you very precise control over what buildpacks run during a build and what
dependencies end up in the final image. Let's talk about how it works and
why/when you would use this kind of functionality.

### What is the Build Plan?

A Build Plan is how a buildpack indicates to other buildpacks which
dependencies it provides and requires. Formally, its a part of the Cloud Native
Buildpacks (CNB) [Buildpack API
specification](https://github.com/buildpacks/spec/blob/main/buildpack.md) and
it functions by passing a [TOML
file](https://github.com/buildpacks/spec/blob/main/buildpack.md#build-plan-toml)
to the buildpack lifecycle after the detect phase has completed. There's a lot
of nuance and complexity there but mostly this means that at the end of the
detect phase, a buildpack will write down what it is capable of providing as a
dependency for other buildpacks to use. It also writes down what it requires in
order to perform its own functions.

Let's show this with an example. The [`bundle-install`
buildpack](https://github.com/paketo-buildpacks/bundle-install) performs a
`bundle install` process which installs Ruby packages called "gems". In order
to run `bundle install`, the buildpack needs an installation of Ruby and the
Bundler CLI. All of this can be described in a Build Plan, which would look
like the following:
```
[[provides]]
  name = "gems"

[[requires]]
  name = "mri"

[[requires]]
  name = "bundler"
```
The buildpack simply states that it provides `gems`, and requires `mri` (Ruby)
and `bundler`. Now, for our buildpack to "pass" detection and participate in
the build process, other buildpacks in its group must provide its requirements
and require its provisions. Lucky for us, the
[`mri`](https://github.com/paketo-buildpacks/mri) and
[`bundler`](https://github.com/paketo-buildpacks/bundler) buildpacks provide
those dependencies, and the [`puma`](https://github.com/paketo-buildpacks/puma)
buildpack requires `gems` so that it can set the `puma` start command. With
those buildpacks we now have a complete set of providing and requiring plan
entries for `mri`, `bundler`, and `gems`. Now that all of the provisions and
requirements in this buildpack group are satisfied, that group is chosen to
execute its build phase.

As you can see, the Build Plan is a fundamental part of the buildpack process.
Its what allows buildpacks to be made modular, replaceable, and composable to
enable a large number of use-cases. Its also what allows buildpacks to
communicate and collaborate on what exactly gets done during the build phase.
We'll explain more about that communication and collaboration a bit later. For
now, let's focus on what the Build Plan Buildpack does.

### How does the Build Plan Buildpack work?

The Build Plan Buildpack works by reading a user provided file at the root of
your app called `plan.toml`, which mirrors the [requires portion of Build
Plan](https://github.com/buildpacks/spec/blob/main/buildpack.md#build-plan-toml).
`plan.toml` has the following schema:
```
[[requires]]
name = "<dependency name>"

[requires.metadata]
# buildpack-specific data

[[or]]

[[or.requires]]
name = "<dependency name>"

[or.requires.metadata]
# buildpack-specific data
```
The buildpack reads `plan.toml` and makes all of the requirements listed in it.
This means you will be able to make any arbitrary requirements that you want.
Furthermore, if you are using the Build Plan Buildpack with Paketo Buildpacks,
it will allow you to specify when you want the dependency to be present whether
that is during build-time, launch-time, or both. You can specify this for
Paketo Buildpacks because they respect two flags that go in the `metadata`
field of a requirement. Those two flags are `build` which makes the dependency
available during the build phase of subsequent buildpacks in the order, and
`launch` which makes the dependency available in the final running image.

### Why would I want this?

Let's start with a basic example. Let's say that you want create an image that
has the Go compiler on it. This is noramlly impossible because the `go`
dependency is usually only ever required during build to compile your
applications source code. However, with the Build Plan buildpack you could
write the following `plan.toml` that would force the compiler to be on the
image.
```
[[requires]]
  name = "go"

  [requires.metadata]
    launch = true
```

There are other applications where the use of the Build Plan buildpack would
enable a build that would be hard if not impossible to detect automatically, or
to make an image as small as possible.

An example of this would be an app that has a simple Nodejs frontend and has a
Go backend. You could add the Node Engine and Build Plan buildpack to the order
grouping of your build and write a `plan.toml` that required the node engine
during launch. This would force the Node Engine buildpack's detection to pass
and the build phase would install the node engine into the image and make it
available during build.

There are countless scenarios that you could propose that are
made possible by using the Build Plan buildpack, so we encourage everyone to
check it out, play with it, and see what you can do with it. If you have any
questions you can always feel free to ask us using any of the platforms listed
below and we would be more than happy to try and help you.

#### Connecting with our community
- [Paketo Slack](https://slack.paketo.io): chat with Paketo maintainers in real
  time to get quick questions answered
- [Github Discussion
  forum](http://github.com/paketo-buildpacks/feedback/discussions): suggest
  ideas and get feedback asynchronously from the Paketo community
- [RFC process](https://github.com/paketo-buildpacks/rfcs): formally propose
  your modification
- [Paketo Working Group
  meetings](https://github.com/paketo-buildpacks/community#working-group-meetings):
  bring your ideas, RFCs, buildpacks, etc. for discussion in the weekly video
  call with Paketo maintainers and contributors
