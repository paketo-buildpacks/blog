---
title: Paketo Buildpacks Sunsets Java Azure Composite Buildpack
date: "2025-04-11"
slug: paketo-java-azure-sunsets
author: dmikusa
---

## Urgent News

The [Paketo Buildpacks Java Azure](https://github.com/paketo-buildpacks/java-azure) composite buildpack is being sunset. It will be archived on May 9th, 2025.

Please [see the RFC](https://github.com/paketo-buildpacks/rfcs/blob/main/text/java/0018-retire-java-azure-composite.md) for rationale and details.

## Action Items for You

If you are using this buildpack, you have two choices on how to proceed.

1. You may migrate off it. The primary feature of this buildpack is that it includes the Microsoft OpenJDK JVM. You do not need this buildpack to use the Microsoft OpenJDK JVM though. To continue to using Microsoft OpenJDK and migrate off of the Java Azure composite buildpack, you need to use [the alternative JVM instructions](https://paketo.io/docs/howto/java/#use-an-alternative-jvm) in the Paketo docs.

    For example, `pack build --buildpack paketo-buildpacks/microsoft-openjdk paketo-buildpacks/java ...` will perform a build with the Microsoft OpenJDK JVM instead of the default Bellsoft Liberica JVM.

2. If you prefer to continue using the Paketo Buildpacks Java Azure composite buildpack, then you will need to fork it and maintain it on your own going forward.

    First, fork the buildpack on GitHub. Then make sure to rename any reference to Paketo Buildpacks to something else. You need to change the buildpack ID and also the image references, so that you are publishing your own copy of that buildpack.

The Paketo team strongly suggests option #1 as we believe it to be less work than option #2 for most users, and because it does not trigger any change in functionality.

Please reach out to the team if you have any questions.
