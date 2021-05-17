---
title: A Philosophy for Developing Paketo Buildpacks, Part 1
date: "2021-05-17T15:03:39-07:00"
slug: buildpack-philosophy-part-1
author: rmoran
---

{{< figure src="/images/posts/0000/road.jpg" alt="A road through the wilderness" caption="Photo by [Jon Flobrant](https://unsplash.com/@jonflobrant?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText) on [Unsplash](https://unsplash.com/collections/1666315/philosophy-topics?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText)" >}}

### Sharing what we've learned

The Paketo Buildpacks Team has been developing our Cloud Native Buildpacks for
the better part of 2 years now. In the process, we've learned a lot about what
works well and what doesn't. We've made mistakes and interated toward solutions
that are more flexible, easier to maintain, and provide better experiences for
our users. In the process, we've developed a set of guidelines – a philosophy,
maybe – for how we think about developing buildpacks. These guidelines don't
always apply, but they are what we strive for in the vast majority of cases.

With this post, we'd like to start to record some of that knowledge and share
it with the buildpack authoring community so that you all might benefit. This
post will cover a few of the guidelines, explaining where we think they apply
and even where they might come into conflict with one another. With that, let's
dive right in!

### Guidelines

#### Meet language-ecosystem expectations

When implementing support for a feature, attempt to meet the expectations of
the language ecosystem. Doing so will ensure that developers familiar with that
ecosystem will find the buildpack’s behavior familiar.

There have been a number of instances in the past where we've been faced with a
decision on how best to deliver a new feature: How do we balance finding a
solution that fits the workflows that our users expect while still fitting
cleanly into the buildpack model?

