---
title: Paketo Java Buildpacks Updates its Default JVM Version
date: "2023-02-09"
slug: paketo-java-buildpacks-updates-its-default-jvm-version
author: dmikusa
---

Time and tides wait for no one, nor does software. The Oracle and the OpenJDK project have been steadily releasing new versions of Java for years now, with new Java versions every six months and now long-term support releases every two years (with Java 21, it's dropped to two years from three).

As of writing this post, the Java buildpack is currently using Java 11 as its default. This has been the same default version since the Paketo Java buildpack was released, but we're falling behind and it's time for a change.

Through our community RFC process, the Paketo Java subteam has [adopted an official policy on updating the default version of the JVM](https://github.com/paketo-buildpacks/rfcs/blob/main/text/java/0014-selecting-default-java-version.md), RFC #0014.

The policy states that "the default should be changed once the latest released LTS version of Java is at least one year old". It further states that we should immediately proceed to update the default version from Java 11 to Java 17. This will bring us into alignment with the stated goals of the policy.

Because we realize this will impact users, we are providing a one month advance notice of this change. We will be adjusting the default version of the JVM to Java 17 starting with the Java buildpack release scheduled for Friday March 17th, 2023.

There are a few things you can do to prepare for this change:

1. Upgrade to Java 17! You know you want to, it's great.
2. If you can't upgrade, you can [pin the major Java version](https://paketo.io/docs/howto/java/#install-a-specific-jvm-version) to your required version.
3. Alternatively, you may be able to [set the Java source/target version](https://www.baeldung.com/java-source-target-options) in your project.

If you do pin the version, please make a note or set a reminder to come back and upgrade later.

The project does not recommend pinning the buildpack version. This will prevent the application from being built using the latest patch release of Java and could leave your application vulnerable to know security issues.

That's it! Go forth and build modern Java apps.