---
title: "One buildpack, ten JVM vendors"
date: "2026-09-26T18:00:00+02:00"
slug: one-buildpack-ten-jvm-vendors
author: anthonydahanne
---

Paketo ships ten JVM vendor buildpacks: Adoptium, Alibaba Dragonwell, Amazon Corretto, Azul Zulu, BellSoft Liberica, Eclipse OpenJ9, GraalVM, Microsoft OpenJDK, Oracle and SAP Machine. Until now, that meant ten repositories, ten release trains, and — for you — a `--buildpack` flag every time you wanted anything other than the default.

[`paketo-buildpacks/jvm-vendors`](https://github.com/paketo-buildpacks/jvm-vendors) replaces the ten repositories with one, and adds a `BP_JVM_VENDOR` environment variable so you can pick your vendor without touching the buildpack order.

It is available today as a preview, under `-dev` image names. Read on for what changes, and what to watch out for.

## Picking a vendor today

The `java` composite buildpack bundles exactly one JVM buildpack, BellSoft Liberica:

```
pack inspect-builder paketobuildpacks/builder-noble-java-tiny
[...]
  paketo-buildpacks/bellsoft-liberica    Paketo Buildpack for BellSoft Liberica    11.9.0
```

Want Corretto instead? You override the builder's whole order, which means naming the JVM buildpack *and* the composite, in that order:

```
pack build my-app --buildpack paketobuildpacks/amazon-corretto:latest \
                  --buildpack paketobuildpacks/java:latest
```

Get the order wrong and detection fails. Forget `paketobuildpacks/java` and nothing builds your application. It works, but it is not something you want to explain twice.

## Picking a vendor with jvm-vendors

The `jvm-vendors` buildpack carries all ten vendors, and `BP_JVM_VENDOR` chooses between them:

```
pack build my-app --buildpack paketobuildpacks/jvm-vendors-dev:latest \
                  --buildpack paketobuildpacks/java:latest \
                  --env BP_JVM_VENDOR=amazon-corretto
```

The buildpack prints what it resolved:

```
[builder] Paketo Buildpack for JVM Vendors 0.3.0
[builder]   Build Configuration:
[builder]     $BP_JVM_VENDOR    amazon-corretto                                    the default JVM vendor
[builder]     $BP_JVM_VENDORS   adoptium,alibaba-dragonwell,amazon-corretto,[...]  the available JVM vendors
[builder]     $BP_JVM_VERSION   25                                                 the Java version
[builder]     Using Java version 25 from BP_JVM_VERSION
[builder]    25.0.4: Contributing to layer
[builder]     Downloading from https://corretto.aws/downloads/resources/25.0.4.10.1/amazon-corretto-25.0.4.10.1-linux-aarch64.tar.gz
```

And the image runs what you asked for:

```
openjdk version "25.0.4.1" 2026-08-18 LTS
OpenJDK Runtime Environment Corretto-25.0.4.10.1 (build 25.0.4.1+10-LTS)
```

Once `jvm-vendors` is wired into the builders, the `--buildpack` flags go away entirely and `BP_JVM_VENDOR` is all you need.

## Try it with Java 27

Java 27 is available for seven of the ten vendors — Adoptium, Amazon Corretto, Azul Zulu, BellSoft Liberica, Eclipse OpenJ9, Oracle and SAP Machine. Alibaba Dragonwell, GraalVM and Microsoft OpenJDK have not published 27 builds yet.

Liberica is the default vendor, so `BP_JVM_VENDOR` can be left out:

```
cd paketo-buildpacks/samples
pack build jvm-vendors-demo --path java/maven \
  --builder paketobuildpacks/builder-noble-java-tiny \
  --buildpack paketobuildpacks/jvm-vendors-dev:latest \
  --buildpack paketobuildpacks/java:latest \
  --env BP_JVM_VERSION=27
[...]
[builder]     Using Java version 27 from BP_JVM_VERSION
[builder]    27.0.0: Contributing to layer
[builder]     Downloading from https://github.com/bell-sw/Liberica/releases/download/27+36/bellsoft-jdk27+36-linux-aarch64.tar.gz
[builder]    27.0.0: Contributing to layer
[builder]     Downloading from https://github.com/bell-sw/Liberica/releases/download/27+36/bellsoft-jre27+36-linux-aarch64.tar.gz
[...]
[exporter] Adding layer 'paketo-buildpacks/jvm-vendors:jre-bellsoft-liberica'
Successfully built image 'jvm-vendors-demo'
```

```
docker run --rm --entrypoint launcher jvm-vendors-demo -- java -version
[...]
openjdk version "27" 2026-09-15
OpenJDK Runtime Environment (build 27+36)
```

Any of the other six behaves the same way. SAP Machine, for instance — and unlike Corretto it publishes a real JRE, so that is what ends up in the runtime image:

```
pack build my-app --buildpack paketobuildpacks/jvm-vendors-dev:latest \
                  --buildpack paketobuildpacks/java:latest \
                  --env BP_JVM_VENDOR=sap-machine \
                  --env BP_JVM_VERSION=27
[...]
[builder]     Using Java version 27 from BP_JVM_VERSION
[builder]    27: Contributing to layer
[builder]     Downloading from https://github.com/SAP/SapMachine/releases/download/sapmachine-27/sapmachine-jdk-27_linux-aarch64_bin.tar.gz
[builder]    27: Contributing to layer
[builder]     Downloading from https://github.com/SAP/SapMachine/releases/download/sapmachine-27/sapmachine-jre-27_linux-aarch64_bin.tar.gz
[...]
openjdk version "27" 2026-09-15
OpenJDK Runtime Environment SapMachine (build 27+35)
```

Both `amd64` and `arm64` are covered; the example above ran on an Apple Silicon Mac.

## One repository, eleven buildpackages

Under the hood, `jvm-vendors` is a single Go codebase and a single `buildpack.toml` holding every vendor's dependencies. At packaging time, [`libpak-tools`](https://github.com/paketo-buildpacks/libpak-tools) slices that `buildpack.toml` two different ways:

- **One buildpackage per vendor**, with the dependencies of every other vendor stripped out, published under the buildpack IDs you already use — `paketo-buildpacks/bellsoft-liberica`, `paketo-buildpacks/azul-zulu`, and so on. These are drop-in replacements for the buildpacks coming out of the old repositories.
- **One buildpackage with all ten vendors**, `paketo-buildpacks/jvm-vendors`, which is what `BP_JVM_VENDOR` is for.

Both shapes come out of the same release. The per-vendor buildpacks keep the vendor selection logic too, so in a builder that stacks several of them, the ones you did not ask for step aside during detection:

```
[detector] ======== Output: paketo-buildpacks/bellsoft-liberica@0.3.0 ========
[detector]     SKIPPED: buildpack does not match requested JVM vendor of [sap-machine], buildpack supports ["bellsoft-liberica"]
```

For maintainers, this collapses ten sets of dependency-update workflows, ten `go.mod` files and ten release processes into one.

The shared logic was never duplicated, to be clear: the memory calculator, the NMT helper and the certificate loader all live in [`libjvm`](https://github.com/paketo-buildpacks/libjvm), and all ten buildpacks pinned the same version of it. What cost time was *shipping* a change — a `libjvm` release, then a dependency bump and a release in each of the ten repositories, 229 merged bump pull requests between them so far. `jvm-vendors` has no `libjvm` dependency; that code now lives in the repository itself, and the propagation step is gone.

## Migrating

Three cases cover most setups.

### You never configured a JVM

Nothing to change. BellSoft Liberica is the default vendor in `jvm-vendors`, as it is in the `java` composite today, and the default Java version matches too:

```
pack build my-app --buildpack paketobuildpacks/jvm-vendors-dev:latest \
                  --buildpack paketobuildpacks/java:latest
[...]
[builder] Paketo Buildpack for JVM Vendors 0.3.0
[builder]     $BP_JVM_VERSION   21   the Java version
[builder]     Using buildpack default Java version 21
[builder]    21.0.12: Contributing to layer
[builder]     Downloading from https://github.com/bell-sw/Liberica/releases/download/21.0.12.1+1/bellsoft-jdk21.0.12.1+1-linux-aarch64.tar.gz
```

Same vendor, same version, same artifact as the buildpack you are on today.

### You pinned a vendor and a version

Say Corretto 17. Before, the vendor buildpack went in front of the composite:

```
pack build my-app --buildpack paketobuildpacks/amazon-corretto:latest \
                  --buildpack paketobuildpacks/java:latest \
                  --env BP_JVM_VERSION=17
[...]
[builder]   Corretto JDK 17.0.20: Contributing to layer
[builder]     Downloading from https://corretto.aws/downloads/resources/17.0.20.12.1/amazon-corretto-17.0.20.12.1-linux-aarch64.tar.gz
```

After, the vendor moves out of the buildpack list and into the environment:

```
pack build my-app --buildpack paketobuildpacks/jvm-vendors-dev:latest \
                  --buildpack paketobuildpacks/java:latest \
                  --env BP_JVM_VENDOR=amazon-corretto \
                  --env BP_JVM_VERSION=17
[...]
[builder]    17.0.20: Contributing to layer
[builder]     Downloading from https://corretto.aws/downloads/resources/17.0.20.12.1/amazon-corretto-17.0.20.12.1-linux-aarch64.tar.gz
```

Byte for byte the same archive — same `BP_JVM_VERSION`, same JDK. Corretto has no JRE, so both builds tell you what they did instead:

```
[builder]   No valid JRE available, providing matching JDK instead. Using a JDK at runtime has security implications.
```

That message is not new, and it is worth reading: you are shipping a compiler in your runtime image. If it bothers you, `BP_JVM_VENDOR=adoptium` or `sap-machine` will give you a real JRE.

### You build native images

This used to be the one area where `jvm-vendors` fell short — BellSoft Liberica shipped no NIK builds at all, and Oracle's `native-image-svm` entry pointed at the plain Oracle JDK, so the tool was missing. Both are fixed.

Native image now works for BellSoft Liberica, GraalVM and Oracle, the same three vendors that offer it today. With Liberica:

```
pack build native-liberica \
  --path java/native-image/spring-boot-native-image-maven \
  --builder paketobuildpacks/builder-noble-java-tiny \
  --buildpack paketobuildpacks/jvm-vendors-dev:latest \
  --buildpack paketobuildpacks/java-native-image:latest \
  --env BP_JVM_VENDOR=bellsoft-liberica \
  --env BP_JVM_VERSION=25 \
  --env BP_MAVEN_ACTIVE_PROFILES=native
[...]
[builder]     Downloading from https://github.com/bell-sw/LibericaNIK/releases/download/25.0.4.1+1-25.0.4.1+2/bellsoft-liberica-vm-openjdk25.0.4.1+2-25.0.4.1+1-linux-aarch64.tar.gz
[...]
[builder] Finished generating 'io.paketo.demo.DemoApplication' in 2m 40s.
Successfully built image 'native-liberica'
```

Swap in `BP_JVM_VENDOR=oracle` and you get Oracle GraalVM instead:

```
[builder]     Downloading from https://download.oracle.com/graalvm/25/latest/graalvm-jdk-25_linux-aarch64_bin.tar.gz
[...]
[builder] Finished generating 'io.paketo.demo.DemoApplication' in 5m 23s.
Successfully built image 'native-oracle'
```

Either way you get a binary that is serving requests in well under a tenth of a second:

```
docker run --rm -p 8080:8080 native-liberica
[...]
INFO 1 --- [main] o.s.boot.reactor.netty.NettyWebServer : Netty started on port 8080 (http)
INFO 1 --- [main] io.paketo.demo.DemoApplication        : Started DemoApplication in 0.041 seconds (process running for 0.063)
```

Note the `BP_MAVEN_ACTIVE_PROFILES=native` flag: the Spring Boot native sample needs its AOT profile to generate reachability metadata. That is not specific to `jvm-vendors`, but it is easy to forget.

One gap remains: no vendor publishes a Java 27 native image yet, so native builds top out at 25.

## What to watch out for

The buildpack is a preview, and honest about it:

- Images are published with a `-dev` suffix: `paketobuildpacks/jvm-vendors-dev`, `paketobuildpacks/bellsoft-liberica-dev`, and so on. The production images still come from the old repositories, which are not archived.
- Nothing is wired into the builders yet, so you need the two `--buildpack` flags shown above.
- Versions restart at `0.x` — `0.3.0` at the time of writing, against `11.9.0` for the current `bellsoft-liberica` buildpack.
- Not every vendor ships every artifact. Only Adoptium, Azul Zulu, BellSoft Liberica, Eclipse OpenJ9 and SAP Machine publish a JRE; native image is BellSoft Liberica, GraalVM and Oracle only.

## Tell us what breaks

That is exactly what a preview is for. Try your applications against `paketobuildpacks/jvm-vendors-dev`, and open an issue on [paketo-buildpacks/jvm-vendors](https://github.com/paketo-buildpacks/jvm-vendors/issues) or find us on [Slack](https://slack.paketo.io/) if something behaves differently from the vendor buildpack you use today.

Happy building!
