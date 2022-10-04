---
title: 'Buildpack Development: Selecting a Cloud-Native Buildpacks Library'
date: "2022-10-03"
slug: buildpack-dev-selecting-a-library
author: dmikusa
---

In the Paketo Buildpacks community, we’ve standardized around writing our buildpacks using the Go language. Go works great for buildpack development because it compiles down to a relatively compact static binary, so our buildpack images are small, and it runs very fast, so our buildpacks run fast. It also provides great support for testing and since we want to have rock solid buildpacks, testing is very important as well.

To write a buildpack in the Go language, it helps if you have a library that implements the Cloud-Native Buildpacks (CNB) specification. You could certainly write buildpacks without a library, but it’s going to require more work and you then need to validate that your buildpack follows the specification.

This leads to what is probably the most common questions we see around developing buildpacks and contributing to the Paketo Buildpacks community. What library should I use? There are three choices and this article will break down each library and the differences.

### libcnb

The Cloud-Native Buildpacks project publishes an official library in Go called `libcnb`. The goal of the `libcnb` library is to implement the Cloud-Native Buildpacks specification in a fairly straightforward and transparent way. It doesn't add a lot of abstractions or additional bells and whistles.

Reasons for using `libcnb` directly:

- You want a minimal set of dependencies.
- Perhaps your buildpack is small/simple and `libcnb` covers everything you require.
- You want new features as soon as possible. Because this is from the CNB project directly, it tends to get all the new features very quickly.
- You want to contribute a buildpack to the CNB directly.
- You want to learn about the CNB specification. Since it maps more directly to the specification and there is less abstraction, it makes learning about the specification easier.

### libpak & packit

The Paketo project has a lot of buildpacks and through the process of writing these buildpacks has discovered many interesting patterns and bits of functionality that we see repeated across buildpacks. As such, we have created our own libraries to extract this code and follow the DRY (don't repeat yourself) principle. 

This has resulted in us producing two additional libraries: `libpak` and `packit`. 

Things to keep in mind about both libraries.

- They both offer a spec-compliant way to create buildpacks
- They both offer a lot of additional functionality, like managing dependencies, file management, logging, running processes and handling bindings, as well as providing their own CI and packaging tools to actually build and ship your buildpack.
- They are both fully maintained and supported by the Paketo project. 

What’s different between the two libraries?

- Primarily the opinions, like the look and feel, and conventions that each library follow
- The API that each library provides
- The implementation. With `libpak`, it extends `libcnb`, while `packit` is a  ground-up separate spec implementation. This shouldn't ultimately matter though as both produce a spec-compliant buildpack.

So which one should you pick? Well, that depends, but we can offer some advice.

1. If you're writing your own buildpack then it's really up to you. Both will work great, so we suggest that you simply pick based on the options, conventions, and API that you prefer.

2. If you're contributing to Paketo, we strongly suggest that you pick the library primarily used by the language family to which you are contributing features, code, or even a whole buildpack.

    The Java buildpacks, Application Monitoring buildpacks, and most of the utilities buildpacks are implemented using `libpak`, while the other language families like Python, Ruby, Go, and Node.js are written using `packit`. Keeping this consistent helps the teams to more easily approve and maintain the code you commit.

### Future Direction

The Paketo project is aware that having two different libraries for creating buildpacks has caused some confusion in the community and represents some development overhead for the project.

The present plan is to gradually bring the `libpak` and `packit` libraries closer together. A likely first step will be to base future versions of `packit` off of the `libcnb`, and some work has already started to facilitate this upstream in `libcnb`. This will reduce the overhead of maintaining a second spec implementation, and removes the possibility of behavior differences based on the implementation.

Beyond that, we hope to see things like CI processes and publishing tools consolidate. We believe that this is another area where we can improve developer experience and reduce our maintenance costs.

It's not clear if there will ever be one library to rule them all, but it is a path that we'll likely continue to explore in the long term. Developers should not worry about picking a winner, both `libpak` and `packit` are likely to be around for years to come.

If you have any additional questions, comments or feedback we'd love to hear from you! Please feel free to open Github issues or reach out on the Paketo Slack.
