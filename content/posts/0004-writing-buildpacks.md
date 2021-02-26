---
title: Building a Cloud Native Buildpack Isn’t as Hard as You Think
date: "2021-02-16"
slug: building-a-cloud-native-buildpack-isnt-as-hard-as-you-think
author: swigmore
---
Maybe you’ve heard that many companies today are transitioning to, or have already transitioned to, a container-based platform like Kubernetes. With this movement comes the need to containerize your applications, new and old. Buildpacks provide a seamless mechanism for doing that *without Dockerfiles.* [Paketo Buildpacks](https://paketo.io) is a community-driven project that provides [Cloud Native Buildpacks](https://buildpacks.io) implementations for the most popular languages. Buildpacks provide great out-of-box support for many languages, but what if you need a buildpack that doesn’t exist yet? As a community-driven initiative, it may feel like the onus is on you to create that buildpack. Where would you even begin? 🤯

Paketo Buildpacks strives to make answering those questions transparent, approachable, and simple. The idea of being a community-driven project is splashed across our [blog posts](/posts/get-to-know-paketo-buildpacks), and [roadmap](/posts/2021-roadmap) for a reason. As an engineer who recently learned the ropes of working on buildpacks myself, I’ll explain why building a buildpack isn’t as hard as you might think, and provide some tips and tricks I've learned along the way.

#### **Keep it simple**

Part of our philosophy when it comes to writing buildpacks is to keep it simple. We want each buildpack to do one job and do it well. This way many simple buildpacks can be combined to achieve complex behaviours. 

This is both a blessing and a curse when it comes to writing buildpacks. It’s a blessing for obvious reasons: since the buildpack only needs to focus on one major task, it's simpler to write. We try to pick good defaults that would make the experience better in the vast majority of cases, and to keep our APIs streamlined, but meaningful.

Simple sounds good, how could this be a curse? 
Because our buildpacks perform one task each, in unique use cases it can be hard to discern if you need a fully new buildpack for your case, or if an existing buildpack just needs a tweak. It doesn’t always make sense to architect a new buildpack, but it can be hard to make this judgement if you’re not closely acquainted with buildpacks that are already available.

#### Two roads diverged

One way to determine if you need a new buildpack is to think about if the feature in question is completely new functionality, or if it’s an unimplemented subset of existing buildpack functionality.
![Roads-Diverged](/images/posts/0004/roads-diverged.jpg)

##### When to add a new buildpack
New functionality usually means a new buildpack is needed. An example of this can be seen with the [Rails Assets buildpack](https://github.com/paketo-buildpacks/rails-assets). A user, [@drnic](https://github.com/drnic) filed [an issue](https://github.com/paketo-buildpacks/ruby/issues/470) about performing asset compilation for Ruby apps, which was completely unsupported behaviour in the Ruby buildpacks. A Ruby maintainer, [@ryanmoran](https://github.com/ryanmoran) wrote up [an RFC](https://github.com/paketo-buildpacks/ruby/pull/475) to propose a new buildpack for the functionality, and a contributor [@genevievelesperance](https://github.com/genevieve) actually [implemented the buildpack](https://github.com/genevieve/rails-assets). (If you’re interested in this workflow, look out for a future blog post outlining our contribution process!) The idea here is that a new buildpack was needed in order to support completely new functionality.

Another example of this case is when a brand new dependency or runtime is needed in an app image. If a buildpack providing the specific distribution that you need doesn't exist, then this would be another good indicator that a new buildpack is needed. This is slightly different than the Rails Assets example above, because that buildpack performs a new behaviour, but doesn't provide a dependency. An example of a need for a new runtime can be seen with the [Rust buildpack](https://github.com/paketo-community/rust). Contributor [@dmikusa-pivotal](https://github.com/dmikusa-pivotal) put together a set of new buildpacks to support Rust-based apps. Specifically the [Rust Dist buildpack](https://github.com/paketo-community/rust-dist) is an example of creating a new buildpack in order to provide a new runtime.

##### When to modify a buildpack
On the other hand, there are many cases for modifying an existing buildpack. When looking for cases of “unimplemented subsets of existing functionality”, ask yourself: *If you were building the app container, step by step, is there any “optional” behaviour?*

For example, imagine an app that serves content on a custom port, rather than using the default port 8080. If the existing buildpack only allowed default port 8080 to be used, it would make sense to modify the buildpack to allow for the optional behaviour of using a custom port, rather than writing a separate buildpack with almost the same logic. This modification would still follow the "keep it simple" philosophy in that the buildpack would still be performing one task, just with more flexibility. This is a simplified example, but there are surely other examples of optimizations within the scope of a buildpack’s functionality that could allow for some new behaviour. We’re always looking for cases where we can optimize the buildpacks, and invite you to weigh in via a Github issue if you can think of one!

#### Patterns are everywhere

Across the different language ecosystems, the buildpacks follow major patterns depending on the type of job that they are doing. Understanding the patterns that our buildpacks follow can make the decision whether to modify a buildpack or create a new one clearer. Especially in the case of writing a new buildpack, I recommend taking advantage of the work that’s already been done. It's far more helpful to look at what other buildpacks are doing as concrete examples than to try to architect complicated behaviours from scratch. Decide what you need your buildpack to do, and find patterns that suit your case. Here I’ve highlighted some common patterns across our buildpacks:

##### Installing a distribution/tool

When you need to download some tool or distribution for your app, and (usually) put it on the PATH, you may find yourself saying:

*“I'll need Golang to build and run my Go app”*, or
*“I'll need to install Bundler to run `bundle-install` commands for my Ruby app."*

Check out the following buildpacks: [Go Dist](https://github.com/paketo-buildpacks/go-dist) , [Bundler](https://github.com/paketo-buildpacks/bundler), [Yarn](https://github.com/paketo-buildpacks/yarn), [Node Engine](https://github.com/paketo-buildpacks/node-engine). And look for the following things:

* Detection: Variations of checking language-specific files (e.g. `Gemfile.lock`) or environment variables for versions to install
* Build: How layer metadata is set (i.e. will I need the contents of this layer during container build-time, run-time, or in subsequent builds?)

##### Managing or installing app dependencies

When your app has a dependency manager, you may be thinking:

*“I'll need to run `bundle-install` to pull in certain gems for my Ruby app”* or 
*“I'll need to run `go mod vendor` to vendor my Go app dependencies.”*

Check out the following buildpacks: [Bundle Install](https://github.com/paketo-buildpacks/bundle-install), [Go Mod Vendor](https://github.com/paketo-buildpacks/go-mod-vendor), [Yarn Install](https://github.com/paketo-buildpacks/yarn-install), [Rails Assets](https://github.com/paketo-buildpacks/rails-assets). And look for the following things:

* Installation Process Execution: How the command is executed (using `pexec`)
* Dependency Caching: How dependencies and layers are cached/reused for subsequent builds
* Symlinking: Some buildpacks do symlinking between assets and layers, see [Yarn Install](https://github.com/paketo-buildpacks/yarn-install) for an example.

##### Running a start command

When a command needs to be run to start the app in the container, you might think:

*“I'll need to run `go-build` to compile and run my app”* or
*“I have an app that runs on a web server, so I need to run a command to start the server.”*

Check out the following buildpacks: [Go Build](https://github.com/paketo-buildpacks/go-build), [Npm Start](https://github.com/paketo-buildpacks/npm-start), [Dotnet Execute](https://github.com/paketo-buildpacks/dotnet-execute), Ruby webservers (e.g. [Unicorn](https://github.com/paketo-buildpacks/unicorn) or [Passenger](https://github.com/paketo-buildpacks/passenger)). And look for the following things:

* Detect: What they require during detection to run. This varies widely depending on language.
* Build: Environment variables set or read from other buildpacks. This varies widely depending on language, but can have an impact on the outcome of the start command.

Of course there are plenty of other patterns and things that buildpacks can do! I urge you to take a look through our other buildpacks for ideas. The [Paketo Dashboard](https://dashboard.paketo.io/) is an excellent place to see a master list of all of the buildpacks we maintain.


#### **Creating a new Paketo-style buildpack**

If you get to the stage where you’re sure that you need a new buildpack, there are some tips to make this process easier.

There are definitely some need-to-know basics when it comes to buildpacks that have been [well documented](https://buildpacks.io/docs/concepts/) by the Cloud Native Buildpacks project. I recommend reading this documentation for more information on some basic concepts, like the buildpack lifecycle phases. Once you have the basics down, there's a [simple tutorial](https://buildpacks.io/docs/buildpack-author-guide/create-buildpack/) to create a CNB in `bash`. This is a great introduction to simple buildpacks, but the Paketo contributors have adopted Golang as our language of choice to carry out more complex behaviour.

#### `packit` is here to help!

Kicking things up a notch, there is a separate [tutorial](https://paketo.io/docs/tutorials/create-paketo-buildpack/) for creating a simple Paketo Buildpack, which are written in **Golang**. The shining star of the tutorial is the introduction of [`packit`](https://github.com/paketo-buildpacks/packit), a library that simplifies the repetitive parts of writing a buildpack, such as [dependency installation](https://github.com/paketo-buildpacks/packit/blob/main/postal) and [file system manipulation](https://github.com/paketo-buildpacks/packit/blob/main/fs). `packit` also ensures that the buildpack abides by the [CNB spec](https://github.com/buildpacks/spec) without too much effort. Writing a buildpack with `packit` is integral to how we write our buildpacks and keep them consistent. I recommend looking at one our buildpacks to see how `packit` is used. Keep an eye out for future blog post deep diving into `packit`, as well.

#### Bootstrap it

Another huge help is our buildpack [Bootstrapper](https://github.com/paketo-community/bootstrapper) which sets up a basic buildpack directory structure in a `packit`-compliant way. Using the bootstrapper tool removes the guesswork involved in setting up all the basic pieces of a buildpack, and enforces test-driven development. The bootstrapper-provided integration tests fail by default, encouraging you to write tests first and think about the overarching picture of what you need your buildpack to do.

#### Connecting with our community
My final piece of advice to make contributing a breeze is to connect with our community in any of our forums that suit you:
    * [Paketo Slack](https://slack.paketo.io): chat with Paketo maintainers in real time to get quick questions answered
    * [Github Discussion forum](http://github.com/paketo-buildpacks/feedback/discussions): suggest ideas and get feedback asynchronously from the Paketo community
    * [RFC process](https://github.com/paketo-buildpacks/rfcs): formally propose your modification
    * [Paketo Working Group meetings](https://github.com/paketo-buildpacks/community#working-group-meetings): bring your ideas, RFCs, buildpacks, etc. for discussion in the weekly video call with Paketo maintainers and contributors
