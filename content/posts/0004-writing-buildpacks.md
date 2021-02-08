---
title: Building a Cloud Native Buildpack Isn’t as Hard as You Think
date: "2021-02-05"
slug: building-a-cloud-native-buildpack-isnt-as-hard-as-you-think
author: swigmore
---

Maybe you’ve heard some chatter about Cloud Native Buildpacks, or at least the value in containerizing your applications. Buildpacks provide a seamless mechanism for doing just that. There are a few implementations of the buildpack concept available, but the general takeaways can be summarized as follows:

> “Buildpacks provide a seamless experience from source code to a running container” 

> “Dockerfiles aren’t the only option anymore” 

> “Everything is open source and community driven”

The Paketo project provides CNB implementations for the most popular languages. Check out https://paketo.io/ to learn more about what's supported. Our buildpacks provide great out-of-box support for most languages, but what if I need a buildpack that doesn’t exist yet? As a community-driven project, is the onus on me to create that buildpack? Where do I even begin?

The [Paketo project](paketo.io) strives to make answering those questions transparent, approachable, and simple.  For a full rundown, check out this [blog post](https://medium.com/paketo-buildpacks/building-apps-for-kubernetes-get-to-know-paketo-buildpacks-6dc29b0f3cf3)  and our [2021 Roadmap](https://blog.paketo.io/posts/2021-roadmap/) for a full rundown. The idea of being a community-driven project is splashed across our [website](paketo.io), and [blog posts](https://medium.com/paketo-buildpacks/2021-paketo-buildpacks-roadmap-8f3977833b32) for a reason. As an engineer who recently learned the ropes of working on buildpacks myself, I’ll explain why building a buildpack isn’t as hard as you might think, and provide some tips and tricks I've learned along the way.


## Creating a Paketo-style buildpack

There are definitely some need-to-know basics when it comes to buildpacks that have been well documented by the Cloud Native Buildpacks project in [the docs](https://buildpacks.io/docs/concepts/). Major concepts such as the buildpack lifecycle phases, and the other components that work alongside buildpacks are explained here. Once you have the basics down, there's a [simple tutorial](https://buildpacks.io/docs/buildpack-author-guide/create-buildpack/) to create a CNB in Bash.


### Packit is here to help!

Kicking things up a notch, there is a separate [tutorial](https://paketo.io/docs/tutorials/create-paketo-buildpack/) for creating a simple Paketo Buildpack, which are written in **Golang**. A shining star of the tutorial is the introduction of [packit](github.com/paketo-buildpacks/packit), a library that simplifies the repetitive parts of writing a buildpack, such as [dependency installation](https://github.com/paketo-buildpacks/packit/blob/main/postal) and [file system manipulation](https://github.com/paketo-buildpacks/packit/blob/main/fs). Packit also ensures that the buildpack abides by the [CNB spec](https://github.com/buildpacks/spec) without too much effort

Writing a buildpack with packit is integral to how we write our buildpacks and keep them consistent. I recommend looking at one our buildpacks to see how packit is used. Keep an eye out for future blog post deep diving into packit, as well.


### Bootstrap it

Another huge help is our buildpack [Bootstrapper](https://github.com/paketo-community/bootstrapper) which sets up a basic buildpack directory structure in a Packit-compliant way. Using the bootstrapper tool removes the guesswork involved in setting up all the basic pieces of a buildpack, and enforces test-driven development. The bootstrapper-provided integration tests fail by default, encouraging you to write tests first and think about the overarching picture of what you need your buildpack to do.


### Keeping it simple

Part of our philosophy when it comes to writing buildpacks is to keep it simple. We tend to write modular buildpacks that do one job, and do it well. This allows many simple buildpacks to be composed together to achieve complex behaviours. As a buildpack contributor, this is music to my ears, since the buildpack only needs to focus on one major task. The modular “implementation” buildpacks we write get hooked together in the overarching “language family” buildpack. Let’s see an example of what this looks like in practice:

To containerize a simple Go application, we need a couple things: a relevant Golang version, some way to manage packages (such as Go modules, maybe), and a way to compile and run the app. Depending on the specific needs of the app, each of these steps is handled by one implementation buildpack, which are pulled in by the language family buildpack. 


![Go-Implementation](/images/posts/0004/go-implementation.jpg)



### **Patterns are everywhere**

One of the best pieces of advice I can provide is to take advantage of the work that’s already been done. It's far more helpful to look at what other buildpacks are doing as concrete examples than to try to architect complicated behaviours from scratch or based on a basic tutorial. Across the different language ecosystems, the buildpacks follow major patterns depending on the type of job that they are doing. Decide what you need your buildpack to do, and find patterns that suit your case. Here I’ve highlighted some common patterns across our buildpacks:

### Pattern 1: Installing a distribution/tool
When you need to download some tool or distribution for your app, and (usually) put it on the PATH. Think:
> “I'll need Golang to run my Go app.”,\
> “I'll need to install Bundler to run `bundle-install` commands for my Ruby app."

Check out the following buildpacks: [Go Dist](https://github.com/paketo-buildpacks/go-dist) , [Bundler](https://github.com/paketo-buildpacks/bundler), [Yarn](https://github.com/paketo-buildpacks/yarn), [Node Engine](https://github.com/paketo-buildpacks/node-engine)

Key things to look out for:
* Detection: Variations of checking language-specific files (e.g. Gemfile.lock) or environment variables for versions to install 
* Build: How layer metadata is set<br/></br> 

### Pattern 2: Managing/installing app dependencies

When your app has a dependency manager, this pattern is needed to actually run that command to pull in dependencies. Think: 
> “I'll need to run `bundle-install` to pull in certain gems for my Ruby app.”\
> “I'll need to run `go mod vendor` to vendor my Go app dependencies.”

Check out the following buildpacks: [Bundle Install](https://github.com/paketo-buildpacks/bundle-install), [Go Mod Vendor](https://github.com/paketo-buildpacks/go-mod-vendor), [Yarn Install](https://github.com/paketo-buildpacks/yarn-install), [Rails Assets](github.com/paketo-buildpacks/rails-assets)

Key things to look out for:
* Installation Process Execution: How the command is executed (using pexec)
* Dependency Caching: How dependencies and layers are cached/checked for subsequent builds
* Symlinking: Some buildpacks do symlinking between assets and layers, see [Yarn Install](https://github.com/paketo-buildpacks/yarn-install) for an example.


### Pattern 3: Running a start command

When a command needs to be run to start the app in the container. Think:
> “I'll need to run `go-build` to compile and run my app.”\
> “I have an app that runs on a web server, so I need to run a command to start the server.”

Check out the following buildpacks: [Go Build](github.com/paketo-buildpacks/go-build), [Npm Start](github.com/paketo-buildpacks/npm-start), [Dotnet Execute](http://github.com/paketo-buildpacks/dotnet-execute), Ruby webservers (e.g. [Unicorn](github.com/paketo-buildpacks/unicorn) or [Passenger](github.com/paketo-buildpacks/passenger))

Key things to look out for:
* Detect: What they require during detection to run. This varies widely depending on language.
* Build: Environment configuration set or taken from other buildpacks. This varies widely depending on language.

Of course there are plenty of other patterns and things that buildpacks can do! I urge you to take a look through our other buildpacks for ideas. The [Paketo Dashboard](https://dashboard.paketo.io/) is an excellent place to see a master list of all of the buildpacks we own.


### **Connecting with our community**

The final step piece of advice to make contributing a breeze is to connect with our community in any of our forums that suit you. We have a [Paketo Discussion Forum](http://github.com/paketo-buildpacks/feedback/discussions) on Github which is a great place to throw out ideas and get feedback. Additionally, you can file an issue on relevant buildpack repositories, or feel free to [write an RFC](https://github.com/paketo-buildpacks/rfcs) proposing your idea formally. 

Lastly, if you fancy a chat we’re available on [Paketo Slack](https://slack.paketo.io) and hold weekly [Paketo Working Group meetings](https://github.com/paketo-buildpacks/community#working-group-meetings)!
