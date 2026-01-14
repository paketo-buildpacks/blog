---
title: Java Buildpacks enhancements
date: "2023-06-16"
slug: java-buildpacks-enhancements
author: anthonydahanne
---

During the last few weeks, some enhancements were brought to buildpacks related to the Java ecosystem.

Let's discover what's new!

### TL;DR

Checkout the [samples repository for Java examples](https://github.com/paketo-buildpacks/samples/tree/main/java) and the [Paketo Buildpacks official documentation](https://paketo.io/docs/howto/java/) - those provide way more details about Paketo uses cases (native, certificates, network-less, etc.) than the different build plugins (Maven and Gradle) documentation.

And they're always up-to-date! In the rare event they're not, create an [issue or Pull Request](https://github.com/paketo-buildpacks/java) or reach us on [Slack](https://join.slack.com/t/paketobuildpacks/shared_invite/zt-2jayv12ro-eTP8AtcmvyIpEtlANfIb~g), and we will fix that!

## No more Gradle welcome message
This enhancement was pretty trivial to add, but we hope you will like it: we have disabled Gradle build default welcome message.

It's interesting to learn about Gradle new features in the welcome message, but when you re-build several times with the same gradle version, that does not remember you used it more than once already (because it's run from fresh containers), it can be get a bit repetitive.

More details in the [PR](https://github.com/paketo-buildpacks/gradle/issues/244).

## Additional build arguments for Gradle and Maven

Before, you always needed to provide the full arguments lists, even if you just wanted to activate 1 parameter, using 
* `BP_MAVEN_BUILD_ARGUMENTS` for Maven builds or
* `BP_GRADLE_BUILD_ARGUMENTS` for Gradle builds

You can still overwrite all of the arguments using `BP_{MAVEN|GRADLE}_BUILD_ARGUMENTS`, but if you just want to append additional arguments to the default list of arguments you can do that using:
* `BP_MAVEN_ADDITIONAL_BUILD_ARGUMENTS` for Maven builds or
* `BP_GRADLE_ADDITIONAL_BUILD_ARGUMENTS` for Gradle builds

More details in the [Maven PR](https://github.com/paketo-buildpacks/maven/pull/265) and in the [Gradle PR](https://github.com/paketo-buildpacks/gradle/pull/238).

## Specify Maven active profiles
Very similar to the previous enhancement, but just for Maven this time, you can activate a profile without specifying the full list of Maven build arguments now, using:

* `BP_MAVEN_ACTIVE_PROFILES`

This enhancement ([PR](https://github.com/paketo-buildpacks/maven/pull/265)) was actually key for the next item in our list, Spring Boot native detection.


## Better Spring Boot Native detection

Since first-class native builds were added in Spring Boot 3.0, Paketo buildpacks support Spring Boot native builds; using a combination of the `bellsoft-liberica`, `spring-boot` and `native-image` buildpacks.

Up until now, it could be tedious for users wanting to get a native build, to specify so many arguments:

```
pack build applications/native-image \
  --builder paketobuildpacks/builder-jammy-tiny \
  --env BP_NATIVE_IMAGE=true \
  --env BP_MAVEN_BUILD_ARGUMENTS="-Dmaven.test.skip=true --no-transfer-progress package -Pnative" \
  --env BP_JVM_VERSION=17
```

Fortunately, we can simplify! Since the `bellosoft-liberica` buildpack [release 10.0.0 back in March 2023](https://github.com/paketo-buildpacks/bellsoft-liberica/releases/tag/v10.0.0), you no longer need to specify `BP_JVM_VERSION=17` since it's now the default version from 11.

Also, the sharp-eyed reader might notice you can replace `BP_MAVEN_BUILD_ARGUMENTS="-Dmaven.test.skip=true --no-transfer-progress package -Pnative"` with `BP_MAVEN_ACTIVE_PROFILES="native"`.

Making the previous invocation much simpler:

```
pack build applications/native-image \
  --builder paketobuildpacks/builder-jammy-tiny \
  --env BP_MAVEN_ACTIVE_PROFILES=native \
```

But that's only improving one use case of Spring Boot native builds (from source code).

If you tried turning a Spring Boot jar built with AOT hints (using `./mvnw package -Pnative` for example), Paketo buildpacks would not know that you wanted a native image from it.

You had to build using:

```
pack build -p target/spring-boot-demo-0.0.1-SNAPSHOT.jar my-image --env BP_NATIVE_IMAGE=true
```

which is not super intuitive...

Thanks to [the Spring and Spring boot teams](https://github.com/paketo-buildpacks/spring-boot/issues/273), we found a way to be more clever about native detection: detecting the Spring-Boot-3.1-introduced [`Spring-Boot-Native-Processed` META-INF/MANIFEST entry](https://github.com/spring-projects/spring-boot/issues/35205); turning the previous `pack` invocation into:

```
pack build -p target/spring-boot-demo-0.0.1-SNAPSHOT.jar my-image
```

## Next steps

Modern Java is still burgeoning! [Coordinated](https://wiki.openjdk.org/display/crac) [Restore](https://www.azul.com/products/components/crac/) at [Checkpoint](https://github.com/CRaC/docs), also known as  [CRaC](https://github.com/sdeleuze/spring-boot-crac-demo), [modern GraalVM distributions](https://medium.com/graalvm/a-new-graalvm-release-and-new-free-license-4aab483692f5), future [Java 21](https://openjdk.org/projects/jdk/21/) should keep us busy!

Of course, there can still be bugs and missing features we have not yet identified, feel free to create an issue to the appropriate Paketo project - if in doubt, [paketo-buildpacks/java](https://github.com/paketo-buildpacks/java/issues/new/choose) is probably the best place to ask for a new feature or share a new bug.
