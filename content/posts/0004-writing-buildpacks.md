---
title: Building a Cloud Native Buildpack Isn’t as Hard as You Think
date: "2021-02-09"
slug: building-a-cloud-native-buildpack-isnt-as-hard-as-you-think
author: swigmore
---

Maybe you’ve heard of Cloud Native Buildpacks (CNB), or at least the value in containerizing your applications. Buildpacks provide a seamless mechanism for doing just that. There are a few implementations of the buildpack concept available, but the general takeaways can be summarized as follows:

> Buildpacks provide a seamless experience from source code to a running container

> Dockerfiles aren’t the only option anymore

> Everything is open source and community driven

[Paketo Buildpacks](https://paketo.io) provides CNB implementations for the most popular languages. The buildpacks provide great out-of-box support for many languages, but what if you need a buildpack that doesn’t exist yet? As a community-driven project, it may feel like the onus is on you to create that buildpack? Where would you even begin?

Paketo Buildpacks strives to make answering those questions transparent, approachable, and simple. The idea of being a community-driven project is splashed across our [blog posts](/posts/get-to-know-paketo-buildpacks), and [roadmap](/posts/2021-roadmap) for a reason. As an engineer who recently learned the ropes of working on buildpacks myself, I’ll explain why building a buildpack isn’t as hard as you might think, and provide some tips and tricks I've learned along the way.

### Creating a Paketo-style buildpack

There are definitely some need-to-know basics when it comes to buildpacks that have been [well documented](https://buildpacks.io/docs/concepts/) by the Cloud Native Buildpacks project. I recommend reading this documentation for more information on some basic concepts, like the buildpack lifecycle phases. Once you have the basics down, there's a [simple tutorial](https://buildpacks.io/docs/buildpack-author-guide/create-buildpack/) to create a CNB in `bash`.

#### `packit` is here to help!

Kicking things up a notch, there is a separate [tutorial](https://paketo.io/docs/tutorials/create-paketo-buildpack/) for creating a simple Paketo Buildpack, which are written in **Golang**. The shining star of the tutorial is the introduction of [`packit`](https://github.com/paketo-buildpacks/packit), a library that simplifies the repetitive parts of writing a buildpack, such as [dependency installation](https://github.com/paketo-buildpacks/packit/blob/main/postal) and [file system manipulation](https://github.com/paketo-buildpacks/packit/blob/main/fs). `packit` also ensures that the buildpack abides by the [CNB spec](https://github.com/buildpacks/spec) without too much effort.

Writing a buildpack with `packit` is integral to how we write our buildpacks and keep them consistent. I recommend looking at one our buildpacks to see how `packit` is used. Keep an eye out for future blog post deep diving into `packit`, as well.

#### Bootstrap it

Another huge help is our buildpack [Bootstrapper](https://github.com/paketo-community/bootstrapper) which sets up a basic buildpack directory structure in a `packit`-compliant way. Using the bootstrapper tool removes the guesswork involved in setting up all the basic pieces of a buildpack, and enforces test-driven development. The bootstrapper-provided integration tests fail by default, encouraging you to write tests first and think about the overarching picture of what you need your buildpack to do.

### Keep it simple

Part of our philosophy when it comes to writing buildpacks is to keep it simple. We want each buildpack to do one job and do it well. This way many simple buildpacks can be combined to achieve complex behaviours. As a contributor, this is music to my ears, since the buildpack only needs to focus on one major task. An example of this is our language family buildpacks, like [Go](https://github.com/paketo-buildpacks/go), which is composed of multiple small buildpacks. There's a buildpack for installing Golang, one for vendoring dependencies with Go modules, and one for compiling and running the app. The Go language family buildpack includes different buildpacks depending on the app.

![Go-Implementation](/images/posts/0004/go-implementation.jpg)

#### Patterns are everywhere

I recommend taking advantage of the work that’s already been done. It's far more helpful to look at what other buildpacks are doing as concrete examples than to try to architect complicated behaviours from scratch. Across the different language ecosystems, the buildpacks follow major patterns depending on the type of job that they are doing. Decide what you need your buildpack to do, and find patterns that suit your case. Here I’ve highlighted some common patterns across our buildpacks:

##### Installing a distribution/tool

When you need to download some tool or distribution for your app, and (usually) put it on the PATH, you may find yourself saying:
*“I'll need Golang to build and run my Go app”*, or
*“I'll need to install Bundler to run `bundle-install` commands for my Ruby app."*

Check out the following buildpacks: [Go Dist](https://github.com/paketo-buildpacks/go-dist) , [Bundler](https://github.com/paketo-buildpacks/bundler), [Yarn](https://github.com/paketo-buildpacks/yarn), [Node Engine](https://github.com/paketo-buildpacks/node-engine). And look for the following things:

* Detection: Variations of checking language-specific files (e.g. `Gemfile.lock`) or environment variables for versions to install
* Build: How layer metadata is set

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
* Build: Environment variables set or read from other buildpacks. This varies widely depending on language.

Of course there are plenty of other patterns and things that buildpacks can do! I urge you to take a look through our other buildpacks for ideas. The [Paketo Dashboard](https://dashboard.paketo.io/) is an excellent place to see a master list of all of the buildpacks we maintain.

### **Connecting with our community**
My final piece of advice to make contributing a breeze is to connect with our community in any of our forums that suit you. We have a [discussion forum](http://github.com/paketo-buildpacks/feedback/discussions) on Github which is a great place to suggest ideas and get feedback. Additionally, you can file an issue on relevant buildpack repositories, [write an RFC](https://github.com/paketo-buildpacks/rfcs) proposing your idea formally. Lastly, if you fancy a chat we’re available on [Paketo Slack](https://slack.paketo.io) and hold weekly [Paketo Working Group meetings](https://github.com/paketo-buildpacks/community#working-group-meetings)!

