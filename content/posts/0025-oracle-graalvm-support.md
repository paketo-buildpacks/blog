---
title: Oracle GraalVM Support has Arrived!
date: "2023-12-11"
slug: oracle-graalvm-support-has-arrived
author: dmikusa
---

## Oracle GraalVM Support has Arrived!

Today marks the start of support for building native image applications with [Oracle GraalVM](https://www.oracle.com/java/graalvm/). Since Oracle released Oracle GraalVM under the [GraalVM Free License](https://blogs.oracle.com/java/post/graalvm-free-license), we've been receiving lots of feedback to add support for it. Starting with the 3.11.0 release of the Paketo Buildpack for Oracle we now have official support! 

With this first release, you can build native image applications with Oracle GraalVM. Building your application is simple. You follow the [process for selecting a Native Image Toolkit](https://paketo.io/docs/howto/java/#use-an-alternative-java-native-image-toolkit) and use the Oracle buildpack. 

For example, if we want to build the [Paketo Maven Spring Boot Sample App](https://github.com/paketo-buildpacks/samples/tree/main/java/native-image/spring-boot-native-image-maven) with `pack`, we would simply run `pack build applications/native-image -b paketo-buildpacks/oracle -b urn:cnb:builder:paketo-buildpacks/java-native-image --builder paketobuildpacks/builder-jammy-tiny --env BP_MAVEN_ACTIVE_PROFILES=native`. This small change is all that's required to tell Paketo Buildpacks to override the default JDK distribution including Native Image, which is from Bellsoft, and instead use Oracle GraalVM.

When you build your image, you'll now see the Paketo buildpacks download, install, and run Oracle's GraalVM for you.

```
...
Paketo Buildpack for Oracle 3.11.0
  https://github.com/paketo-buildpacks/oracle
  Build Configuration:
    $BP_JVM_JLINK_ARGS           --no-man-pages --no-header-files --strip-debug --compress=1  configure custom link arguments (--output must be omitted)
    $BP_JVM_JLINK_ENABLED        false                                                        enables running jlink tool to generate custom JRE
    $BP_JVM_TYPE                 JRE                                                          the JVM type - JDK or JRE
    $BP_JVM_VERSION              17                                                           the Java version
  Launch Configuration:
    $BPL_DEBUG_ENABLED           false                                                        enables Java remote debugging support
    $BPL_DEBUG_PORT              8000                                                         configure the remote debugging port
    $BPL_DEBUG_SUSPEND           false                                                        configure whether to suspend execution until a debugger has attached
    $BPL_HEAP_DUMP_PATH                                                                       write heap dumps on error to this path
    $BPL_JAVA_NMT_ENABLED        true                                                         enables Java Native Memory Tracking (NMT)
    $BPL_JAVA_NMT_LEVEL          summary                                                      configure level of NMT, summary or detail
    $BPL_JFR_ARGS                                                                             configure custom Java Flight Recording (JFR) arguments
    $BPL_JFR_ENABLED             false                                                        enables Java Flight Recording (JFR)
    $BPL_JMX_ENABLED             false                                                        enables Java Management Extensions (JMX)
    $BPL_JMX_PORT                5000                                                         configure the JMX port
    $BPL_JVM_HEAD_ROOM           0                                                            the headroom in memory calculation
    $BPL_JVM_LOADED_CLASS_COUNT  35% of classes                                               the number of loaded classes in memory calculation
    $BPL_JVM_THREAD_COUNT        250                                                          the number of threads in memory calculation
    $JAVA_TOOL_OPTIONS                                                                        the JVM launch flags
    Using buildpack default Java version 17
  Oracle GraalVM 17.0.9: Contributing to layer
    Downloading from https://download.oracle.com/graalvm/17/archive/graalvm-jdk-17.0.9_linux-x64_bin.tar.gz
    Verifying checksum
    Expanding to /layers/paketo-buildpacks_oracle/native-image-svm
    Adding 137 container CA certificates to JVM truststore
    Writing env.build/JAVA_HOME.override
    Writing env.build/JDK_HOME.override
...
```

This example shows one of my favorite features of buildpacks, which is that switching JVM and Native Image vendors is trivial. The Oracle GraalVM is fantastic, but if you want to switch to use the GraalVM Community Edition, that's easy too. Just swap in `paketo-buildpacks/graalvm` for `paketo-buildpacks/oracle`. A two-second change and you're building using a different vendor.

Just as easily, you can swap versions too. The Oracle buildpack presently supports both Java 17 and 21, which you can select by setting the `BP_JVM_VERSION` flag. For example, `pack build applications/native-image -b paketobuildpacks/oracle -b urn:cnb:builder:paketo-buildpacks/java-native-image --builder paketobuildpacks/builder-jammy-tiny --env BP_MAVEN_ACTIVE_PROFILES=native --env BP_JVM_VERSION=21`. This makes trying out new versions trivial, which ultimately makes your upgrades easier.

### Spring Boot Build Tools

If you're using Spring Boot Build Tools to generate your application image, you can use Oracle GraalVM with the following changes.

1. Modify the image configuration block in your `pom.xml`.

    ```
    ...
    <configuration>
        <image>
            <builder>paketobuildpacks/builder-jammy-tiny:latest</builder>
            <buildpacks>
                <buildpack>docker.io/paketobuildpacks/oracle</buildpack>
                <buildpack>urn:cnb:builder:paketo-buildpacks/java-native-image</buildpack>
            </buildpacks>
        </image>
    </configuration>
    ...
    ```

2. Then run `./mvnw spring-boot:build-image -Pnative` to build your image.

And the equivalent change with Gradle `build.gradle`:
    ```
    ...
    tasks.named("bootBuildImage") {
        builder = "paketobuildpacks/builder-jammy-tiny:latest"
        buildpacks = ["docker.io/paketobuildpacks/oracle", "urn:cnb:builder:paketo-buildpacks/java-native-image"]
    }
    ...
    ```
2. Then run `./gradlew bootBuildImage` to build your image.

## Future Roadmap

At the moment, the Oracle buildpack supports using the [Oracle free JDK](https://www.oracle.com/java/technologies/downloads/) for running your Java apps, and it supports using [Oracle GraalVM](https://www.oracle.com/java/graalvm/) for building your Native Image apps. What's been left out at the moment is support to use Oracle GraalVM as a JDK to run your Java apps.

This was something we left out of the initial support because it would have delayed the release more and that's something we didn't want to do. Also, we believe that future work in the Paketo project is going to make support for this significantly easier.

What this all means is that for the moment, you can't run your Java apps with GraalVM. We'll be working hard to support this in the future, but in the meantime, we think you'll really enjoy using Oracle GraalVM to build your native images.

As always, please post questions/comments on our [GitHub Discussion Page](https://github.com/orgs/paketo-buildpacks/discussions/categories/java-team), or Join the [Paketo Slack](https://slack.paketo.io/) and chat with us in the `#java` room.