Recently this question of balance became relevant in our [Ruby
buildpack](https://github.com/paketo-buildpacks/ruby) as we worked to provide a
buildpack that enabled a flexible build process while ensuring that we limited
what ends up in the built container image.  Specifically, we knew there were
cases where developers would have different expectations about what gems (Ruby
packages) were provided by the [`bundle-install`
buildpack](https://github.com/paketo-buildpacks/bundle-install) at different
points in the buildpack lifecycle.

For instance, it would be totally reasonable for our users to expect gems that
are only used for development or testing to be available while the application
container is being built, but then not in the resulting container image. An
example of this might be that a user expects to have the [`uglifier`
gem](https://github.com/lautis/uglifier) available to the [`rails-assets`
buildpack](https://github.com/paketo-buildpacks/rails-assets) so that
JavaScript files could be compressed, but then also expect that it wouldn't
appear in the built container image as it serves no purpose to a running Rails
application. Providing a buildpack that operates this way is just what the Ruby
developer ecosystem would expect.

To resolve this, the `bundle-install` buildpack [provides two different
layers](https://github.com/paketo-buildpacks/bundle-install/blob/b2e7772ec4ad72d51b53733a756939c0dfd6056c/build.go#L73-L171),
one for build-related gems and another for launch-related gems. Doing this has
certainly resulted in a buildpack that is more programatically complex, but its
also meant that the buildpack works the way the user thinks. In these cases,
taking on that extra complexity can have huge benefits for developer
productivity.

#### Enable complexity through composition

Try to limit the focus of the buildpack. Buildpacks can easily sprawl as they
accrete features. Instead of pulling every possible feature into the buildpack,
consider how it might be broken down into parts that can be composed together
to create more complex behaviors. In turn, these parts can be reused to enable
other workflows that weren't originally foreseen.

If you dig into many of our language family buildpacks ([.Net
Core](https://github.com/paketo-buildpacks/dotnet-core),
[Go](https://github.com/paketo-buildpacks/go),
[Java](https://github.com/paketo-buildpacks/java), etc.) you'll notice that
they are made up of many smaller buildpacks. Just [taking a
look](https://github.com/paketo-buildpacks/nodejs/blob/33aad92fd908665122d9ca6345fcfd97fa3d86bb/buildpack.toml)
at the NodeJS buildpack, we can see that it consists of 11 smaller buildpacks:

* [Node Engine](https://github.com/paketo-buildpacks/node-engine)
* [Node Start](https://github.com/paketo-buildpacks/node-start)
* [NPM Install](https://github.com/paketo-buildpacks/npm-install)
* [NPM Start](https://github.com/paketo-buildpacks/npm-start)
* [Yarn](https://github.com/paketo-buildpacks/yarn)
* [Yarn Install](https://github.com/paketo-buildpacks/yarn-install)
* [Yarn Start](https://github.com/paketo-buildpacks/yarn-start)
* [Procfile](https://github.com/paketo-buildpacks/procfile)
* [Environment Variables](https://github.com/paketo-buildpacks/environment-variables)
* [Image Labels](https://github.com/paketo-buildpacks/image-labels)
* [CA Certificates](https://github.com/paketo-buildpacks/ca-certificates)

Each one of these buildpacks performs a small role in the overall NodeJS
buildpack. They provide dependencies, execute build tool processes, or
configure the application to run in a containerized environment. They do their
single part of the job well, and in a focused manner. For example, given a
[Yarn](https://yarnpkg.com/)-based application, the Node Engine buildpack
installs the NodeJS runtime, the Yarn buildpack installs the Yarn tool, the
Yarn Install buildpack executes the `yarn install` build process, and the Yarn
Start buildpack chooses the right command to start the application in the
container.

These buildpacks can be used over again in different combinations and in
entirely different buildpack language ecosystems. Its pretty common for
[Rails](http://rubyonrails.org/) apps to require a JavaScript runtime to
compile their assets. The Ruby buildpack includes the Node Engine buildpack to
provide that runtime. It works well because the Node Engine buildpack limits
itself to performing only that one task.

#### Be transparent and understandable

Provide the buildpack user with transparent and understandable feedback during
all phases of the buildpack lifecycle. When a buildpack fails to detect,
specify why. When a buildpack fails to build, include as much logging
information as is reasonable to help the user orient themselves in the build
context at the point of failure. Provide concise prose messages with clear
phrasing.

The log output that our buildpacks provide isn't perfect, but we've thought a
bit about how it conveys information to the user. Let's take a look at some
sample log output from the [Go
buildpack](https://github.com/paketo-buildpacks/go).

```
Paketo Go Distribution Buildpack 0.4.0
  Resolving Go version
    Candidate version sources (in priority order):
      go.mod -> ">= 1.15"

    Selected Go version (using go.mod): 1.16.3

  Executing build process
    Installing Go 1.16.3
      Completed in 13.551s

Paketo Go Mod Vendor Buildpack 0.2.1
  Checking module graph
    Running 'go mod graph'
      Completed in 310ms

  Executing build process
    Running 'go mod vendor'
      Completed in 315ms

Paketo Go Build Buildpack 0.3.2
  Executing build process
    Running 'go build -o /layers/paketo-buildpacks_go-build/targets/bin -buildmode pie .'
      Completed in 45.49s

  Assigning launch processes
    web: /layers/paketo-buildpacks_go-build/targets/bin/mod
    mod: /layers/paketo-buildpacks_go-build/targets/bin/mod
```

From the logs, we can see that there are three buildpacks involved in the build
process ([Go Dist](https://github.com/paketo-buildpacks/go-dist), [Go Mod
Vendor](https://github.com/paketo-buildpacks/go-mod-vendor), and [Go
Build](https://github.com/paketo-buildpacks/go-build)). These buildpacks have
log output that structurally mirror one another. They use indentation to denote
a relational hierarchy to the log information. They tell the user the exact
command that will be executed by the buildpack (`go mod vendor`). And, they
repeat common phrases (`Executing build process`, `Running ...`, `Completed in
...`). These common elements help users to orient themselves.

Not every one of our buildpacks has log output that looks like this. And this
certainly isn't the final note on how we want to provide feedback to buildpack
users about how the buildpacks are working. We'll continue to evolve and
evaluate this output always keeping in mind that the goal should be to remain
transparent and understandable.

#### Understand the container lifecycle and environment

The images our users build will be run in environments that are often chaotic
and/or limited. We should build features in a way that supports environments
that are operating in imperfect conditions. As a starting point, buildpacks
should consider how they can support graceful shutdowns and/or perform tasks in
environments without network access.

To illustrate this, we'll take a look at a scenario we encountered in the
development of the NodeJS buildpack that brought this guideline into conflict
with another. It involves a concept called graceful shutdown that allows
applications to finish responding to open HTTP requests before they terminate
their process.

To see how this type of concern influences the design decisions made in our
buildpacks, let's take a closer look at how Kubernetes handles [stopping
containers](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#pod-termination).
To summarize the documentation, Kubernetes has a mechanism that allows it to
gracefully shutdown containers so that they can finish any work they may have
inflight. Technically, this is achieved by having the container runtime send a
`TERM` signal to the container telling it to finish its work and shutdown. When
it sends the signal, the init process in the container will receive the signal.
Often times this is the application process itself (maybe a Go or Rust binary).
But in some cases, there is a small process tree managing the lifecycle of the
application process. For the signal to make it all the way to the application
process, each process in the hierarchy will need to implement signal handling
and forwarding. If the signal doesn't make it to the application, it won't know
that it needs to finish any inflight requests and come to a stop. Instead, it
will just keep running with the expectation that new requests will keep
arriving. After some time, Kubernetes will send another signal that will result
in the container being stopped entirely. This abrupt stop could mean that
inflight connections between the app and external clients are dropped
mid-request. It obviously creates a less than ideal situation for application
users. Their experience when the connection fails may be that the application
is broken.

In the NodeJS language family we have several buildpacks that choose launch
processes. These launch processes are what the Cloud Native Buildpack launcher
will invoke when the built application container is run. For developers
familiar with `npm`, this is something like `node server.js`. Its often what
they put as the `npm start` command.  When we first built our NodeJS support,
we focused on building something that matched those expectations for NodeJS
developers. We built the [`npm-start`
buildpack](https://github.com/paketo-buildpacks/npm-start) to set the launch
process for the container to `npm start`. Unfortunately, this creates a process
tree that prevents the application from receiving the `TERM` signal from the
container runtime. Specifically, this process tree looks like the following:

```
UID  PID  PPID  C  STIME  TTY        TIME  CMD
cnb    1     0  1  21:41  pts/0  00:00:01  npm
cnb   32     1  0  21:41  pts/0  00:00:00  sh -c node server.js
cnb   33    32  0  21:41  pts/0  00:00:00   \_ node server.js
```

We can see our `npm` process is PID 1 and that there are a couple other child
processes (32 and 33). What's happening here is that `npm` is creating a
subshell to run the command that is defined in the `package.json` for `npm
start` (`node server.js` in this case). Now, when `npm` receives the `TERM`
signal it sends it on, but the subshell between `npm` and your application
`node` process doesn't. It also doesn't act like a proper process manager (and
arguably shouldn't [according to the
maintainers](https://github.com/npm/npm/issues/4603)) making sure these
processes receive that signal.

To ensure the application process will receive a signal and shutdown
gracefully, we don't run `npm start` as the launch process. Instead, we inspect
the command that `npm start` would have run and run it directly. While that
doesn't match directly with what a developer in the NodeJS ecosystem might
expect given their experience developing an application on their own
workstation, it has become a clear [best
practice](https://github.com/nodejs/docker-node/blob/main/docs/BestPractices.md#cmd)
in the community for applications run in containers. Knowing when to make the
tradeoff between these guidelines can be difficult, but it makes all the
difference for creating containers that perform well in all cases.

### Next Time

Hopefully this post left you with some understanding of the thought that has
gone into the development of Paketo buildpacks and maybe even inspired you to
think about [contributing](https://paketo.io/contribute/). In the next post we
will explore some more thoughts we have on the development of Cloud Native
Buildpacks including developing a meaningful API, enabling configuration, and
performance.
