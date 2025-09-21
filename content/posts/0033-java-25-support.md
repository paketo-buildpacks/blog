---
title: Paketo Buildpacks add support for Java 25
date: "2025-09-19"
slug: paketo-java-25-support
author: anthonydahanne
---

## Java 25 is now available from Java buildpacks

The Paketo Buildpacks team is excited to announce that, after only 3 days since the first Java 25 builds appeared, Java 25 is now an option for your Paketo Buildpacks Java builds.

Check out those release notes!

https://github.com/paketo-buildpacks/java/releases/tag/v18.14.0

https://github.com/paketo-buildpacks/java-native-image/releases/tag/v11.17.0

But even better, try them out now!

### First option: force Java to 25 using BP_JVM_VERSION

```
cd paketo-buildpacks/samples/java/maven
pack config default-builder paketobuildpacks/builder-noble-java-tiny:latest
pack build applications/maven --env BP_JVM_VERSION=25
[...]
[builder]     Using Java version 25 from BP_JVM_VERSION
[...]
```

### Second option: set your `.sdkmanrc` to Java 25

```
cd paketo-buildpacks/samples/java/maven
sdk install java 25-zulu
sdk use java 25-zulu
sdk env init
cat .sdkmanrc 
java=25-zulu

pack config default-builder paketobuildpacks/builder-noble-java-tiny:latest
pack build applications/maven
[...]
[builder]     Using Java version 25 extracted from .sdkmanrc
[builder]   BellSoft Liberica JDK 25.0.0: Contributing to layer
[builder]     Downloading from https://github.com/bell-sw/Liberica/releases/download/25+37/bellsoft-jdk25+37-linux-aarch64.tar.gz
[...]
```

## What about the other JDK / JRE distributions?

At the time of writing: [Azul Zulu](https://github.com/paketo-buildpacks/azul-zulu/releases/tag/v11.3.0), [Bellsoft Liberica (not NIK yet)](https://github.com/paketo-buildpacks/bellsoft-liberica/releases/tag/v11.3.0), [Oracle and GraalVM](https://github.com/paketo-buildpacks/oracle/releases/tag/v4.2.0), [SAP Machine](https://github.com/paketo-buildpacks/sap-machine/releases/tag/v12.2.0), [Amazon Corretto](https://github.com/paketo-buildpacks/amazon-corretto/releases/tag/v9.3.0) all got upgraded to support Java 25 (and lost support for Java 24)

As a reminder, you can choose your JVM distribution specifying its buildpack:

```
pack build applications/maven  --buildpack paketobuildpacks/azul-zulu:latest --buildpack paketobuildpacks/java:latest --env BP_JVM_VERSION=25
[...]
[builder]     Using Java version 25 from BP_JVM_VERSION
[builder]   Azul Zulu JDK 25.0.0: Contributing to layer
[builder]     Downloading from https://cdn.azul.com/zulu/bin/zulu25.28.85-ca-jdk25.0.0-linux_aarch64.tar.gz
[...]
```

Alibaba Dragonwell, Microsoft OpenJDK, Adoptium, IBM Semeru OpenJ9, Adoptium Temurin did not publish JDK 25 builds yet. 

## What about Java 24? 

Java 24 is not an LTS version, so we no longer bundle it.

See the [RFC](https://github.com/paketo-buildpacks/rfcs/blob/main/text/java/0014-selecting-default-java-version.md) for more explanation.

## Why Java 25 isn't the default?

Java 25 is an LTS version, so in 1 year it will be the default.

See the [RFC](https://github.com/paketo-buildpacks/rfcs/blob/main/text/java/0014-selecting-default-java-version.md) for more explanation.

## Happy migration to Java 25!

Please reach out to the team if you have any questions.
