---
title: Paketo Buildpacks usage and socials
date: "2025-03-31"
slug: paketo-java-usage-socials
author: anthonydahanne
---

## Paketo Buildpacks: where are they used?

[While preparing for a talk about PaaS](https://blog.dahanne.net/2024/04/10/state-of-the-paas-in-2024/), I found out that CNBs (Cloud Native Buildpacks), in particular [Paketo Buildpacks](https://github.com/paketo-buildpacks), are widely used across the industry!

Sure, there's the Dockerfile as our main competition (with all its cons: maintainability, no SBOM generation, no third party agent nor a standard mechanism to include CA certs, etc.), but interestingly enough [NixPacks](https://github.com/railwayapp/nixpacks) (maintained by Railway but used in other PaaS too) are also gaining traction as our competitor.

Here's a non-complete list of PaaS where you can use Paketo Buildpacks to build your container images:

* [Fly.io](https://fly.io/docs/reference/builders/#buildpacks): they support both the Dockerfile (if it's in your workspace, they'll pick it up) and Paketo Buildpacks (if no Dockerfile exists, they rely on them)
* Porter: also defaulting to Paketo Buildpacks
* [Microsoft Azure Container Apps](https://learn.microsoft.com/en-us/azure/container-apps/overview): a mix of Paketo Buildpacks and Azure buildpacks, see this build output:

```shell
pass: 
azure-buildpacks/java-buildpack-msopenjdk@0.3.3
paketo-buildpacks/syft@1.42.0
paketo-buildpacks/maven@6.15.12
paketo-buildpacks/executable-jar@6.8.3
paketo-buildpacks/apache-tomcat@7.14.2
azure-buildpacks/java-buildpack-telemetry@0.1.24
```

* Probably Heroku and Google Cloud Run, since they can run their own CNBs, it should be possible to override and use Paketo Buildpacks instead

In case you don't want to use a public PaaS, you can still run Paketo Buildpacks with:

* [Cloud Foundry](https://docs.cloudfoundry.org/buildpacks/cnb/index.html): since December 2024, it supports CNBs too, thanks to [RFC 0017](https://github.com/cloudfoundry/community/blob/main/toc/rfc/rfc-0017-add-cnbs.md), [RFC 0028](https://github.com/cloudfoundry/community/blob/main/toc/rfc/rfc-0028-cnb-lifecycle.md) and [RFC 0031](https://github.com/cloudfoundry/community/blob/main/toc/rfc/rfc-0031-system-cnb.md)
* [kpack](https://github.com/buildpacks-community/kpack): allows you to define Kubernetes CRDs to define the source of the code you're going to build, as well as the builders and buildpacks you want to use
* [Epinio](https://docs.epinio.io/): based on Kubernetes too, similar to Kpack
* [Dokku](https://dokku.com/): a small self-hosted PaaS solution, supports [Cloud-Native Buildpacks & Paketo](https://dokku.com/docs/deployment/builders/cloud-native-buildpacks/#customizing-the-buildpack-stack-builder)

You can also bookmark [this page that lists Paketo Buildpacks adopters](https://github.com/paketo-buildpacks/community/blob/main/ADOPTERS.md).

## Java Paketo Buildpacks in the news

March 2025 [saw the addition of Java 24](https://github.com/paketo-buildpacks/java/releases/tag/v18.5.0) (in replacement of Java 23), and in September, you can be sure Java 25 (LTS release) will be integrated the week it's out 🤞!

Curious about what's happening with Java Paketo Buildpacks? you'll probably want to watch those recent interviews / talks:

* September 2024: [Spring Office hours - Buildpacks with Anthony Dahanne](https://www.youtube.com/watch?v=am4x5DNaJgs)
* February 2025: [Coffee Software with Anthony Dahanne on Buildpacks](https://www.youtube.com/watch?v=hZWoL0balhY)

And don't miss out the free virtual [JDConf 2025](https://jdconf.com/agenda.html#apac-session-07) where you'll listen to David O'Sullivan and Anthony Dahanne explain how Paketo Buildpacks is the best way to build Java apps container image!

Happy building, make sure you join us on [Slack or GitHub](https://paketo.io/community/) for help and info!

PS: want to add a PaaS, or a tool that leverages Paketo Buildpacks to the list? Please make a [Pull Request to the blog](https://github.com/paketo-buildpacks/blog)