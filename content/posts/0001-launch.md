---
title: Building apps for Kubernetes? Get to Know Paketo Buildpacks.
date: "2020-04-21"
slug: get-to-know-paketo-buildpacks
author: kvedurmudi
---

![Logo](/images/posts/0001/logo.png)

I’m excited to announce the launch of [Paketo Buildpacks](https://paketo.io/),
a collection of Cloud Native Buildpacks for the most popular languages and
frameworks. Paketo Buildpacks make it easy for you to build and patch
containerized apps so that you can spend all your time on the thing that
matters the most… **developing great software**.

## First off… what are Paketo Buildpacks, and why would I use them?

> Buildpacks provide a higher-level abstraction for building apps

If you’re looking for an alternative to Dockerfiles, Buildpacks are worth a
look. Buildpacks:

1. Provide an easy way to transform source code into secure container images
   without requiring developers to write and maintain Dockerfiles.

1. Permit build functionality to be modularized in a re-usable,
   context-independent, and transparent way.

1. Optimize the build experience by minimizing the number of rebuilt image
   layers. (Dockerfiles do this too, but with CNB the layer order doesn’t
   matter!)

1. Provide a simple and nearly-instant method for patching OS-level
   vulnerabilities.

1. Provide metadata about the contents of container images, via an extensive
   Bill-of-Materials.

Paketo Buildpacks use the Cloud Native Buildpacks specification to provide
modular language runtime support for applications. Paketo Buildpacks are great
if you:

* **Deploy container images to Kubernetes.** Paketo Buildpacks follow best
  practices in each language ecosystem. They package your apps into container
  images that can easily be deployed onto any modern runtime.

* **Want to use the latest language runtimes to build your apps.** Need the
  latest runtime or compiler features? Tired of waiting for OS package repos to
  update? You can trust the Paketo Buildpacks project to release new buildpacks
  whenever new dependency version lines are released upstream.

* **Don’t want to spend time worrying about vulnerable dependencies.** We’re
  constantly updating Paketo Buildpacks to patch vulnerabilities in upstream
  language runtimes and operating system packages. The community has a terrific
  track record of keeping these bits updated, so it’s easier for your apps to
  stay up-to-date. Additionally, since Paketo Buildpacks use CNB and the OCI
  standard, it’s easy to “rebase” your app images with stack updates.

## Demo

Let’s run through a quick demo of how easy it is to build your apps using
Paketo Buildpacks and deploy them to an existing Kubernetes cluster. We’re
using a local Minikube cluster for this demo.

Prerequisites:

* [Pack CLI](https://github.com/buildpacks/pack)
* [Docker](https://docs.docker.com/get-docker/)
* [kubectl CLI](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* [Minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/)

You can find the demo app source code
[here](https://github.com/paketo-buildpacks/samples/tree/master/demo-apps/app-source).

Let’s build a simple Node.js app using pack and the Node.js Paketo Buildpack.

```
$ pack build paketo-demo-app -p </path/to/app/source> --builder gcr.io/paketo-buildpacks/builder:base
```

![Demo 1](/images/posts/0001/demo-1.gif)

Now, let’s quickly validate that our app is working as expected.

```
$ docker run -p 8080:8080 -e PORT=8080 paketo-demo-app &
$ curl localhost:8080/greeting
```

![Demo 2](/images/posts/0001/demo-2.gif)

Awesome, it works! Now let’s tag our image and publish it to a registry
location. We’re using a GCR registry for this demo.

```
$ docker tag paketo-demo-app </registry/path/to/demo/image>
$ docker push </registry/path/to/demo/image>
```

![Demo 3](/images/posts/0001/demo-3.gif)

Finally, let’s deploy our app image to our live Kubernetes cluster.

```
$ kubectl create deployment paketo-node --image=</registry/path/to/demo/image>
$ kubectl expose deployment paketo-node --type=LoadBalancer --port=8080
$ minikube service paketo-node
```

![Demo 4](/images/posts/0001/demo-4.gif)

And that’s it! It’s that simple to get started with Paketo Buildpacks! You can
run `kubectl get services` to find the IP address of your deployed app.

## Give Paketo Buildpacks a Try!

Ready to learn more? Check out these links.

* Join us on [Slack](https://slack.paketo.io/) and start asking questions!
* Walk through our
  [tutorial](https://paketo.io/docs/getting-started/build-an-example-app/) on
  [paketo.io](https://paketo.io/) to see how easy it is to use Paketo
  Buildpacks to build your apps.
* Bookmark the [Paketo Buildpacks
  Github](https://github.com/paketo-buildpacks/) to see all the cool buildpacks
  and tools we’re building!
* Follow us on [Twitter](https://twitter.com/Paketo_io)!
* Read through [buildpacks.io](https://buildpacks.io/) for more information
  about how Cloud Native Buildpacks work.
